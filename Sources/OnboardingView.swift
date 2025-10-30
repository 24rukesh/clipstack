import SwiftUI
import AppKit

struct OnboardingView: View {
    @State private var notificationsEnabled = false
    @State private var startAtLogin = LoginItemManager.shared.isStartAtLoginEnabled()
    var onClose: (() -> Void)?
    private var supportsLoginItem: Bool {
        if #available(macOS 13.0, *) { return true } else { return false }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Welcome to ClipStack")
                .font(.title2)
                .bold()
            Text("Get set up with notifications and auto-start at login.")
                .font(.body)
                
            GroupBox(label: Text("Notifications")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enable notifications to see 'Saved' and 'Copied' alerts.")
                    HStack {
                        Button(notificationsEnabled ? "Notifications Enabled" : "Enable Notifications") {
                            Notifier.requestAuthorization { granted in
                                DispatchQueue.main.async { notificationsEnabled = granted }
                            }
                        }
                        .disabled(notificationsEnabled)
                    }
                }
            }
            
            GroupBox(label: Text("Start at Login")) {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Launch ClipStack automatically after login", isOn: $startAtLogin)
                        .disabled(!supportsLoginItem)
                        .onChange(of: startAtLogin) { v in
                            LoginItemManager.shared.setStartAtLogin(v)
                        }
                    if !supportsLoginItem {
                        Text("Requires macOS 13 or later.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                Spacer()
                Button("Continue") {
                    UserDefaults.standard.set(true, forKey: "hasOnboarded")
                    onClose?()
                }
            }
        }
        .padding(20)
        .frame(width: 520)
        .onAppear {
            startAtLogin = LoginItemManager.shared.isStartAtLoginEnabled()
        }
    }
}