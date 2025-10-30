import Cocoa
import SwiftUI
import CoreData

@MainActor
class ClipboardMonitor: ObservableObject {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    @Published var clipboardHistory: [ClipboardItem] = []
    
    init() {
        // Load saved clipboard history
        loadHistory()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                await self.checkForNewContent()
            }
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkForNewContent() async {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount
        
        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount
            
            // Check if we have text content
            if let text = pasteboard.string(forType: .string) {
                addClipboardItem(.text(text))
            }
            // Check if we have image content
            else if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
                addClipboardItem(.image(image))
            }
        }
    }
    
    private func addClipboardItem(_ item: ClipboardItem) {
        // Add to the beginning of the history
        clipboardHistory.insert(item, at: 0)
        
        // Limit history to 100 items
        if clipboardHistory.count > 100 {
            clipboardHistory.removeLast()
        }
        
        // Save the updated history
        saveHistory()
    }
    
    private func saveHistory() {
        let context = CoreDataManager.shared.context
        
        // Clear existing entities
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ClipboardItemEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error clearing existing clipboard items: \(error)")
        }
        
        // Save current history
        for item in clipboardHistory {
            let entity = ClipboardItemEntity(from: item, context: context)
            // Limit to 100 items in Core Data as well
            if entity.identifier != clipboardHistory.prefix(100).last?.id.uuidString {
                context.delete(entity)
            }
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