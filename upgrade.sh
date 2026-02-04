#!/bin/bash
# ClipStack Upgrade Script
# Performs clean upgrade: uninstall old version, install new version

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔄 ClipStack Upgrade Process"
echo "============================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Step 1: Graceful shutdown
echo "${BLUE}Step 1: Stopping ClipStack...${NC}"

# Try graceful quit first
osascript -e 'tell application "ClipStack" to quit' 2>/dev/null && echo "   ${GREEN}✓${NC} Graceful quit sent" || echo "   - App not running or already quit"
sleep 2

# Force kill if still running
pkill ClipStack 2>/dev/null && echo "   ${GREEN}✓${NC} Force stopped" || echo "   - No process to kill"

# Wait for TCC database to sync
echo "   Waiting for system sync..."
sleep 1
echo ""

# Step 2: Clean removal
echo "${BLUE}Step 2: Removing old version...${NC}"
sudo rm -rf /Applications/ClipStack.app 2>/dev/null && echo "   ${GREEN}✓${NC} Removed from /Applications" || echo "   - Not found in /Applications"
echo ""

# Step 3: Build new version
echo "${BLUE}Step 3: Building fresh version...${NC}"
cd "$SCRIPT_DIR"

# Clean build artifacts
rm -rf .build build dist
echo "   ${GREEN}✓${NC} Cleaned old build artifacts"

# Build release version
echo "   Building release binary..."
swift build -c release

if [ $? -eq 0 ]; then
    echo "   ${GREEN}✓${NC} Release build complete"
else
    echo "   ${RED}✗${NC} Build failed!"
    exit 1
fi

# Step 3: Package application
echo "   Packaging application..."
bash "$SCRIPT_DIR/build.sh"

if [ ! -d "build/ClipStack.app" ]; then
    echo "   ${RED}✗${NC} Build failed - ClipStack.app not found"
    exit 1
fi

echo "   ${GREEN}✓${NC} Application packaged"
echo ""

# Step 5: Install new version
echo "${BLUE}Step 5: Installing new version...${NC}"
sudo rm -rf /Applications/ClipStack.app 2>/dev/null || true
sudo cp -R build/ClipStack.app /Applications/
echo "   ${GREEN}✓${NC} Copied to /Applications/ClipStack.app"

# Remove quarantine attributes that can confuse TCC
sudo xattr -rd com.apple.quarantine /Applications/ClipStack.app 2>/dev/null && echo "   ${GREEN}✓${NC} Removed quarantine attribute" || echo "   - No quarantine to remove"

# Clear extended attributes
sudo xattr -c /Applications/ClipStack.app 2>/dev/null && echo "   ${GREEN}✓${NC} Cleared extended attributes" || true

# Wait for filesystem and TCC to sync
sleep 1
echo ""

# Step 6: Launch and verify
echo "${BLUE}Step 6: Launching ClipStack...${NC}"
open /Applications/ClipStack.app
sleep 2

# Check if running
if pgrep -x "ClipStack" > /dev/null; then
    PID=$(pgrep -x "ClipStack")
    echo "   ${GREEN}✓${NC} ClipStack is running (PID: $PID)"
else
    echo "   ${YELLOW}!${NC} ClipStack not running - please launch manually"
fi

echo ""
echo "${GREEN}✅ Upgrade complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Grant accessibility permissions when prompted"
echo "  2. Set up global shortcut in preferences"
echo "  3. Test copy/paste functionality"
echo ""
