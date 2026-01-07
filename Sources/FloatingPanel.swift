import Cocoa
import SwiftUI

class FloatingPanel: NSPanel {
    let item: ClipboardItem
    weak var appDelegate: AppDelegate?
    var autoCloseTimer: Timer?
    var onCloseCallback: ((FloatingPanel) -> Void)?
    
    init(contentRect: NSRect, item: ClipboardItem, appDelegate: AppDelegate?) {
        self.item = item
        self.appDelegate = appDelegate
        super.init(contentRect: contentRect,
                   styleMask: [.borderless, .nonactivatingPanel, .hudWindow],
                   backing: .buffered,
                   defer: false)
        
        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        
        // Setup Visual Effect View for "HUD" style blur
        let visualEffectView = NSVisualEffectView(frame: self.contentView!.bounds)
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.autoresizingMask = [.width, .height]
        
        // Round corners of the visual effect view
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 12
        visualEffectView.layer?.masksToBounds = true
        
        self.contentView = visualEffectView
        
        // Embed SwiftUI content
        let hostingView = NSHostingView(rootView: FloatingClipView(item: item, onClose: { [weak self] in
            self?.close()
        }, onPaste: { [weak self] in
            self?.paste()
        }))
        hostingView.frame = visualEffectView.bounds
        hostingView.autoresizingMask = [.width, .height]
        
        visualEffectView.addSubview(hostingView)
    }
    
    func startAutoCloseTimer(duration: TimeInterval) {
        autoCloseTimer?.invalidate()
        autoCloseTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.close()
        }
    }
    
    override func close() {
        autoCloseTimer?.invalidate()
        autoCloseTimer = nil
        // Notify delegate before closing
        onCloseCallback?(self)
        super.close()
    }

    func paste() {
        // Delegate paste logic to AppDelegate to ensure it survives panel closure
        appDelegate?.performPaste(item: item)
        
        // Close panel immediately
        self.close()
    }
}
