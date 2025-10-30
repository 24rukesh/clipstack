import Cocoa
import SwiftUI

@MainActor
class GlobalShortcutMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func startMonitoring() {
        // Check if we have permission to monitor events
        let checkOptionPrompt = "AXTrustedCheckOptionPrompt"
        let options = [checkOptionPrompt: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        
        if !accessEnabled {
            print("Accessibility access not granted. Please enable in System Preferences > Security & Privacy > Privacy > Accessibility")
            return
        }
        
        // Create the event tap for Cmd+Shift+V
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
            Task { @MainActor in
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
        
        eventTap = nil
        runLoopSource = nil
    }
}