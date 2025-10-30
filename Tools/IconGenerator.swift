import AppKit

struct IconGenerator {
    static func makeSymbolImage(size: CGFloat) -> NSImage? {
        guard let base = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil) else {
            return nil
        }
        let img = NSImage(size: NSSize(width: size, height: size))
        img.lockFocus()
        NSColor.clear.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()

        // Draw a rounded rect background
        let corner: CGFloat = size * 0.18
        let bgRect = NSRect(x: 0, y: 0, width: size, height: size)
        let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: corner, yRadius: corner)
        NSColor.white.setFill()
        bgPath.fill()

        // Draw the symbol centered
        let symbolSize = size * 0.6
        let dest = NSRect(x: (size - symbolSize)/2, y: (size - symbolSize)/2, width: symbolSize, height: symbolSize)
        base.draw(in: dest, from: .zero, operation: .sourceOver, fraction: 1.0)
        img.unlockFocus()
        return img
    }

    static func writePNG(_ image: NSImage, to url: URL) throws {
        guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "IconGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode PNG"])
        }
        try png.write(to: url)
    }

    static func run() {
        let fm = FileManager.default
        let iconset = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("build/AppIcon.iconset")
        try? fm.removeItem(at: iconset)
        try? fm.createDirectory(at: iconset, withIntermediateDirectories: true, attributes: nil)

        let sizes: [(name: String, size: CGFloat)] = [
            ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
            ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
            ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
            ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
            ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024),
        ]
        for s in sizes {
            if let img = makeSymbolImage(size: s.size) {
                let url = iconset.appendingPathComponent(s.name)
                try? writePNG(img, to: url)
            }
        }
    }
}

IconGenerator.run()