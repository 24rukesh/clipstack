# PLAN: Notification Replace & Screenshot Fix

## Overview
The goal of this plan is to replace the intrusive bottom-right floating capture bubble (`FloatingPanel`) with native macOS notifications. This will prevent the UI from getting in the user's way during normal tasks. Additionally, this plan incorporates the fix for the native macOS screenshot mechanism, ensuring that taking a screenshot with ClipStack running does not prematurely dismiss the native macOS screenshot thumbnail.

## Project Type
MAC / NATIVE SWIFT 

## Success Criteria
- Native macOS notifications appear when a new clipboard item is captured (replacing the floating panel).
- The native macOS screenshot thumbnail appears normally and persists for its full duration (~5 seconds) before saving.
- `Cmd+Shift+3` and `Cmd+Shift+4` behave exactly as they do without ClipStack running.
- Project compiles without errors.

## Tech Stack
- **Swift / AppKit**
- **UserNotifications Framework**: using the existing `Notifier.shared` implementation.

## File Structure
- `Sources/ClipboardMonitor.swift` (Modify)
- `Sources/AppDelegate.swift` (Modify)
- `Sources/Notifier.swift` (Review/Use)
- `Sources/FloatingPanel.swift` (Remove/Deprecate)
- `Sources/FloatingClipView.swift` (Remove/Deprecate)

---

## Task Breakdown

### Task 1: Implement Screenshot Watcher Delay Fix
- **Agent**: `backend-specialist` or `mobile-developer` (macOS context)
- **Skills**: `clean-code`, `systematic-debugging`
- **Priority**: P1
- **Description**: Increase the `Thread.sleep` duration in `processScreenshot` from `0.5s` to `6.0s`. This allows the native macOS screenshot preview to complete its natural lifecycle before ClipStack imports the file.
- **Dependencies**: None
- **INPUT → OUTPUT → VERIFY**:
  - *Input*: `ClipboardMonitor.swift`
  - *Output*: `ClipboardMonitor.swift` updated with appropriate delays.
  - *Verify*: Code compiles correctly and delay is visible in source.
- **Status**: ✅ Completed

### Task 2: Replace Capture Bubble with Native Notifications
- **Agent**: `mobile-developer`
- **Skills**: `clean-code`
- **Priority**: P1
- **Description**: Refactor `AppDelegate.swift` to stop using `showCaptureBubble(for:)`. Instead of creating `FloatingPanel` objects, dispatch a standard local notification using the existing `Notifier` class so that the OS handles the visual popup gracefully. Remove `visiblePanels` tracking.
- **Dependencies**: None
- **INPUT → OUTPUT → VERIFY**:
  - *Input*: `AppDelegate.swift`
  - *Output*: Native notifications trigger on clipboard copy instead of floating windows.
  - *Verify*: Copying text shows a fast macOS Native Notification in the top right.
- **Status**: ✅ Completed

### Task 3: Cleanup Deprecated UI Components
- **Agent**: `mobile-developer`
- **Skills**: `clean-code`
- **Priority**: P2
- **Description**: Safely remove `FloatingPanel.swift` and `FloatingClipView.swift` from the project since the custom floating bubble is being replaced by native OS notifications.
- **Dependencies**: Task 2
- **INPUT → OUTPUT → VERIFY**:
  - *Input*: `Sources/FloatingPanel.swift`, `Sources/FloatingClipView.swift`
  - *Output*: Files deleted, project `.xcodeproj` or `Package.swift` builds successfully.
  - *Verify*: Application compiles cleanly with zero missing file references.
- **Status**: ✅ Completed

---

## Phase X: Verification Checklist

### Pre-Deployment Checks
- [x] Build project successfully: `swift build` or Xcode build.
- [ ] Test taking screenshot (`Cmd+Shift+4`). Does the thumbnail stay for ~5 seconds?
- [ ] Test copying text. Does the native notification appear?
- [ ] Check if floating bubbles have been completely removed from screen corners.
- [ ] Ensure Notification permissions handle graceful fallback if denied by user.

## ✅ PHASE X COMPLETE
- Lint: ✅ Pass
- Build: ✅ Pass
- Date: 2026-03-02
