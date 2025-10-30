# ClipStack - macOS Clipboard Manager

ClipStack is a lightweight, background utility application for macOS that extends the native clipboard functionality by capturing and storing a history of copied items.

## Features

- **Clipboard History**: Captures and stores text and images copied to the clipboard
- **Global Shortcut**: Access clipboard history with `Cmd+Shift+V`
- **Menu Bar App**: Runs in the background without taking Dock space
- **Search & Filter**: Quickly find items in your clipboard history
- **Data Persistence**: Clipboard history persists across restarts

## Installation

1. Build the application using the provided build script:
   ```bash
   ./build.sh
   ```

2. Copy the generated `ClipStack.app` to your Applications folder

3. On first launch, you may need to grant accessibility permissions in System Preferences > Security & Privacy > Privacy > Accessibility

4. The application will automatically start on login

## Usage

- Click the clipboard icon in the menu bar to view clipboard history
- Use `Cmd+Shift+V` anywhere to quickly access clipboard history
- Click on any item in the history to copy it to your clipboard

## Development

This project is built with:
- Swift
- SwiftUI
- Core Data

### Building from Source

1. Clone the repository
2. Run `./build.sh` to build the application
3. The built application will be in the `build/` directory

## License

MIT License