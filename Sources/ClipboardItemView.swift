import SwiftUI

struct ClipboardItemView: View {
    let item: ClipboardItem
    var onCopy: (() -> Void)? = nil
    @State private var isCopied = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            switch item.type {
            case .text:
                Image(systemName: "text.alignleft")
                    .foregroundColor(.blue)
            case .image:
                Image(systemName: "photo")
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.previewText)
                    .font(.body)
                    .lineLimit(2)
                
                Text(item.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Button(action: {
                        onCopy?()
                        withAnimation { isCopied = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { isCopied = false }
                        }
                    }) {
                        Text(isCopied ? "Copied" : "Copy")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(.top, 2)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
}