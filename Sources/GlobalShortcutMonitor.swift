import Cocoa
import SwiftUI
import Carbon

class GlobalShortcutMonitor: ObservableObject {
    private var hotKeyRef: EventHotKeyRef?
    private var appDelegate: AppDelegate
    
    @Published var currentKeyCode: Int = kVK_ANSI_V
    @Published var currentModifiers: Int = cmdKey | shiftKey
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        loadShortcut()
    }
    
    func startMonitoring() {
        registerHotKey()
    }
    
    func stopMonitoring() {
        unregisterHotKey()
    }
    
    func setShortcut(keyCode: Int, modifiers: Int) {
        self.currentKeyCode = keyCode
        self.currentModifiers = modifiers
        
        UserDefaults.standard.set(keyCode, forKey: "globalHotkeyKey")
        UserDefaults.standard.set(modifiers, forKey: "globalHotkeyModifiers")
        
        registerHotKey()
    }
    
    private func loadShortcut() {
        if UserDefaults.standard.object(forKey: "globalHotkeyKey") != nil {
            currentKeyCode = UserDefaults.standard.integer(forKey: "globalHotkeyKey")
            currentModifiers = UserDefaults.standard.integer(forKey: "globalHotkeyModifiers")
        } else {
            // Default: Cmd + Shift + V
            currentKeyCode = kVK_ANSI_V
            currentModifiers = cmdKey | shiftKey
        }
    }
    
    var shortcutString: String {
        var str = ""
        if (currentModifiers & cmdKey) != 0 { str += "⌘" }
        if (currentModifiers & shiftKey) != 0 { str += "⇧" }
        if (currentModifiers & optionKey) != 0 { str += "⌥" }
        if (currentModifiers & controlKey) != 0 { str += "⌃" }
        str += Self.keyString(for: currentKeyCode)
        return str
    }
    
    static func keyString(for keyCode: Int) -> String {
        switch keyCode {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        default: return "?"
        }
    }
    
    private func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
    
    private func registerHotKey() {
        unregisterHotKey()
        
        let hotKeyID = EventHotKeyID(signature: OSType(UInt32(bitPattern: Int32(bitPattern: 0x43534B31))), id: 1) // 'CSK1'
        
        let status = RegisterEventHotKey(UInt32(currentKeyCode), UInt32(currentModifiers), hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
        
        if status != noErr {
            print("Failed to register hotkey: \(status)")
            return
        }
        
        // Install event handler if not already installed? 
        // Actually, we need to install the handler once, and it will receive events for the registered hotkey ID.
        // But if we re-register, the ID is same, so handler should be fine.
        // However, we need to make sure we only install the handler once logically.
        // To be safe, we can install it in init or Lazily.
        installEventHandler()
    }
    
    private var eventHandlerRef: EventHandlerRef?
    
    private func installEventHandler() {
        if eventHandlerRef != nil { return }
        
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        let callback: EventHandlerUPP = { (_, eventRef, userData) in
            guard let userData = userData else { return noErr }
            let monitor = Unmanaged<GlobalShortcutMonitor>.fromOpaque(userData).takeUnretainedValue()
            
            // Verify it's our hotkey (optional if we only check one ID)
            var hotKeyID = EventHotKeyID()
            GetEventParameter(eventRef, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            
            if hotKeyID.id == 1 {
                 DispatchQueue.main.async {
                     monitor.appDelegate.showClipboardHistoryAtMouse() // or showClipboardHistory()
                 }
            }
            
            return noErr
        }
        
        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        InstallEventHandler(GetEventDispatcherTarget(), callback, 1, &eventSpec, selfPtr, &eventHandlerRef)
    }
}