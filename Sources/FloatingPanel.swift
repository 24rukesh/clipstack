import Cocoa
import SwiftUI

class FloatingPanel: NSPanel {
    
    init(contentRect: NSRect, item: ClipboardItem) {
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
        }))
        hostingView.frame = visualEffectView.bounds
        hostingView.autoresizingMask = [.width, .height]
        
        visualEffectView.addSubview(hostingView)
    }
}
