#!/bin/bash
# Quick Permission Fix - Temporary workaround
# This restarts ClipStack to sync TCC permissions

echo "🔄 Quick Permission Fix"
echo "======================="
echo ""

# Kill ClipStack
echo "1. Stopping ClipStack..."
pkill -9 ClipStack 2>/dev/null && echo "   ✓ Stopped" || echo "   - Not running"

# Wait for TCC to recognize the permission change
echo "2. Waiting for system sync (3 seconds)..."
sleep 3

# Relaunch
echo "3. Relaunching ClipStack..."
open /Applications/ClipStack.app

sleep 2

# Check if running
if pgrep -x "ClipStack" > /dev/null; then
    echo "   ✓ ClipStack restarted"
    echo ""
    echo "✅ Try pasting now - it should work without prompts!"
else
    echo "   ✗ Failed to restart"
    echo ""
    echo "Please launch ClipStack manually from Applications"
fi

echo ""
echo "NOTE: This is a temporary fix."
echo "Run ./upgrade.sh to install the permanent fix."
