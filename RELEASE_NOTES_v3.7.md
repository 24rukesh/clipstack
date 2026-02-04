# ClipStack v3.7 - Permission Persistence & Auto-Cleanup Release

## 🎯 Major Improvements

### ✅ Permission Persistence Fix
**Problem Solved**: No more repeated permission prompts during app upgrades!

**What Changed**:
- **Smart Retry Logic**: Checks permissions 3-5 times with delays, waiting for macOS TCC database to sync
- **Permission Memory**: Remembers when permissions were granted, distinguishes first-time vs lost permissions
- **Better Error Messages**: Clear guidance for different permission scenarios
- **Graceful Shutdown**: Proper app lifecycle during upgrades prevents TCC conflicts

### ✅ Auto-Cleanup PKG Installer
**Problem Solved**: Clean upgrades without file conflicts!

**What Changed**:
- **Pre-Install Script**: Automatically removes old ClipStack versions before installing new one
- **No Manual Uninstall**: Just run the PKG installer - it handles cleanup automatically
- **Clean State**: Each install starts fresh, preventing permission and state conflicts

### ✅ Code Quality Improvements
- Fixed 2 deprecation warnings (`popUpMenu`, `NSImage` availability)
- Removed dead commented code
- Created centralized `PasteUtility.swift` for permission handling
- Enhanced logging for debugging

---

## 📦 Installation

### Fresh Install
1. Download `ClipStack.pkg`
2. Double-click to install
3. Grant accessibility permissions when prompted
4. Done!

### Upgrade from Previous Version
1. Download `ClipStack.pkg`
2. Double-click to install
3. Installer automatically removes old version
4. No permission re-prompts needed!

**Alternative**: Download `ClipStack.app.zip`, unzip, and drag to Applications

---

## 🔧 For Developers

### New Tools
- **`upgrade.sh`** - Automated upgrade with cleanup
- **`uninstall.sh`** - Complete removal script
- **`Uninstall ClipStack.app`** - GUI uninstaller (no Terminal)
- **`quick-fix.sh`** - Temporary permission sync workaround

### What's Included
```
dist/
├── ClipStack.pkg        ← Installer with auto-cleanup
└── ClipStack.app.zip    ← Manual installation
```

---

## 🐛 Bug Fixes

- **Fixed**: Permission prompts on every upgrade even when granted
- **Fixed**: Paste not working immediately after permission grant (TCC sync delay)
- **Fixed**: Deprecated API warnings in Xcode
- **Fixed**: File conflicts during manual upgrades

---

## 🚀 Technical Details

### Permission Check Enhancement
```swift
// Old: Single check, fails immediately
guard AXIsProcessTrusted() else { ... }

// New: Retry with delays for TCC sync
checkAccessibilityPermissions(retryCount: 5, delay: 0.5)
```

### PKG Pre-Install Script
Automatically executes before installation:
1. Kills running ClipStack process
2. Removes `/Applications/ClipStack.app`
3. Clears quarantine attributes
4. Syncs filesystem
5. Proceeds with clean installation

### Upgrade Flow
```
1. Graceful quit (AppleScript)
2. Force kill if needed
3. Wait for TCC sync (1s)
4. Remove old version
5. Build & package new version
6. Install to /Applications
7. Remove quarantine attributes
8. Clear extended attributes
9. Launch new version
```

---

## 📊 Changes Summary

**Files Changed**: 18 files  
**Additions**: +1,016 lines  
**Deletions**: -111 lines

### Key Files
- `Sources/PasteUtility.swift` - New permission handling utility
- `scripts/preinstall` - PKG cleanup script
- `upgrade.sh` - Automated upgrade workflow
- `uninstall.sh` - Complete removal script
- `build.sh` - Updated PKG build with cleanup

---

## 🔗 Commits

- `82ba245` - Add auto-cleanup to PKG installer
- `223b724` - Fix: Implement permission persistence for app upgrades

---

## ⚠️ Known Issues

**Remaining Deprecation**:
- 1 AppKit framework deprecation (non-critical, in Apple's code)

**Future Work**:
- Code signing with Developer ID
- Notarization for distribution
- Auto-update mechanism
- Image thumbnails in clipboard history

---

## 📝 Upgrade Notes

### From v3.6 or Earlier
**Recommended**: Use the PKG installer for cleanest upgrade.

**If using manual install**:
1. Run `./upgrade.sh` from project directory, OR
2. Use the `Uninstall ClipStack.app` to remove old version first
3. Then install new version

### First Time Users
No special requirements - just install and grant accessibility permissions when prompted.

---

## 🙏 Acknowledgments

This release addresses the #1 user complaint: repeated permission prompts during upgrades. The fix implements proper TCC synchronization handling and automated cleanup for conflict-free upgrades.

---

## 📄 License

MIT License - See LICENSE file for details
