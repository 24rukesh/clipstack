import SwiftUI

struct ClipboardHistoryView: View {
    @ObservedObject var clipboardMonitor: ClipboardMonitor
    @State private var searchText = ""
    
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
            }
            .padding(8)
            .background(Color.gray.opacity(0.2))
            
            // Clipboard history list
            List(filteredHistory) { item in
                ClipboardItemView(item: item)
                    .onTapGesture {
                        pasteItem(item)
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
            // TODO: Implement image pasting
            break
        }
        
        // Close the popover
        NSApp.windows.first?.performClose(nil)
    }
}