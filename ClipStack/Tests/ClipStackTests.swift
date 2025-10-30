import XCTest
@testable import ClipStack

class ClipStackTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testClipboardItemCreation() throws {
        let item = ClipboardItem.text("Hello, World!")
        
        XCTAssertEqual(item.type, .text)
        XCTAssertEqual(item.content, "Hello, World!")
        XCTAssertNotNil(item.timestamp)
        XCTAssertFalse(item.id.uuidString.isEmpty)
    }
    
    func testImageItemCreation() throws {
        // Create a simple test image
        let image = NSImage(size: NSSize(width: 100, height: 100))
        let item = ClipboardItem.image(image)
        
        XCTAssertEqual(item.type, .image)
        XCTAssertNil(item.content)
        XCTAssertNotNil(item.timestamp)
        XCTAssertFalse(item.id.uuidString.isEmpty)
    }
    
    func testPreviewTextForTextItems() throws {
        let shortText = "Short text"
        let shortItem = ClipboardItem.text(shortText)
        XCTAssertEqual(shortItem.previewText, shortText)
        
        let longText = String(repeating: "A", count: 150)
        let longItem = ClipboardItem.text(longText)
        XCTAssertTrue(longItem.previewText.hasSuffix("..."))
        XCTAssertEqual(longItem.previewText.count, 103) // 100 chars + "..."
    }
    
    func testPreviewTextForImageItems() throws {
        let image = NSImage(size: NSSize(width: 100, height: 100))
        let item = ClipboardItem.image(image)
        XCTAssertEqual(item.previewText, "Image")
    }
    
    func testFormattedTimestamp() throws {
        let item = ClipboardItem.text("Test")
        XCTAssertNotNil(item.formattedTimestamp)
        XCTAssertFalse(item.formattedTimestamp.isEmpty)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
            _ = ClipboardItem.text("Performance test")
        }
    }
}