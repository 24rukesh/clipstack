#!/bin/bash

# ClipStack Validation Script

echo "=== ClipStack Validation ==="

# Check if required files exist
echo "Checking required files..."

REQUIRED_FILES=(
    "Sources/ClipStack/AppDelegate.swift"
    "Sources/ClipStack/ClipboardItem.swift"
    "Sources/ClipStack/ClipboardMonitor.swift"
    "Sources/ClipStack/ClipboardHistoryView.swift"
    "Sources/ClipStack/ClipboardItemView.swift"
    "Sources/ClipStack/CoreDataManager.swift"
    "Sources/ClipStack/GlobalShortcutMonitor.swift"
    "Sources/ClipStack/ClipStackMain.swift"
    "Sources/ClipStack/Info.plist"
)

MISSING_FILES=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing file: $file"
        MISSING_FILES=1
    else
        echo "✅ Found: $file"
    fi
done

if [ $MISSING_FILES -ne 0 ]; then
    echo "❌ Some required files are missing"
    exit 1
fi

# Check if Core Data model exists
if [ ! -d "Sources/ClipStack/ClipStackDataModel.xcdatamodeld" ]; then
    echo "❌ Missing Core Data model"
    exit 1
else
    echo "✅ Core Data model found"
fi

# Build the project
echo ""
echo "Building project..."
swift build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful"

# Check if executable exists
if [ ! -f ".build/debug/ClipStack" ]; then
    echo "❌ Executable not found"
    exit 1
else
    echo "✅ Executable found"
fi

echo ""
echo "=== Validation Complete ==="
echo "✅ All checks passed! ClipStack is ready for testing."
echo ""
echo "To run the application:"
echo "  .build/debug/ClipStack"
echo ""
echo "To run manual tests, execute:"
echo "  ./test.sh"