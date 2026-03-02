import Foundation

/// Central constants for ClipStack application configuration
enum AppConstants {
    
    /// Timing-related constants
    enum Timing {
        /// Delay before simulating paste command (allows app switching)
        static let pasteDelay: TimeInterval = 0.6
        
        /// Duration floating bubbles remain visible
        static let bubbleDisplayDuration: TimeInterval = 8.0
        
        /// Interval for polling screenshot preferences changes
        static let screenshotPrefsPollingInterval: TimeInterval = 10.0
    }
    
    /// Limit constants for memory and performance management
    enum Limits {
        /// Maximum clipboard history items to store
        static let maxHistoryItems = 100
        
        /// Maximum floating bubbles to display simultaneously
        static let maxBubbleCount = 5
        
        /// Maximum content size in bytes before truncation/rejection
        static let maxContentSize = 1_000_000 // 1MB
        
        /// Maximum screenshot paths to track (LRU cache)
        static let maxScreenshotPaths = 1000
        
        /// Number of recent screenshots to process per scan
        static let screenshotScanLimit = 3
    }
    
    /// UI dimension constants
    enum UI {
        /// Default popover dimensions
        static let popoverWidth: CGFloat = 300
        static let popoverHeight: CGFloat = 400
        
        /// Floating panel dimensions
        static let panelWidth: CGFloat = 240
        static let panelHeight: CGFloat = 80
        
        /// Spacing and padding
        static let panelGap: CGFloat = 10
        static let rightPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 20
        
        /// Corner radius
        static let panelCornerRadius: CGFloat = 12
    }
    
    /// Virtual key codes for keyboard shortcuts
    enum VirtualKeys {
        static let command: UInt16 = 0x37
        static let v: UInt16 = 0x09
    }
    
    /// UserDefaults keys
    enum DefaultsKeys {
        static let hasOnboarded = "hasOnboarded"
        static let startAtLogin = "startAtLogin"
        static let shortcutEnabled = "shortcutEnabled"
        static let shortcutModifiers = "shortcutModifiers"
        static let shortcutKeyCode = "shortcutKeyCode"
        static let globalHotkeyKey = "globalHotkeyKey"
        static let globalHotkeyModifiers = "globalHotkeyModifiers"
    }
}
