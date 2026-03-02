import Foundation
import os.log

/// Unified logging infrastructure for ClipStack
/// Uses Apple's unified logging system for better performance and filtering
enum AppLogger {
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.clipstack"
    
    /// General application events
    static let general = Logger(subsystem: subsystem, category: "general")
    
    /// Clipboard monitoring and history management
    static let clipboard = Logger(subsystem: subsystem, category: "clipboard")
    
    /// Screenshot detection and processing
    static let screenshot = Logger(subsystem: subsystem, category: "screenshot")
    
    /// Core Data operations and persistence
    static let coreData = Logger(subsystem: subsystem, category: "coredata")
    
    /// Keyboard shortcuts and hotkey events
    static let shortcuts = Logger(subsystem: subsystem, category: "shortcuts")
    
    /// UI events and user interactions
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    /// Paste operations and app activation
    static let paste = Logger(subsystem: subsystem, category: "paste")
    
    /// Performance monitoring and metrics
    static let performance = Logger(subsystem: subsystem, category: "performance")
}

// MARK: - Convenience Extensions
extension Logger {
    /// Log an error with context
    func error(_ message: String, error: Error) {
        self.error("\(message): \(error.localizedDescription)")
    }
}
