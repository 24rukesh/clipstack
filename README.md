# ClipStack – Free, Open‑Source Clipboard Manager for macOS

Fast, private, and simple clipboard history that lives in your menu bar. Search, copy, and manage your recent clips without leaving the keyboard — built with Swift, free and open‑source.

## Download

- Download DMG: [ClipStack.dmg](https://github.com/24rukesh/clipstack/blob/main/dist/ClipStack.dmg)
- If macOS warns that the app can’t be opened:
  - Right‑click `ClipStack.app` → Open → Open
  - Or remove quarantine: `xattr -dr com.apple.quarantine /Applications/ClipStack.app`

## Highlights

- Menu bar clipboard history: always at hand
- Search: find text clips instantly
- One‑click copy: “Copy” button shows “Copied” with a short delay
- Notifications: “Saved” and “Copied” confirmation (opt‑in)
- Start at Login (macOS 13+): enable in Preferences or onboarding
- Private by design: all data stored locally via Core Data (sandboxed)

## Quick Start

1. Download the DMG and drag `ClipStack.app` to `/Applications`.
2. Launch ClipStack:
   - Find the clipboard icon in the macOS menu bar.
   - Left‑click: open the history popover.
   - Right‑click: menu with Preferences and Quit.
3. First run:
   - Enable Notifications (optional) for “Saved/Copied” alerts.
   - Enable Start at Login (macOS 13+) so ClipStack launches after login.

## Using ClipStack

- Search: type in the header search field to filter clips.
- Copy: click “Copy” (button below the text); the button changes to “Copied”, then the popover closes.
- Clear history: click “Clear All” in the header.
- Preferences: click the gear icon or open from the menu; toggle Start at Login.
- Auto‑scroll: new clips appear at the top; the list scrolls to top when new items arrive or search changes.

## Permissions

- Notifications: requested on first run for banners; optional.
- Accessibility: not required (no event tap shortcut in this build).

## Build From Source

Requirements: macOS 11+, Swift toolchain.

```bash
git clone https://github.com/24rukesh/clipstack.git
cd clipstack
bash build.sh
open build/ClipStack.app
```

Build script outputs:
- `build/ClipStack.app` – runnable app bundle
- `dist/ClipStack.dmg` – shareable disk image

Optional signing/notarization (for distribution):

```bash
export SIGN_ID="Developer ID Application: Your Name (TEAMID)"
export NOTARY_PROFILE="AC_PASSWORD" # notarytool keychain profile
bash build.sh
```

## Privacy

- All clipboard data stays on your device, saved via Core Data in the app’s sandbox.
- No network calls, no analytics, no ads.

## Roadmap

- Optional global shortcut (configurable) — off by default
- Image thumbnails in history
- Advanced search and filters
- Export/import clipboard history

## Contributing

Issues and PRs are welcome. Please describe your use case clearly and keep changes small and focused.

## Why ClipStack?

- Lightweight: a focused menu bar tool that respects your workflow
- Open‑source: audit, extend, or customize
- Built for macOS: Swift, SwiftUI, Core Data

## Support

- If something doesn’t work:
  - Ensure the app is in `/Applications` (not in Downloads)
  - If macOS blocks opening, use the right‑click → Open flow
  - Rebuild: `bash build.sh` and run `open build/ClipStack.app`

Enjoy a faster, simpler clipboard on macOS.