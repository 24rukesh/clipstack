# ClipStack - macOS Clipboard Manager

## Overview

ClipStack is a lightweight, background utility application for macOS that extends the native clipboard functionality by capturing and storing a history of copied items.

## Features Implemented

1. **Clipboard History**: Captures and stores text and images copied to the clipboard
2. **Global Shortcut**: Access clipboard history with `Cmd+Shift+V`
3. **Menu Bar App**: Runs in the background without taking Dock space
4. **Search & Filter**: Quickly find items in your clipboard history
5. **Data Persistence**: Clipboard history persists across restarts using Core Data

## Technical Implementation

### Architecture
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture Pattern**: MVVM (Model-View-ViewModel)
- **Persistence**: Core Data
- **System Integration**: 
  - `NSPasteboard` for clipboard monitoring
  - `CGEvent.tapCreate` for global keyboard shortcut
  - `LSUIElement` for menu bar agent behavior

### Key Components

1. **AppDelegate**: Central coordinator managing menu bar, clipboard monitoring, and global shortcuts
2. **ClipboardMonitor**: Monitors system clipboard and manages history
3. **GlobalShortcutMonitor**: Listens for Cmd+Shift+V globally
4. **CoreDataManager**: Manages Core Data persistence
5. **UI Components**: 
   - ClipboardHistoryView (main popover)
   - ClipboardItemView (individual items)

## Project Structure

```
ClipStack/
├── Package.swift
├── Sources/
│   ├── ClipStack/
│   │   ├── AppDelegate.swift
│   │   ├── ClipboardItem.swift
│   │   ├── ClipboardItemEntity+CoreDataProperties.swift
│   │   ├── ClipboardItemView.swift
│   │   ├── ClipboardMonitor.swift
│   │   ├── ClipStackDataModel.xcdatamodeld
│   │   ├── ClipStackMain.swift
│   │   ├── CoreDataManager.swift
│   │   ├── GlobalShortcutMonitor.swift
│   │   ├── Info.plist
│   │   └── ClipboardHistoryView.swift
```

## Building the Application

1. Navigate to the project directory
2. Run `swift build`
3. The built application will be in the `.build/debug/` directory

## Deployment

To create a distributable app bundle:
1. Build the project with `swift build`
2. Create an app bundle structure
3. Copy the executable to the bundle
4. Include necessary resources (Info.plist, Core Data model)
5. Sign the application for distribution

## Requirements

- macOS 11.0 or later
- Xcode 13.0 or later (for development)

## Future Enhancements

1. Add support for rich text and file clipboard items
2. Implement cloud synchronization across devices
3. Add customizable keyboard shortcuts
4. Include clipboard item preview thumbnails
5. Add expiration policies for old clipboard items