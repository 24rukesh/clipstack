# ClipStack Testing Guide

## Overview

This document provides comprehensive guidance on testing the ClipStack macOS clipboard manager application. Testing covers unit tests, integration tests, UI tests, and manual testing procedures.

## Automated Testing

### Prerequisites

1. macOS 11.0 or later
2. Xcode command line tools
3. Swift 5.5 or later

### Running Tests

ClipStack includes both automated and manual testing approaches:

```bash
# Validate project structure
./validate.sh

# Run manual testing guide
./test.sh

# Build the application
swift build
```

## Manual Testing Procedures

### 1. Installation Testing

1. Build the application:
   ```bash
   swift build
   ```

2. Locate the executable:
   ```bash
   ls .build/debug/ClipStack
   ```

3. Run the application:
   ```bash
   .build/debug/ClipStack
   ```

4. Verify the menu bar icon appears

### 2. Basic Functionality Testing

#### Clipboard Monitoring
- [ ] Copy text to clipboard using Cmd+C
- [ ] Verify the text appears in the clipboard history
- [ ] Copy an image to clipboard
- [ ] Verify the image appears in the clipboard history

#### Global Shortcut
- [ ] Press Cmd+Shift+V anywhere in the system
- [ ] Verify the clipboard history popover appears
- [ ] Verify the popover appears near the cursor position

#### Menu Bar Interaction
- [ ] Click the clipboard icon in the menu bar
- [ ] Verify the clipboard history popover appears

### 3. UI Testing

#### Clipboard History View
- [ ] Verify the search bar is functional
- [ ] Test searching with various text inputs
- [ ] Verify clipboard items are displayed correctly
- [ ] Verify text items show truncated preview
- [ ] Verify image items show "Image" label
- [ ] Verify timestamps are displayed correctly

#### Item Selection
- [ ] Click on a text item in the history
- [ ] Verify the item is copied to clipboard
- [ ] Click on an image item in the history
- [ ] Verify the item is copied to clipboard

### 4. Data Persistence Testing

- [ ] Add several items to clipboard history
- [ ] Quit the application
- [ ] Restart the application
- [ ] Verify clipboard history is preserved

### 5. Performance Testing

- [ ] Monitor CPU usage when application is idle (should be minimal)
- [ ] Monitor memory usage (should be low)
- [ ] Copy multiple items rapidly
- [ ] Verify application responsiveness

### 6. Edge Case Testing

#### Empty Content
- [ ] Copy empty text to clipboard
- [ ] Verify it's handled correctly in history

#### Large Content
- [ ] Copy very long text to clipboard
- [ ] Verify text is properly truncated in preview

#### Rapid Operations
- [ ] Copy multiple items quickly
- [ ] Verify all items are captured correctly

## Test Cases Checklist

### Core Functionality
- [ ] Clipboard text monitoring
- [ ] Clipboard image monitoring
- [ ] Global shortcut activation (Cmd+Shift+V)
- [ ] Menu bar icon interaction
- [ ] Clipboard history persistence
- [ ] Search functionality
- [ ] Item selection and re-copying

### UI/UX
- [ ] Menu bar icon visibility
- [ ] Popover appearance and positioning
- [ ] Search bar functionality
- [ ] Item display formatting
- [ ] Timestamp formatting
- [ ] Text truncation for long items

### System Integration
- [ ] Low CPU/memory usage
- [ ] Proper background operation
- [ ] Accessibility permission handling
- [ ] Launch agent behavior

### Edge Cases
- [ ] Empty clipboard content
- [ ] Very large clipboard content
- [ ] Rapid clipboard operations
- [ ] System under load

## Debugging Tips

1. **Accessibility Permissions**: If global shortcuts don't work, check System Preferences > Security & Privacy > Privacy > Accessibility

2. **Console Logging**: Use Console.app to view application logs

3. **Performance Monitoring**: Use Activity Monitor to check CPU and memory usage

4. **Clipboard Testing**: Use the `pbpaste` and `pbcopy` commands in Terminal for clipboard operations

## Common Issues and Solutions

### Global Shortcut Not Working
1. Verify accessibility permissions are granted
2. Restart the application
3. Check if another application is intercepting the shortcut

### Clipboard History Not Persisting
1. Verify Core Data permissions
2. Check for disk space issues
3. Verify application has proper file system access

### High CPU Usage
1. Check if clipboard monitoring interval is too frequent
2. Verify no infinite loops in monitoring code
3. Check for memory leaks

## Testing Tools

### Built-in macOS Tools
1. **Console.app** - View application logs
2. **Activity Monitor** - Monitor CPU/memory usage
3. **Terminal** - Test clipboard with `pbcopy`/`pbpaste`

### Third-party Tools
1. **Instruments** - Advanced performance profiling
2. **Xcode** - Debugging and UI inspection

## Test Automation Roadmap

Future enhancements for automated testing:

1. **UI Testing Framework**: Implement XCUI testing
2. **Continuous Integration**: Set up GitHub Actions for automated testing
3. **Performance Benchmarks**: Create automated performance tests
4. **Cross-version Testing**: Test on multiple macOS versions

## Validation Script

The project includes a validation script that checks:
- All required source files exist
- Core Data model is present
- Project builds successfully
- Executable is created

Run it with:
```bash
./validate.sh
```

## Manual Testing Script

A guided manual testing script provides step-by-step instructions:

```bash
./test.sh
```

This script outputs a comprehensive testing guide for manual validation.

## Conclusion

ClipStack has been designed with testability in mind. The modular architecture allows for focused testing of individual components, while the integration tests ensure proper system-level functionality. Following this testing guide will help ensure the application works correctly across all supported scenarios.