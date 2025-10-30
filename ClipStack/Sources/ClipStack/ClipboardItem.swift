import Cocoa
import SwiftUI

enum ClipboardItemType: String, Codable {
    case text
    case image
}

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let type: ClipboardItemType
    let content: String?  // For text items
    let timestamp: Date
    
    init(type: ClipboardItemType, content: String?) {
        self.id = UUID()
        self.type = type
        self.content = content
        self.timestamp = Date()
    }
    
    // Convenience initializer for text items
    static func text(_ text: String) -> ClipboardItem {
        return ClipboardItem(type: .text, content: text)
    }
    
    // Convenience initializer for image items
    static func image(_ image: NSImage) -> ClipboardItem {
        return ClipboardItem(type: .image, content: nil)
    }
    
    // Preview text for display in the list
    var previewText: String {
        switch type {
        case .text:
            guard let content = content else { return "Empty text" }
            return content.count > 100 ? String(content.prefix(100)) + "..." : content
        case .image:
            return "Image"
        }
    }
    
    // Formatted timestamp for display
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}