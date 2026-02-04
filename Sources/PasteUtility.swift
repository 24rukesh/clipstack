import Cocoa
import os.log

/// Shared utility for simulating paste commands across the application
/// Consolidates duplicate paste logic from AppDelegate and ClipboardHistoryView
enum PasteUtility {
    
    // MARK: - Permission State Tracking
    
    /// UserDefaults key for tracking if permissions were previously granted
    private static let permissionsGrantedKey = "HasGrantedAccessibilityPermissions"
    
    /// Checks if accessibility permissions are trusted, with retry logic for fresh launches
    /// - Parameters:
    ///   - retryCount: Number of times to retry checking (default: 3)
    ///   - delay: Delay between retries in seconds (default: 0.5)
    /// - Returns: true if permissions are granted, false otherwise
    static func checkAccessibilityPermissions(retryCount: Int = 3, delay: TimeInterval = 0.5) -> Bool {
        for attempt in 0..<retryCount {
            if AXIsProcessTrusted() {
                AppLogger.paste.info("Accessibility permissions verified (attempt \(attempt + 1))")
                return true
            }
            
            if attempt < retryCount - 1 {
                AppLogger.paste.debug("Permission not yet trusted, waiting \(delay)s before retry")
                Thread.sleep(forTimeInterval: delay)
            }
        }
        
        AppLogger.paste.warning("Accessibility permissions not granted after \(retryCount) attempts")
        return false
    }
    
    // MARK: - Paste Simulation
    
    /// Simulates a Cmd+V paste command using CGEvent
    /// This allows programmatic pasting into other applications
    static func simulatePaste() {
        AppLogger.paste.debug("Simulating Cmd+V paste command")
        
        // Use combinedSessionState for better reliability with user session apps
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Create keyboard events: Cmd down, V down, V up, Cmd up
        guard let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: AppConstants.VirtualKeys.command, keyDown: true),
              let vDown = CGEvent(keyboardEventSource: source, virtualKey: AppConstants.VirtualKeys.v, keyDown: true),
              let vUp = CGEvent(keyboardEventSource: source, virtualKey: AppConstants.VirtualKeys.v, keyDown: false),
              let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: AppConstants.VirtualKeys.command, keyDown: false) else {
            AppLogger.paste.error("Failed to create CGEvents for paste")
            return
        }
        
        // Set command modifier flags
        cmdDown.flags = .maskCommand
        vDown.flags = .maskCommand
        vUp.flags = .maskCommand
        
        // Post events in sequence
        cmdDown.post(tap: .cghidEventTap)
        vDown.post(tap: .cghidEventTap)
        vUp.post(tap: .cghidEventTap)
        cmdUp.post(tap: .cghidEventTap)
        
        AppLogger.paste.debug("Paste events posted successfully")
    }
    
    /// Copies content to pasteboard without simulating a paste
    /// - Parameter item: The clipboard item to copy
    static func copyToPasteboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch item.type {
        case .text:
            if let content = item.content {
                pasteboard.setString(content, forType: .string)
                AppLogger.clipboard.debug("Copied text to pasteboard (\(content.count) chars)")
            }
        case .image:
            if let data = item.imageData, let image = NSImage(data: data) {
                _ = pasteboard.writeObjects([image])
                AppLogger.clipboard.debug("Copied image to pasteboard")
            }
        }
    }
    
    /// Performs a complete paste operation: copy to pasteboard, activate target app, then paste
    /// - Parameters:
    ///   - item: The clipboard item to paste
    ///   - targetApp: Optional target application to activate before pasting
    ///   - completion: Optional callback after paste completes
    static func performPaste(
        item: ClipboardItem,
        activating targetApp: NSRunningApplication?,
        completion: (() -> Void)? = nil
    ) {
        // Check if we've previously confirmed permissions
        let previouslyGranted = UserDefaults.standard.bool(forKey: permissionsGrantedKey)
        
        // Use retry logic - more retries if previously granted (TCC may be syncing)
        let retryCount = previouslyGranted ? 5 : 2
        let hasPermission = checkAccessibilityPermissions(retryCount: retryCount, delay: 0.5)
        
        guard hasPermission else {
            // Show alert only if first time or after extended retries
            AppLogger.paste.error("Accessibility permissions check failed after \(retryCount) attempts")
            
            DispatchQueue.main.async {
                let alert = NSAlert()
                
                if previouslyGranted {
                    // Permission was granted before but now failed - unusual situation
                    alert.messageText = "Accessibility Permission Issue"
                    alert.informativeText = "ClipStack previously had accessibility permissions but can't access them now. This can happen after app updates. Please verify permissions in System Settings and restart ClipStack."
                    alert.alertStyle = .warning
                } else {
                    // First time - normal permission request
                    alert.messageText = "Accessibility Permissions Required"
                    alert.informativeText = "ClipStack needs accessibility permissions to paste automatically. Please grant permissions in System Settings."
                    alert.alertStyle = .informational
                }
                
                alert.addButton(withTitle: "Open Settings")
                alert.addButton(withTitle: "Cancel")
                
                if alert.runModal() == .alertFirstButtonReturn {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            return
        }
        
        // Store that we've successfully verified permissions
        if !previouslyGranted {
            UserDefaults.standard.set(true, forKey: permissionsGrantedKey)
            AppLogger.paste.info("Stored accessibility permission confirmation")
        }
        
        AppLogger.paste.debug("Accessibility permissions verified")
        
        // First, copy to pasteboard
        copyToPasteboard(item)
        
        // Activate target application if provided
        if let app = targetApp {
            AppLogger.paste.debug("Activating target app: \(app.localizedName ?? "Unknown")")
            app.activate(options: .activateIgnoringOtherApps)
        } else {
            AppLogger.paste.warning("No target application to activate")
        }
        
        // Delay to allow app activation, then simulate paste
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Timing.pasteDelay) {
            simulatePaste()
            completion?()
        }
    }
}
