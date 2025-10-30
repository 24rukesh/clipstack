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
    let imageData: Data?  // For image items (PNG data)
    let timestamp: Date
    
    init(type: ClipboardItemType, content: String?, imageData: Data? = nil) {
        self.id = UUID()
        self.type = type
        self.content = content
        self.imageData = imageData
        self.timestamp = Date()
    }
    
    // Convenience initializer for text items
    static func text(_ text: String) -> ClipboardItem {
        return ClipboardItem(type: .text, content: text, imageData: nil)
    }
    
    // Convenience initializer for image items
    static func image(_ image: NSImage) -> ClipboardItem {
        // Convert NSImage to PNG data
        var pngData: Data? = nil
        if let tiffData = image.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiffData) {
            pngData = rep.representation(using: .png, properties: [:])
        }
        return ClipboardItem(type: .image, content: nil, imageData: pngData)
    }

    // Convenience initializer for raw image data
    static func imageData(_ data: Data) -> ClipboardItem {
        return ClipboardItem(type: .image, content: nil, imageData: data)
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