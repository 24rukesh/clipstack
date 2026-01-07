import SwiftUI
import Carbon

struct ClipboardHistoryView: View {
    @ObservedObject var clipboardMonitor: ClipboardMonitor
    @ObservedObject var globalShortcutMonitor: GlobalShortcutMonitor
    weak var appDelegate: AppDelegate? // Weak reference to avoid retain cycle
    @State private var searchText = ""
    var onClose: (() -> Void)?
    @State private var showPreferencesInline = false
    
    // Keyboard navigation state
    @State private var selectedId: UUID?
    @State private var eventMonitor: Any?
    @State private var isRecordingHotkey = false
    
    private var supportsLoginItem: Bool {
        if #available(macOS 13.0, *) { return true } else { return false }
    }
    
    var filteredHistory: [ClipboardItem] {
        if searchText.isEmpty {
            return clipboardMonitor.clipboardHistory
        } else {
            return clipboardMonitor.clipboardHistory.filter {
                if let content = $0.content {
                    return content.localizedCaseInsensitiveContains(searchText)
                }
                return false
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search clipboard history...", text: $searchText)
                Spacer()
                Button("Clear All") {
                    clipboardMonitor.clearHistory()
                }
                .disabled(clipboardMonitor.clipboardHistory.isEmpty)
                .padding(.horizontal, 8)
                Button(action: {
                    withAnimation { showPreferencesInline.toggle() }
                }) {
                    Image(systemName: "gearshape")
                }
                .padding(.horizontal, 8)
            }
            .padding(8)
            .background(Color.gray.opacity(0.2))
            
            if showPreferencesInline {
                GroupBox(label: Text("Preferences")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Start at login")
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { LoginItemManager.shared.isStartAtLoginEnabled() },
                                set: { v in LoginItemManager.shared.setStartAtLogin(v) }
                            ))
                            .labelsHidden()
                            .disabled(!supportsLoginItem)
                        }
                        if !supportsLoginItem {
                            Text("Requires macOS 13 or later.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Global Shortcut")
                            Spacer()
                            Button(action: {
                                isRecordingHotkey = true
                            }) {
                                Text(isRecordingHotkey ? "Press keys..." : shortcutString)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(isRecordingHotkey ? Color.accentColor : Color.gray.opacity(0.2))
                                    .foregroundColor(isRecordingHotkey ? .white : .primary)
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        HStack {
                            Spacer()
                            Button("Close Preferences") {
                                withAnimation { showPreferencesInline = false }
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
                .padding(.horizontal, 8)
            }
            
            // Clipboard history list with auto-scroll to top on updates
            ScrollViewReader { proxy in
                List(filteredHistory) { item in
                    ClipboardItemView(item: item, isSelected: selectedId == item.id, 
                    onCopy: {
                        copyToClipboard(item)
                    }, 
                    onPaste: {
                        pasteItem(item)
                    })
                    .onDrag {
                        print("[ClipStack] onDrag started for item: \(item.previewText)")
                        if let content = item.content {
                            return NSItemProvider(object: content as NSString)
                        } else if let imageData = item.imageData, let image = NSImage(data: imageData) {
                            return NSItemProvider(object: image)
                        }
                        return NSItemProvider()
                    }
                    .id(item.id)
                    .onTapGesture {
                        print("[ClipStack] onTapGesture triggered")
                        selectedId = item.id
                    }
                }
                .listStyle(PlainListStyle())
                .onChange(of: clipboardMonitor.clipboardHistory.count) { _ in
                    // When new items are added, keep scroll at top and select first
                    if let first = filteredHistory.first {
                        selectedId = first.id
                        withAnimation { proxy.scrollTo(first.id, anchor: .top) }
                    }
                }
                .onChange(of: searchText) { _ in
                    // When search changes, jump to top and select first
                    if let first = filteredHistory.first {
                        selectedId = first.id
                        withAnimation { proxy.scrollTo(first.id, anchor: .top) }
                    } else {
                        selectedId = nil
                    }
                }
                .onChange(of: selectedId) { id in
                    if let id = id {
                        withAnimation { proxy.scrollTo(id, anchor: .center) }
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
        .onAppear {
            setupKeyboardMonitor()
            // Select first item initially
            if selectedId == nil {
                selectedId = filteredHistory.first?.id
            }
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
    }
    
    private func setupKeyboardMonitor() {
        // Prevent duplicate monitors
        guard eventMonitor == nil else { return }
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Handle Hotkey Recording
            if isRecordingHotkey {
                let keyCode = Int(event.keyCode)
                // Ignore modifier-only key presses (e.g. just pressing Cmd)
                // We want key combinations like Cmd+V
                // But NSEvent for modifier usually comes as flagsChanged, not keyDown.
                // keyDown implies a non-modifier key was pressed (mostly).
                // However, we check if valid.
                let mods = carbonModifiers(from: event.modifierFlags)
                
                // Allow cancelling with Esc
                if keyCode == kVK_Escape {
                    isRecordingHotkey = false
                    return nil
                }
                
                // Set the shortcut
                globalShortcutMonitor.setShortcut(keyCode: keyCode, modifiers: mods)
                isRecordingHotkey = false
                return nil
            }
            
            let keyCode = Int(event.keyCode)
            
            switch keyCode {
            case kVK_DownArrow:
                moveSelection(offset: 1)
                return nil // Consume event
            case kVK_UpArrow:
                moveSelection(offset: -1)
                return nil // Consume event
            case kVK_Return:
                if let selected = filteredHistory.first(where: { $0.id == selectedId }) {
                    pasteItem(selected)
                }
                return nil
            case kVK_Escape:
                onClose?()
                return nil
            default:
                return event
            }
        }
    }
    
    private func removeKeyboardMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func carbonModifiers(from flags: NSEvent.ModifierFlags) -> Int {
        var mods = 0
        if flags.contains(.command) { mods |= cmdKey }
        if flags.contains(.shift) { mods |= shiftKey }
        if flags.contains(.option) { mods |= optionKey }
        if flags.contains(.control) { mods |= controlKey }
        return mods
    }
    
    private var shortcutString: String {
        return globalShortcutMonitor.shortcutString
    }
    
    private func moveSelection(offset: Int) {
        let items = filteredHistory
        guard !items.isEmpty else { return }
        
        var newIndex = 0
        if let id = selectedId, let index = items.firstIndex(where: { $0.id == id }) {
            newIndex = index + offset
        } else {
            // If nothing selected, start at 0 (or -1 -> 0 if moving down)
            newIndex = offset > 0 ? 0 : items.count - 1
        }
        
        // Clamp
        newIndex = max(0, min(newIndex, items.count - 1))
        selectedId = items[newIndex].id
    }
    
    private func copyToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch item.type {
        case .text:
            if let content = item.content {
                pasteboard.setString(content, forType: .string)
            }
        case .image:
            if let data = item.imageData, let image = NSImage(data: data) {
                _ = pasteboard.writeObjects([image])
            }
        }
    }

    private func pasteItem(_ item: ClipboardItem) {
        // First copy to clipboard
        copyToClipboard(item)
        
        // Notify user locally if needed, but primarily we want to paste
        // We close the window first to return focus to the previous app
        onClose?()
        
        // Explicitly activate the last application to ensure focus
        if let appDelegate = appDelegate {
            print("[ClipStack] Using passed AppDelegate, calling activateLastApplication")
            appDelegate.activateLastApplication()
        } else if let appDelegate = NSApp.delegate as? AppDelegate {
            print("[ClipStack] Cast NSApp.delegate, calling activateLastApplication")
             appDelegate.activateLastApplication()
        } else {
            print("[ClipStack] ERROR: Could not find AppDelegate")
        }
        
        // Small delay to allow window to close and focus to return
        // Increased to 0.6s to ensure reliable focus switching
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.pasteToCurrentApplication()
        }
    }
    
    private func pasteToCurrentApplication() {
        print("[ClipStack] Attempting to paste to current application...")
        let source = CGEventSource(stateID: .combinedSessionState)
        
        guard let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true),
              let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true),
              let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false),
              let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false) else {
            print("[ClipStack] Failed to create CGEvent for paste.")
            return
        }
        
        cmdDown.flags = .maskCommand
        vDown.flags = .maskCommand
        vUp.flags = .maskCommand
        
        cmdDown.post(tap: .cghidEventTap)
        vDown.post(tap: .cghidEventTap)
        vUp.post(tap: .cghidEventTap)
        cmdUp.post(tap: .cghidEventTap)
        print("[ClipStack] Paste events posted.")
    }
}