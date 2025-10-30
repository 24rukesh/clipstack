import Foundation
import AppKit
import ServiceManagement

class LoginItemManager {
    static let shared = LoginItemManager()
    private init() {}
    
    static let defaultsKeyStartAtLogin = "startAtLogin"
    
    func isStartAtLoginEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: Self.defaultsKeyStartAtLogin)
    }
    
    func setStartAtLogin(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Self.defaultsKeyStartAtLogin)
        if #available(macOS 13.0, *) {
            if enabled {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        } else {
            // App Store build: Start at Login is only supported on macOS 13+
            showUnsupportedAlert()
        }
    }
    
    private func showUnsupportedAlert() {
        let alert = NSAlert()
        alert.messageText = "Start at Login Not Supported"
        alert.informativeText = "This version of macOS does not support enabling Start at Login from the App Store build. Upgrade to macOS 13 or later to enable this feature."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}