import SwiftUI
import AppKit

struct PermissionsView: View {
    @State private var notificationsGranted = false
    var onClose: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Required Permissions")
                .font(.title2)
                .bold()

            Text("To enable global shortcut and notifications, please grant the following:")
                .font(.body)

            VStack(alignment: .leading, spacing: 8) {
                Text("Accessibility: Needed for the Cmd+Shift+V shortcut.")
                HStack {
                    Button("Open Accessibility Settings") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Notifications: Used to show ‘Saved’ and ‘Copied’ alerts.")
                HStack {
                    Button(notificationsGranted ? "Notifications Enabled" : "Enable Notifications") {
                        Notifier.requestAuthorization { granted in
                            DispatchQueue.main.async { notificationsGranted = granted }
                        }
                    }
                    .disabled(notificationsGranted)
                }
            }

            HStack {
                Spacer()
                Button("Close") { onClose?() }
            }
        }
        .padding(20)
        .frame(width: 420)
    }
}