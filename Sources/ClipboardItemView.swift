import SwiftUI

struct ClipboardItemView: View {
    let item: ClipboardItem
    var isSelected: Bool = false
    var onCopy: (() -> Void)? = nil
    var onPaste: (() -> Void)? = nil
    @State private var isCopied = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            switch item.type {
            case .text:
                Image(systemName: "text.alignleft")
                    .foregroundColor(isSelected ? .white : .blue)
            case .image:
                Image(systemName: "photo")
                    .foregroundColor(isSelected ? .white : .green)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.previewText)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(item.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                
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
                            .background(isCopied ? Color.green : (isSelected ? Color.white.opacity(0.2) : Color.gray.opacity(0.2)))
                            .foregroundColor(isSelected ? .white : .primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        onPaste?()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.turn.up.left")
                            Text("Paste")
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
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
        .padding(.horizontal, 8)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(8)
    }
}