#!/bin/bash

# ClipStack Testing Script

echo "=== ClipStack Testing ==="
echo "Building application..."
swift build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful"

# Run manual tests
echo ""
echo "=== Manual Testing Guide ==="
echo "To test ClipStack, perform the following steps:"
echo ""
echo "1. Run the application:"
echo "   .build/debug/ClipStack"
echo ""
echo "2. Grant accessibility permissions when prompted"
echo ""
echo "3. Test clipboard functionality:"
echo "   - Copy some text to clipboard"
echo "   - Verify it appears in the history when you click the menu bar icon"
echo "   - Use Cmd+Shift+V to open the clipboard history"
echo "   - Click on a history item to copy it back to clipboard"
echo ""
echo "4. Test persistence:"
echo "   - Restart the application"
echo "   - Verify clipboard history is preserved"
echo ""
echo "5. Test UI elements:"
echo "   - Verify menu bar icon appears correctly"
echo "   - Verify popover displays correctly"
echo "   - Test search functionality with various text"
echo ""
echo "6. Test edge cases:"
echo "   - Copy empty text"
echo "   - Copy very long text"
echo "   - Copy multiple items quickly"
echo ""
echo "✅ Manual testing guide complete"