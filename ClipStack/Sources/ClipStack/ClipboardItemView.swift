import SwiftUI

struct ClipboardItemView: View {
    let item: ClipboardItem
    
    var body: some View {
        HStack {
            switch item.type {
            case .text:
                Image(systemName: "text.alignleft")
                    .foregroundColor(.blue)
            case .image:
                Image(systemName: "photo")
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText)
                    .font(.body)
                    .lineLimit(2)
                
                Text(item.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}