# ClipStack Uninstaller Guide

## Three Ways to Uninstall

### Method 1: User-Friendly App (Recommended for Users) 🖱️

**Use the standalone uninstaller app:**

1. Double-click `Uninstall ClipStack.app`
2. Click "Uninstall ClipStack"
3. Enter your admin password
4. Done!

**Features:**
- ✅ No Terminal required
- ✅ Guided dialogs
- ✅ Single password prompt
- ✅ Complete removal

**Distribution:**
- Include `Uninstall ClipStack.app` in the distributed `.zip` or `.dmg`
- Users can run it anytime to cleanly remove ClipStack

---

### Method 2: Terminal Script (For Developers) 💻

**Use the bash script:**

```bash
./uninstall.sh
```

**When to use:**
- During development
- Automated workflows
- When scripting is preferred

---

### Method 3: Manual Removal (Advanced) ⚙️

If the above methods fail, manually remove these:

```bash
# Kill process
pkill -9 ClipStack

# Remove app bundle
sudo rm -rf /Applications/ClipStack.app
rm -rf ~/Applications/ClipStack.app

# Remove data
rm -rf ~/Library/Preferences/com.clipstack.app.plist
rm -rf ~/Library/Application\ Support/ClipStack
rm -rf ~/Library/Caches/com.clipstack.app
rm -rf ~/Library/Saved\ Application\ State/com.clipstack.app.savedState

# Reset permissions
tccutil reset Accessibility com.clipstack.app
```

---

## What Gets Removed

| Item | Location | Size |
|------|----------|------|
| Application | `/Applications/ClipStack.app` | ~5 MB |
| Preferences | `~/Library/Preferences/com.clipstack.app.plist` | ~1 KB |
| Clipboard Data | `~/Library/Application Support/ClipStack` | Varies |
| Cache | `~/Library/Caches/com.clipstack.app` | ~100 KB |
| Saved State | `~/Library/Saved Application State/...` | ~50 KB |
| TCC Permissions | System database | N/A |

---

## Manual Cleanup (After Uninstall)

Some items require manual removal from System Settings:

### 1. Accessibility Permissions
1. Open **System Settings**
2. Go to **Privacy & Security** → **Accessibility**
3. Find **ClipStack** in the list
4. Click **ⓘ** → **Remove** (or toggle off)

### 2. Login Items
1. Open **System Settings**
2. Go to **General** → **Login Items**
3. Find **ClipStack**
4. Click **−** to remove

---

## Troubleshooting

### "Operation not permitted"

**Cause:** Uninstaller doesn't have Full Disk Access.

**Fix:** Grant temporary FDA:
1. System Settings → Privacy & Security → Full Disk Access
2. Add the uninstaller app
3. Run uninstall
4. Remove uninstaller from FDA list

### Uninstaller Won't Launch

**Cause:** App not signed or quarantined.

**Fix:**
```bash
xattr -d com.apple.quarantine "Uninstall ClipStack.app"
```

### ClipStack Still in Accessibility List

**Cause:** TCC reset requires restart.

**Fix:** Reboot your Mac, then check again.

---

## Creating Distribution Package

Include uninstaller in your distribution:

### Option 1: ZIP Archive
```bash
# Create distributable zip with uninstaller
zip -r ClipStack-v3.6.zip \
    "ClipStack.app" \
    "Uninstall ClipStack.app" \
    "README.md"
```

### Option 2: DMG with Uninstaller
```bash
# Create DMG with both install and uninstall
hdiutil create -volname "ClipStack" -srcfolder dist-temp -ov -format UDZO ClipStack.dmg
```

DMG should contain:
```
ClipStack.dmg
├── ClipStack.app
├── Uninstall ClipStack.app
├── README.md
└── Applications (symlink)
```

---

## Best Practices

### For Users
- Always use the uninstaller app before reinstalling
- Restart Mac after uninstall if experiencing issues
- Check System Settings for leftover entries

### For Developers  
- Test uninstaller on clean macOS install
- Include uninstaller in all distribution packages
- Document uninstall process in README
- Provide support for manual removal

### For Distribution
- Sign the uninstaller app with same certificate as main app
- Notarize both apps together
- Test uninstaller on Gatekeeper-protected systems
