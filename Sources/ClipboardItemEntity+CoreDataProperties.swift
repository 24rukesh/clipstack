import Foundation
import CoreData

extension ClipboardItemEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipboardItemEntity> {
        return NSFetchRequest<ClipboardItemEntity>(entityName: "ClipboardItemEntity")
    }
    
    @NSManaged public var type: String?
    @NSManaged public var content: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var identifier: String?
    
    // Convert to ClipboardItem model
    func toClipboardItem() -> ClipboardItem? {
        guard let typeString = type,
              let itemType = ClipboardItemType(rawValue: typeString),
              let _ = timestamp,
              let _ = identifier else {
            return nil
        }
        
        // Create a ClipboardItem with the stored values
        switch itemType {
        case .text:
            return ClipboardItem(type: .text, content: content, imageData: nil)
        case .image:
            let data = content.flatMap { Data(base64Encoded: $0) }
            return ClipboardItem(type: .image, content: nil, imageData: data)
        }
    }
    
    // Initialize from ClipboardItem model
    convenience init(from clipboardItem: ClipboardItem, context: NSManagedObjectContext) {
        self.init(context: context)
        self.type = clipboardItem.type.rawValue
        switch clipboardItem.type {
        case .text:
            self.content = clipboardItem.content
        case .image:
            self.content = clipboardItem.imageData?.base64EncodedString()
        }
        self.timestamp = clipboardItem.timestamp
        self.identifier = clipboardItem.id.uuidString
    }
}