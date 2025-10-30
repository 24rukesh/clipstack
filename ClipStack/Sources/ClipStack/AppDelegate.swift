import Cocoa
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var clipboardMonitor: ClipboardMonitor!
    var globalShortcutMonitor: GlobalShortcutMonitor!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize clipboard monitoring first
        clipboardMonitor = ClipboardMonitor()
        clipboardMonitor.startMonitoring()
        
        // Create the status item for the menu bar
        setupMenuBar()
        
        // Initialize global shortcut monitoring
        globalShortcutMonitor = GlobalShortcutMonitor(appDelegate: self)
        globalShortcutMonitor.startMonitoring()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ClipStack")
            button.action = #selector(statusBarButtonClicked)
        }
        
        // Create popover for clipboard history
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        
        // Set the content view
        let historyView = ClipboardHistoryView(clipboardMonitor: clipboardMonitor)
        popover.contentViewController = NSHostingController(rootView: historyView)
    }
    
    @objc func statusBarButtonClicked() {
        toggleClipboardHistory()
    }
    
    func showClipboardHistory() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func toggleClipboardHistory() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            showClipboardHistory()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor.stopMonitoring()
        globalShortcutMonitor.stopMonitoring()
    }
}