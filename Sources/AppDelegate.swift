import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var statusMenu: NSMenu!
    var clipboardMonitor: ClipboardMonitor!
    var globalShortcutMonitor: GlobalShortcutMonitor!
    var permissionsWindow: NSWindow?
    var anchorWindow: NSWindow?
    var preferencesWindow: NSWindow?
    var onboardingWindow: NSWindow?
    
    var lastActiveApplication: NSRunningApplication?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize monitors FIRST so views have valid references
        clipboardMonitor = ClipboardMonitor()
        globalShortcutMonitor = GlobalShortcutMonitor(appDelegate: self)

        // Request notification permission early
        _ = Notifier.shared // ensure delegate is set
        Notifier.requestAuthorization()

        // Create the status item and popover for the menu bar
        setupMenuBar()

        // Start monitoring services
        clipboardMonitor.startMonitoring()
        globalShortcutMonitor.startMonitoring()

        // Show onboarding on first launch
        if !UserDefaults.standard.bool(forKey: "hasOnboarded") {
            showOnboardingWindow()
        }
    }
    
    var eventMonitor: EventMonitor?

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ClipStack") {
                image.isTemplate = true // ensure proper monochrome rendering in status bar
                button.image = image
            } else {
                // Fallback to emoji/title if symbol image cannot be loaded
                button.title = "📋"
            }
            button.target = self
            button.action = #selector(statusBarButtonClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Build status menu with actions
        statusMenu = NSMenu()
        let showItem = NSMenuItem(title: "Show Clipboard History", action: #selector(showClipboardHistory), keyEquivalent: "")
        showItem.target = self
        statusMenu.addItem(showItem)
        statusMenu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Quit ClipStack", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        statusMenu.addItem(quitItem)

        // Create popover for clipboard history
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .semitransient
        
        // Set the content view and provide a close handler
        let historyView = ClipboardHistoryView(clipboardMonitor: clipboardMonitor, globalShortcutMonitor: globalShortcutMonitor, appDelegate: self, onClose: { [weak self] in
            self?.closePopover(nil)
        })
        popover.contentViewController = NSHostingController(rootView: historyView)
        
        // Initialize EventMonitor to close popover on outside clicks
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let self = self, self.popover.isShown {
                 self.closePopover(event)
            }
        }
    }
    
    @objc func statusBarButtonClicked() {
        // Right click opens the menu, left click toggles the popover
        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            if let menu = statusMenu {
                statusItem.popUpMenu(menu)
            }
            return
        }
        toggleClipboardHistory()
    }
    
    @objc func showClipboardHistory() {
        // Capture the current frontmost app before we activate ourselves
        if let currentApp = NSWorkspace.shared.frontmostApplication {
             if currentApp.bundleIdentifier != Bundle.main.bundleIdentifier {
                lastActiveApplication = currentApp
                print("[ClipStack] Captured last active app: \(currentApp.localizedName ?? "Unknown")")
             }
        }
        
        NSApp.activate(ignoringOtherApps: true)
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            eventMonitor?.start()
        }
    }

    func showClipboardHistoryAtMouse() {
        // Capture the current frontmost app before we activate ourselves
        if let currentApp = NSWorkspace.shared.frontmostApplication {
             if currentApp.bundleIdentifier != Bundle.main.bundleIdentifier {
                lastActiveApplication = currentApp
                print("[ClipStack] Captured last active app (mouse): \(currentApp.localizedName ?? "Unknown")")
             }
        }
        
        NSApp.activate(ignoringOtherApps: true)
        let mouse = NSEvent.mouseLocation
        let rect = NSRect(x: mouse.x, y: mouse.y, width: 1, height: 1)
        let win = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
        win.isOpaque = false
        win.backgroundColor = .clear
        win.level = .floating
        win.ignoresMouseEvents = true
        win.makeKeyAndOrderFront(nil)
        anchorWindow = win
        if let view = win.contentView {
            popover.show(relativeTo: view.bounds, of: view, preferredEdge: .maxY)
            eventMonitor?.start()
        }
    }
    
    func activateLastApplication() {
        if let app = lastActiveApplication {
            print("[ClipStack] Activating last app: \(app.localizedName ?? "Unknown")")
            app.activate(options: .activateIgnoringOtherApps)
        } else {
            print("[ClipStack] No last application to activate.")
            NSApp.hide(nil) // Fallback: just hide ourselves to let the next app come forward
        }
    }
    
    // New helper to close popover and stop monitor
    @objc func closePopover(_ sender: Any?) {
        popover.performClose(sender)
        anchorWindow?.orderOut(sender)
        anchorWindow = nil
        eventMonitor?.stop()
    }
    
    func toggleClipboardHistory() {
        if popover.isShown {
            closePopover(nil)
        } else {
            showClipboardHistory()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor.stopMonitoring()
        // Shortcut removed; nothing to stop
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func showPermissionsWindow() {
        if permissionsWindow != nil { return }
        let hosting = NSHostingController(rootView: PermissionsView(onClose: { [weak self] in
            self?.permissionsWindow?.close()
            self?.permissionsWindow = nil
        }))
        let window = NSWindow(contentViewController: hosting)
        window.title = "ClipStack Permissions"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        permissionsWindow = window
    }

    func showOnboardingWindow() {
        if onboardingWindow != nil { onboardingWindow?.makeKeyAndOrderFront(nil); return }
        let view = OnboardingView(onClose: { [weak self] in
            self?.onboardingWindow?.close()
            self?.onboardingWindow = nil
        })
        let hosting = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hosting)
        window.title = "Get Started"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        onboardingWindow = window
    }

    @objc func openPreferences() {
        if preferencesWindow != nil { preferencesWindow?.makeKeyAndOrderFront(nil); return }
        let view = PreferencesView(onApply: { [weak self] newSettings in
            ShortcutManager.shared.register(settings: newSettings) {
                NSApp.activate(ignoringOtherApps: true)
                self?.showClipboardHistory()
            }
            // Relaunch the app to ensure settings apply and recover if the app closes
            self?.relaunchApp()
        })
        let hosting = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hosting)
        window.title = "ClipStack Preferences"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        preferencesWindow = window
    }

    func relaunchApp() {
        let bundlePath = Bundle.main.bundlePath
        let process = Process()
        process.launchPath = "/usr/bin/open"
        process.arguments = [bundlePath]
        try? process.run()
        // Give the new instance a moment to start, then terminate this one
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NSApp.terminate(nil)
        }
    }
}