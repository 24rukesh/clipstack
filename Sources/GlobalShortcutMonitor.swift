import Cocoa
import SwiftUI
import Carbon

class GlobalShortcutMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func startMonitoring() {
        // Prefer Carbon HotKey registration (does not require Accessibility permission)
        let keyCode: UInt32 = UInt32(kVK_ANSI_V)
        let modifiers: UInt32 = UInt32(cmdKey | optionKey)
        var hotKeyID = EventHotKeyID(signature: OSType(UInt32(bitPattern: Int32(bitPattern: 0x43534B31))), id: 1) // 'CSK1'
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
        if status == noErr, let _ = hotKeyRef {
            var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
            let callback: EventHandlerUPP = { (_, eventRef, userData) in
                if let userData = userData {
                    let monitor = Unmanaged<GlobalShortcutMonitor>.fromOpaque(userData).takeUnretainedValue()
                    DispatchQueue.main.async {
                        monitor.appDelegate.showClipboardHistoryAtMouse()
                    }
                }
                return noErr
            }
            InstallEventHandler(GetEventDispatcherTarget(), callback, 1, &eventSpec, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), &eventHandlerRef)
            return
        }

        // Fallback: event tap requires Accessibility permission
        let checkOptionPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [checkOptionPrompt: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        if !accessEnabled {
            print("Accessibility access not granted. Please enable in System Settings > Privacy & Security > Accessibility")
            return
        }
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                if let refcon = refcon {
                    let monitor = Unmanaged<GlobalShortcutMonitor>.fromOpaque(refcon).takeUnretainedValue()
                    return monitor.handleKeyboardEvent(proxy, type: type, event: event)
                }
                return Unmanaged.passRetained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        if let eventTap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            if let runLoopSource = runLoopSource {
                CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
        }
    }
    
    private func handleKeyboardEvent(_ proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // Check for Cmd+Shift+V
        let flags = event.flags
        let isCmdPressed = flags.contains(.maskCommand)
        let isShiftPressed = flags.contains(.maskShift)
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        // 'V' key code is 9
        if isCmdPressed && isShiftPressed && keyCode == 9 {
            // Show the clipboard history popover
            DispatchQueue.main.async {
                self.appDelegate.showClipboardHistory()
            }
            
            // Suppress the event so it doesn't reach other applications
            return nil
        }
        
        // Pass through all other events
        return Unmanaged.passRetained(event)
    }
    
    func stopMonitoring() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandlerRef = eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
        
        eventTap = nil
        runLoopSource = nil
        hotKeyRef = nil
        eventHandlerRef = nil
    }
}