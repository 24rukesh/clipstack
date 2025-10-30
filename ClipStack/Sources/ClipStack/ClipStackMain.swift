import SwiftUI

@main
struct ClipStackMain: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Empty scene since we're running as a menu bar app
        Settings {
            EmptyView()
        }
    }
}