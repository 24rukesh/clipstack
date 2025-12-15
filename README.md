# ClipStack – Free, Open‑Source Clipboard Manager for macOS

**ClipStack** is a fast, private, and simple clipboard history manager that lives in your menu bar. Built with Swift and SwiftUI, it feels right at home on macOS.

<p align="center">
  <img alt="macOS" src="https://img.shields.io/badge/macOS-11.0%2B-blue?logo=apple">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5-orange?logo=swift">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green">
  <img alt="Downloads" src="https://img.shields.io/github/downloads/24rukesh/clipstack/total?label=Downloads&logo=github">
</p>

---

## 🚀 Download & Install

### Option 1: Installer (Recommended)
1.  **[Download the latest release](https://github.com/24rukesh/clipstack/releases/latest)**.
2.  Download `ClipStack.pkg` (Installer) or `ClipStack.app.zip` (Portable) from the Assets section.
3.  Open the installer and follow the prompts.
    > _Note: If macOS prevents opening the installer, **Right-click** the file and select **Open**._

---

## ✨ Features

*   **⚡️ Lightning Fast:** Native menu bar app offering instant access to your clipboard history.
*   **⌨️ Keyboard First:** Navigate history with arrow keys (`↑`, `↓`) and paste with `Enter`.
*   **🔍 Instant Search:** Filter your history in real-time to find exactly what you need.
*   **🎹 Configurable Hotkey:** Default `Cmd + Shift + V`. Customize it in Preferences to whatever fits your workflow.
*   **🖼️ Rich Content:** Supports text, code, and images.
*   **🚀 Auto-Start:** Optional "Start at Login" (macOS 13+).
*   **🔒 Private by Design:** 
    *   All data is stored locally using Core Data (sandboxed).
    *   **No** internet access.
    *   **No** analytics.
    *   **No** tracking.

## 🛠 Usage

1.  **Open:** Press `Cmd + Shift + V` (default) or click the menu bar icon.
2.  **Navigate:** Use `Up` / `Down` arrow keys to select a clip.
3.  **Paste:** Press `Enter` to copy the selected item to your clipboard and paste it immediately (if supported).
4.  **Search:** Just start typing! The list filters automatically.
5.  **Preferences:** Click the gear icon inside the app to toggle "Start at Login" or record a new Global Hotkey.

## 🏗️ Build from Source

Requirements: **macOS 11+** and Xcode / Swift toolchain.

```bash
# 1. Clone the repository
git clone https://github.com/24rukesh/clipstack.git
cd clipstack

# 2. Build the app
./build.sh

# 3. Run
open build/ClipStack.app
```

The build script will generate:
*   `build/ClipStack.app`: The runnable application.
*   `dist/ClipStack.app.zip`: A distinct release structure.
*   `dist/ClipStack.pkg`: An installer package.

## 🗺️ Roadmap

*   [x] Markdown / Rich text preview support
*   [x] Configurable Global Hotkey
*   [x] Keyboard Navigation
*   [ ] Image thumbnail previews in list
*   [ ] Favorites / Pinned clips
*   [ ] Cloud sync (Optional & Encrypted)

## 🤝 Contributing

Contributions are welcome!
1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
