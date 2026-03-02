import Cocoa
import SwiftUI
import CoreData

class ClipboardMonitor: ObservableObject {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    @Published var clipboardHistory: [ClipboardItem] = []
    
    // Thread-safe queue for screenshot operations
    private let screenshotQueue = DispatchQueue(label: "com.clipstack.screenshots", qos: .utility)
    
    init() {
        // Load saved clipboard history
        loadHistory()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkForNewContent()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        AppLogger.clipboard.info("Clipboard monitoring stopped")
    }
    
    private func checkForNewContent() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount
        
        // Only process if change count actually changed
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount
        
        // Check if we have text content
        if let text = pasteboard.string(forType: .string) {
            addClipboardItem(.text(text))
        }
    }
    
    // Closure to notify delegate (AppDelegate) of new items
    var onNewItem: ((ClipboardItem) -> Void)?

    private func addClipboardItem(_ item: ClipboardItem) {
        // Input validation: check content size
        if item.type == .text, let content = item.content, content.utf8.count > AppConstants.Limits.maxContentSize {
            AppLogger.clipboard.warning("Skipping large text item (\(content.utf8.count) bytes > \(AppConstants.Limits.maxContentSize) limit)")
            return
        }
        
        if item.type == .image, let imageSize = item.imageData?.count, imageSize > AppConstants.Limits.maxContentSize * 10 {
            AppLogger.clipboard.warning("Skipping large image (\(imageSize) bytes)")
            return
        }
        
        // Add to the beginning of the history
        clipboardHistory.insert(item, at: 0)
        
        // Limit history to configured max
        if clipboardHistory.count > AppConstants.Limits.maxHistoryItems {
            clipboardHistory.removeLast()
        }
        
        // Save the updated history
        saveHistory()

        // Notify that a new item was saved
        // Trigger the Floating Panel Bubble instead of system notification
        onNewItem?(item)
    }


    
    private func saveHistory() {
        let context = CoreDataManager.shared.context
        
        // Incremental save: only add new items not already persisted
        let fetchRequest: NSFetchRequest<ClipboardItemEntity> = ClipboardItemEntity.fetchRequest()
        
        do {
            let existingEntities = try context.fetch(fetchRequest)
            let existingIDs = Set(existingEntities.compactMap { $0.identifier })
            
            // Only insert items not already in the database
            let itemsToSave = clipboardHistory.prefix(AppConstants.Limits.maxHistoryItems)
            var newItemsCount = 0
            
            for item in itemsToSave {
                let itemID = item.id.uuidString
                if !existingIDs.contains(itemID) {
                    _ = ClipboardItemEntity(from: item, context: context)
                    newItemsCount += 1
                }
            }
            
            // Remove items beyond limit
            if existingEntities.count + newItemsCount > AppConstants.Limits.maxHistoryItems {
                let itemsToDelete = existingEntities.count + newItemsCount - AppConstants.Limits.maxHistoryItems
                let oldestItems = existingEntities.suffix(itemsToDelete)
                for entity in oldestItems {
                    context.delete(entity)
                }
            }
            
            AppLogger.coreData.debug("Saving \(newItemsCount) new items to Core Data")
        } catch {
            AppLogger.coreData.error("Error preparing incremental save", error: error)
        }
        
        CoreDataManager.shared.saveContext()
    }

    func clearHistory() {
        clipboardHistory.removeAll()
        // Clear Core Data store
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ClipboardItemEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error clearing existing clipboard items: \(error)")
        }
        CoreDataManager.shared.saveContext()
    }
    
    private func loadHistory() {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<ClipboardItemEntity> = ClipboardItemEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 100
        
        do {
            let entities = try context.fetch(fetchRequest)
            clipboardHistory = entities.compactMap { $0.toClipboardItem() }
        } catch {
            print("Error loading clipboard history: \(error)")
        }
    }
}