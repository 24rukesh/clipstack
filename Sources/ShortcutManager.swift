import Foundation
import Carbon

class ShortcutManager {
    static let shared = ShortcutManager()
    
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private init() {}
    
    struct Settings {
        var enabled: Bool
        var modifiers: UInt32
        var keyCode: UInt32
    }
    
    static let defaultsKeyEnabled = "shortcutEnabled"
    static let defaultsKeyModifiers = "shortcutModifiers"
    static let defaultsKeyKeyCode = "shortcutKeyCode"
    
    func loadSettings() -> Settings {
        let d = UserDefaults.standard
        let enabled: Bool
        if d.object(forKey: Self.defaultsKeyEnabled) == nil {
            enabled = true // default to enabled on first run
        } else {
            enabled = d.bool(forKey: Self.defaultsKeyEnabled)
        }
        let modifiers = d.object(forKey: Self.defaultsKeyModifiers) as? UInt32 ?? UInt32(cmdKey | optionKey)
        let keyCode = d.object(forKey: Self.defaultsKeyKeyCode) as? UInt32 ?? UInt32(kVK_ANSI_V)
        return Settings(enabled: enabled, modifiers: modifiers, keyCode: keyCode)
    }
    
    func save(settings: Settings) {
        let d = UserDefaults.standard
        d.set(settings.enabled, forKey: Self.defaultsKeyEnabled)
        d.set(settings.modifiers, forKey: Self.defaultsKeyModifiers)
        d.set(settings.keyCode, forKey: Self.defaultsKeyKeyCode)
    }
    
    func register(settings: Settings, onTrigger: @escaping () -> Void) {
        unregister()
        guard settings.enabled else { return }
        let hotKeyID = EventHotKeyID(signature: OSType(UInt32(bitPattern: Int32(bitPattern: 0x43534B31))), id: 1)
        let status = RegisterEventHotKey(settings.keyCode, settings.modifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
        guard status == noErr, hotKeyRef != nil else { return }
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { (_, _, userData) in
            if let userData = userData {
                let box = Unmanaged<CallbackBox>.fromOpaque(userData).takeUnretainedValue()
                box.closure()
            }
            return noErr
        }
        let box = CallbackBox(closure: onTrigger)
        InstallEventHandler(GetEventDispatcherTarget(), callback, 1, &eventSpec, UnsafeMutableRawPointer(Unmanaged.passUnretained(box).toOpaque()), &eventHandlerRef)
    }
    
    func unregister() {
        if let hotKeyRef = hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        if let eventHandlerRef = eventHandlerRef { RemoveEventHandler(eventHandlerRef) }
        hotKeyRef = nil
        eventHandlerRef = nil
    }
}

private class CallbackBox {
    let closure: () -> Void
    init(closure: @escaping () -> Void) { self.closure = closure }
}