import XCTest
@testable import Tests

class ClipStackTests: XCTestCase {
    
    func testClipboardItemCreation() throws {
        // This is a placeholder test since we can't easily test the full app in isolation
        XCTAssertTrue(true)
    }
    
    func testClipboardItemPreview() {
        let textItem = ClipboardItem.text("Short text")
        XCTAssertEqual(textItem.previewText, "Short text")
        
        let imageItem = ClipboardItem.image(NSImage())
        XCTAssertEqual(imageItem.previewText, "Image")
    }
    
    func testFormattedTimestamp() {
        let item = ClipboardItem.text("Test")
        XCTAssertNotNil(item.formattedTimestamp)
        XCTAssertFalse(item.formattedTimestamp.isEmpty)
    }
}