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
        let item = ClipboardItem(type: itemType, content: content)
        return item
    }
    
    // Initialize from ClipboardItem model
    convenience init(from clipboardItem: ClipboardItem, context: NSManagedObjectContext) {
        self.init(context: context)
        self.type = clipboardItem.type.rawValue
        self.content = clipboardItem.content
        self.timestamp = clipboardItem.timestamp
        self.identifier = clipboardItem.id.uuidString
    }
}