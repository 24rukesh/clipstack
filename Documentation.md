# ClipStack Architecture

## Main Components

### 1. AppDelegate
The central coordinator of the application that manages:
- Menu bar status item
- Clipboard monitoring
- Global shortcut monitoring
- Core Data management

### 2. Clipboard Monitor
Responsible for monitoring the system clipboard using NSPasteboard and capturing new items when they are copied.

### 3. Global Shortcut Monitor
Uses CGEvent tap to listen for the Cmd+Shift+V keyboard shortcut globally across the system.

### 4. Core Data Manager
Manages the Core Data stack for persistent storage of clipboard history.

### 5. UI Components
- **Clipboard History View**: The main popover view showing the clipboard history
- **Clipboard Item View**: Individual items in the history list

## Data Flow

1. User copies text or images to clipboard
2. Clipboard Monitor detects changes via NSPasteboard
3. New items are added to the history and saved via Core Data
4. User activates the interface via menu bar click or Cmd+Shift+V
5. Clipboard History View displays items from the history
6. User selects an item to copy it back to the clipboard

## Key Features

- **Low Resource Usage**: Timer-based monitoring with 0.5 second intervals
- **Global Access**: System-wide keyboard shortcut
- **Persistent Storage**: Core Data for saving history between sessions
- **Native Integration**: Menu bar app with macOS design guidelines