# ClipStack – Free, Open‑Source Clipboard Manager for macOS

Fast, private, and simple clipboard history that lives in your menu bar. Search, copy, and manage your recent clips without leaving the keyboard. Built with Swift, free and open-source.

---

<p align="center">
  <img alt="macOS" src="https://img.shields.io/badge/macOS-11.0%2B-blue?logo=apple">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5-orange?logo=swift">
  <img alt="GitHub All Releases" src="https://img.shields.io/github/downloads/24rukesh/clipstack/total?label=Downloads&logo=github">
  </p>

---

## 🚀 Download & Quick Start

### 1. Download
[**➡️ Download the latest `ClipStack.pkg` from Releases**](https://github.com/24rukesh/clipstack/releases/latest/download/ClipStack.pkg)

### 2. Install
Open the installer (`ClipStack.pkg`) and follow the prompts. The app is installed to `/Applications`.

### 3. First Run
⚠️ **If macOS warns about opening the installer:**

> **Method 1 (Easiest):**
> In Finder, **Right‑click** `ClipStack.pkg` → select **Open** → click **Open** in the dialog.
>
> **Method 2 (Terminal):**
> `xattr -dr com.apple.quarantine /Applications/ClipStack.app`

### 4. Onboarding
* **Enable Notifications** (optional) for "Saved" and "Copied" alerts.
* **Enable Start at Login** (macOS 13+) so ClipStack launches automatically.

## ✨ Features

* ✅ **Menu Bar Native:** Lives in your menu bar, always one click away.
* ✅ **Instant Search:** Find any text clip instantly.
* ✅ **One-Click Copy:** Simple "Copy" button with "Copied" confirmation.
* ✅ **Notifications:** Optional "Saved" and "Copied" alerts.
* ✅ **Start at Login:** Runs automatically (macOS 13+).
* ✅ **Private by Design:** All data is stored 100% locally.

## ⚙️ How to Use

* **Open:** Click the clipboard icon in your menu bar.
* **Search:** Type in the search field to filter.
* **Copy:** Click the "Copy" button below any clip. The popover will close.
* **Clear:** Click "Clear All" in the header to wipe the history.
* **Settings:** Right-click the menu bar icon (or click the gear) to open Preferences.

## 🔒 Privacy First

ClipStack is built to be private. Period.
* All clipboard data stays on your device.
* Data is saved via Core Data in the app’s secure sandbox.
* **Zero** network calls.
* **Zero** analytics or trackers.
* **Zero** ads.

## 👨‍💻 Build From Source

Requirements: **macOS 11+** and Swift toolchain.

```bash
git clone [https://github.com/24rukesh/clipstack.git](https://github.com/24rukesh/clipstack.git)
cd clipstack
bash build.sh
open build/ClipStack.app
````

The build script will output:

  * `build/ClipStack.app` (Runnable app)
  * `dist/ClipStack.app.zip` (Zipped app bundle)
  * `dist/ClipStack.pkg` (Installer that places the app in `/Applications`)

### Optional Signing (for Distribution)

```bash
export SIGN_ID="Developer ID Application: Your Name (TEAMID)"
export NOTARY_PROFILE="AC_PASSWORD" # notarytool keychain profile
bash build.sh
```

## 🗺️ Roadmap

  * ⬜️ Optional global hotkey (configurable)
  * ⬜️ Image thumbnail previews in history
  * ⬜️ Advanced search and filters
  * ⬜️ Export/import clipboard history

## ❤️ Contributing & Support

### Contributing

Issues and Pull Requests are welcome\! Please describe your use case clearly and keep changes small and focused.

### Support

If something doesn’t work, please check the following:

  * Ensure the app is in `/Applications` (not in your Downloads folder).
  * If macOS blocks opening, use the **Right‑click → Open** method.
  * Try rebuilding from the source using the steps above.

## 💡 Why ClipStack?

  * **Lightweight:** A focused tool that respects your workflow.
  * **Open-Source:** Fully transparent. Audit, extend, or customize it.
  * **Native:** Built with Swift, SwiftUI, and Core Data for the best macOS experience.

-----

Enjoy a faster, simpler clipboard on macOS
