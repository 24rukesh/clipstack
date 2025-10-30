import Cocoa
import SwiftUI
import CoreData

class ClipboardMonitor: ObservableObject {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    @Published var clipboardHistory: [ClipboardItem] = []
    // Screenshot directory watchers
    private var screenshotWatchSources: [DispatchSourceFileSystemObject] = []
    private var screenshotWatchFDs: [Int32] = []
    private var processedScreenshotPaths: Set<String> = []
    private var screenshotLocationPath: String?
    private var screenshotPrefsTimer: Timer?
    
    init() {
        // Load saved clipboard history
        loadHistory()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkForNewContent()
        }
        startScreenshotWatchers()
        startScreenshotPrefsPolling()
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        stopScreenshotWatchers()
        screenshotPrefsTimer?.invalidate()
        screenshotPrefsTimer = nil
    }
    
    private func checkForNewContent() {
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
                // Prefer PNG data for storage and pasting
                if let tiffData = image.tiffRepresentation,
                   let rep = NSBitmapImageRep(data: tiffData),
                   let pngData = rep.representation(using: .png, properties: [:]) {
                    addClipboardItem(.imageData(pngData))
                } else {
                    addClipboardItem(.image(image))
                }
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

        // Notify that a new item was saved
        switch item.type {
        case .text:
            let preview = item.previewText
            Notifier.notify(title: "Saved to ClipStack", body: preview)
        case .image:
            Notifier.notify(title: "Saved to ClipStack", body: "Image saved")
        }
    }

    // MARK: - Screenshot Watchers
    private func startScreenshotWatchers() {
        // Resolve user-configured screenshot location (System Settings → Screenshots)
        let resolved = getScreenshotLocationFromPreferences()
        screenshotLocationPath = resolved
        var candidateDirs: [String] = []
        if let loc = resolved { candidateDirs.append(loc) }
        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser
        let desktop = home.appendingPathComponent("Desktop").path
        let picturesScreenshots = home.appendingPathComponent("Pictures/Screenshots").path
        for dir in [desktop, picturesScreenshots] {
            if !candidateDirs.contains(dir) { candidateDirs.append(dir) }
        }
        candidateDirs.forEach { addDirectoryWatchIfExists($0) }
    }

    private func addDirectoryWatchIfExists(_ path: String) {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue {
            let fd = open(path, O_EVTONLY)
            if fd >= 0 {
                let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .write, queue: DispatchQueue.global(qos: .utility))
                source.setEventHandler { [weak self] in
                    self?.scanForNewScreenshots(in: path)
                }
                source.setCancelHandler { [weak self] in
                    if let idx = self?.screenshotWatchFDs.firstIndex(of: fd) { self?.screenshotWatchFDs.remove(at: idx) }
                    close(fd)
                }
                screenshotWatchFDs.append(fd)
                screenshotWatchSources.append(source)
                source.resume()
            }
        }
    }

    private func stopScreenshotWatchers() {
        screenshotWatchSources.forEach { $0.cancel() }
        screenshotWatchSources.removeAll()
        screenshotWatchFDs.forEach { close($0) }
        screenshotWatchFDs.removeAll()
        processedScreenshotPaths.removeAll()
    }

    private func scanForNewScreenshots(in path: String) {
        let url = URL(fileURLWithPath: path)
        guard let items = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]) else { return }
        let screenshots = items.filter { u in
            let name = u.lastPathComponent.lowercased()
            return (name.hasPrefix("screenshot") || name.contains("screenshot")) && name.hasSuffix(".png")
        }
        // Sort by modification date descending
        let sorted = screenshots.sorted { a, b in
            let da = (try? a.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            let db = (try? b.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            return da > db
        }
        // Process the most recent few to be safe
        for u in sorted.prefix(3) {
            let path = u.path
            if processedScreenshotPaths.contains(path) { continue }
            processedScreenshotPaths.insert(path)
            processScreenshot(at: u)
        }
    }

    private func processScreenshot(at url: URL) {
        if let image = NSImage(contentsOf: url) {
            DispatchQueue.main.async {
                let pb = NSPasteboard.general
                pb.clearContents()
                _ = pb.writeObjects([image])
            }
        }
    }

    private func getScreenshotLocationFromPreferences() -> String? {
        // Read from com.apple.screencapture domain; value is a POSIX path string
        if let value = CFPreferencesCopyAppValue("location" as CFString, "com.apple.screencapture" as CFString) {
            if let str = value as? String, !str.isEmpty { return str }
        }
        return nil
    }

    private func startScreenshotPrefsPolling() {
        screenshotPrefsTimer?.invalidate()
        screenshotPrefsTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.refreshScreenshotLocation()
        }
    }

    private func refreshScreenshotLocation() {
        let newLoc = getScreenshotLocationFromPreferences()
        guard newLoc != screenshotLocationPath else { return }
        screenshotLocationPath = newLoc
        // Reconfigure watchers to track new directory
        stopScreenshotWatchers()
        startScreenshotWatchers()
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
        
        // Save up to 100 most recent items
        for item in clipboardHistory.prefix(100) {
            _ = ClipboardItemEntity(from: item, context: context)
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