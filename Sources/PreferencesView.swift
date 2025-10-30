import SwiftUI
import Carbon

struct PreferencesView: View {
    @State private var startAtLogin: Bool = LoginItemManager.shared.isStartAtLoginEnabled()
    var onApply: ((ShortcutManager.Settings) -> Void)?
    private var supportsLoginItem: Bool {
        if #available(macOS 13.0, *) { return true } else { return false }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences").font(.title2).bold()
            
            // Shortcut section removed
            
            GroupBox(label: Text("Startup")) {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Start at login", isOn: $startAtLogin)
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
                Button("Apply") {
                    let settings = ShortcutManager.Settings(enabled: false, modifiers: 0, keyCode: 0)
                    ShortcutManager.shared.save(settings: settings)
                    onApply?(settings)
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

private let letterKeys: [(label: String, code: UInt32)] = [
    ("A", UInt32(kVK_ANSI_A)), ("B", UInt32(kVK_ANSI_B)), ("C", UInt32(kVK_ANSI_C)), ("D", UInt32(kVK_ANSI_D)), ("E", UInt32(kVK_ANSI_E)),
    ("F", UInt32(kVK_ANSI_F)), ("G", UInt32(kVK_ANSI_G)), ("H", UInt32(kVK_ANSI_H)), ("I", UInt32(kVK_ANSI_I)), ("J", UInt32(kVK_ANSI_J)),
    ("K", UInt32(kVK_ANSI_K)), ("L", UInt32(kVK_ANSI_L)), ("M", UInt32(kVK_ANSI_M)), ("N", UInt32(kVK_ANSI_N)), ("O", UInt32(kVK_ANSI_O)),
    ("P", UInt32(kVK_ANSI_P)), ("Q", UInt32(kVK_ANSI_Q)), ("R", UInt32(kVK_ANSI_R)), ("S", UInt32(kVK_ANSI_S)), ("T", UInt32(kVK_ANSI_T)),
    ("U", UInt32(kVK_ANSI_U)), ("V", UInt32(kVK_ANSI_V)), ("W", UInt32(kVK_ANSI_W)), ("X", UInt32(kVK_ANSI_X)), ("Y", UInt32(kVK_ANSI_Y)),
    ("Z", UInt32(kVK_ANSI_Z))
]