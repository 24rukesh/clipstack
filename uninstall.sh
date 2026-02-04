#!/bin/bash
# ClipStack Complete Uninstall Script
# Removes all traces of ClipStack from the system

set -e

echo "🗑️  ClipStack Complete Uninstall"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Kill running process
echo "1. Stopping ClipStack..."
pkill -9 ClipStack 2>/dev/null && echo "   ${GREEN}✓${NC} Killed running process" || echo "   - No running process found"

# Remove application bundle
echo ""
echo "2. Removing application bundles..."
if [ -d "/Applications/ClipStack.app" ]; then
    sudo rm -rf /Applications/ClipStack.app
    echo "   ${GREEN}✓${NC} Removed from /Applications"
else
    echo "   - Not found in /Applications"
fi

if [ -d "$HOME/Applications/ClipStack.app" ]; then
    rm -rf "$HOME/Applications/ClipStack.app"
    echo "   ${GREEN}✓${NC} Removed from ~/Applications"
else
    echo "   - Not found in ~/Applications"
fi

# Remove preferences
echo ""
echo "3. Removing preferences..."
rm -rf "$HOME/Library/Preferences/com.clipstack.app.plist" 2>/dev/null && echo "   ${GREEN}✓${NC} Removed preference file" || echo "   - No preference file found"
defaults delete com.clipstack.app 2>/dev/null && echo "   ${GREEN}✓${NC} Cleared defaults" || true

# Remove application support
echo ""
echo "4. Removing application data..."
if [ -d "$HOME/Library/Application Support/ClipStack" ]; then
    rm -rf "$HOME/Library/Application Support/ClipStack"
    echo "   ${GREEN}✓${NC} Removed application support data"
else
    echo "   - No application support data found"
fi

# Remove caches
echo ""
echo "5. Removing caches..."
rm -rf "$HOME/Library/Caches/com.clipstack.app" 2>/dev/null && echo "   ${GREEN}✓${NC} Removed cache directory" || echo "   - No cache directory found"

# Remove saved state
echo ""
echo "6. Removing saved application state..."
rm -rf "$HOME/Library/Saved Application State/com.clipstack.app.savedState" 2>/dev/null && echo "   ${GREEN}✓${NC} Removed saved state" || echo "   - No saved state found"

# Remove containers (if sandboxed)
echo ""
echo "7. Removing containers..."
rm -rf "$HOME/Library/Containers/com.clipstack.app" 2>/dev/null && echo "   ${GREEN}✓${NC} Removed container" || echo "   - No container found"

# Remove group containers
rm -rf "$HOME/Library/Group Containers/com.clipstack."* 2>/dev/null && echo "   ${GREEN}✓${NC} Removed group containers" || echo "   - No group containers found"

# Reset TCC permissions (requires user to re-grant)
echo ""
echo "8. Resetting permissions..."
tccutil reset Accessibility com.clipstack.app 2>/dev/null && echo "   ${GREEN}✓${NC} Reset accessibility permissions" || echo "   ${YELLOW}!${NC} Could not reset TCC (may require System Settings)"

# Optional: Remove launch agent (if exists)
echo ""
echo "9. Checking for launch agents..."
if [ -f "$HOME/Library/LaunchAgents/com.clipstack.app.plist" ]; then
    launchctl unload "$HOME/Library/LaunchAgents/com.clipstack.app.plist" 2>/dev/null || true
    rm "$HOME/Library/LaunchAgents/com.clipstack.app.plist"
    echo "   ${GREEN}✓${NC} Removed launch agent"
else
    echo "   - No launch agent found"
fi

echo ""
echo "${GREEN}✅ Complete uninstall finished!${NC}"
echo ""
echo "Note: You may need to manually remove ClipStack from:"
echo "  • System Settings → Privacy & Security → Accessibility"
echo "  • System Settings → General → Login Items"
echo ""
