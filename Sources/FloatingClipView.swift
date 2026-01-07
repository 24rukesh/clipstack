import SwiftUI

struct FloatingClipView: View {
    let item: ClipboardItem
    var onClose: (() -> Void)? = nil
    var onPaste: (() -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // Main Content Area
            Group {
                if let color = item.detectedColor, let hexText = item.content {
                    // Color Item Layout
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color)
                            .frame(width: 60, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(hexText.trimmingCharacters(in: .whitespacesAndNewlines))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Text("Color")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                    }
                    .padding(12)
                    
                } else {
                    // Standard Text/Image Layout
                    HStack(spacing: 12) {
                        // Left: Thumbnail / Icon
                        Group {
                            if let imageData = item.imageData, let nsImage = NSImage(data: imageData) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                // Fallback icon for text
                                Image(systemName: "doc.text.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(8)
                                    .background(Color.black.opacity(0.2))
                            }
                        }
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        
                        // Right: Content styling
                        VStack(alignment: .leading, spacing: 2) {
                            if item.type == .text {
                                let lines = item.previewText.split(separator: "\n", maxSplits: 1).map(String.init)
                                if let firstLine = lines.first {
                                    Text(firstLine)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }
                                if lines.count > 1 {
                                    Text(lines[1])
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            } else {
                                Text(item.previewText)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                }
            }
            // Add padding to content to avoid overlap with close button if needed,
            // but close button is small and overlaps gracefully.
            
            // Close Button (Top Left)
            Button(action: {
                onClose?()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 16, height: 16)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(4)
            .offset(x: -2, y: -2) // Slight offset closer to corner
        }
        .frame(width: 240, height: 80)
        // Border
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        // Click to Paste
        .contentShape(Rectangle()) // Ensure the whole area is tappable
        .onTapGesture {
            onPaste?()
        }
    }
}

// Preview provider for testing
#if DEBUG
struct FloatingClipView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FloatingClipView(item: ClipboardItem.text("Header Line\nBody line content implementation."))
                .background(Color.black)
                .previewDisplayName("Text Item")
            
            FloatingClipView(item: ClipboardItem.text("#007AFF"))
                .background(Color.black)
                .previewDisplayName("Color Item")
        }
    }
}
#endif
