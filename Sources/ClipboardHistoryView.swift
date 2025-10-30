import SwiftUI

struct ClipboardHistoryView: View {
    @ObservedObject var clipboardMonitor: ClipboardMonitor
    @State private var searchText = ""
    var onClose: (() -> Void)?
    @State private var showPreferencesInline = false
    private var supportsLoginItem: Bool {
        if #available(macOS 13.0, *) { return true } else { return false }
    }
    // Removed copiedItemId; each row manages its own copied state via its button
    
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
                    ClipboardItemView(item: item, onCopy: {
                        pasteItem(item)
                    })
                    .id(item.id)
                }
                .listStyle(PlainListStyle())
                .onChange(of: clipboardMonitor.clipboardHistory.count) { _ in
                    // When new items are added, keep scroll at top
                    if searchText.isEmpty, let firstId = filteredHistory.first?.id {
                        withAnimation { proxy.scrollTo(firstId, anchor: .top) }
                    }
                }
                .onChange(of: searchText) { _ in
                    // When search changes, jump to top of filtered results
                    if let firstId = filteredHistory.first?.id {
                        withAnimation { proxy.scrollTo(firstId, anchor: .top) }
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
    }
    
    private func pasteItem(_ item: ClipboardItem) {
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
        
        // Ensure notification permission and show system notification
        Notifier.requestAuthorization()
        // Show system notification
        Notifier.notify(title: "Copied to Clipboard", body: item.type == .text ? (item.previewText) : "Image copied")
        // Delay popover closing until after the copied button text appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onClose?()
        }
    }
}