import SwiftUI

struct AppMenu: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.openSettings)
    private var openSettings

    var body: some View {
        Menu {
            Section {
                Button("About MemoryActivity") {
                    dismiss()
                    NSApp.activate(ignoringOtherApps: true)

                    NSApp.orderFrontStandardAboutPanel(nil)
                }

                Button("Check for Updates…") {
                    dismiss()

                    Sparkle.instance.checkForUpdates()
                }
                .badge(
                    Sparkle.instance.shouldDeliverGentleScheduledUpdateReminder ? "1 update" : nil,
                )
                .disabled(!Sparkle.instance.canCheckForUpdates)
            }

            Section {
                Button {
                    dismiss()
                    NSApp.activate(ignoringOtherApps: true)

                    openSettings()
                } label: {
                    if macOS26Available {
                        Label("Settings…", systemImage: "gear")
                            .labelStyle(.titleAndIcon)
                    } else {
                        Text("Settings…")
                    }
                }
                .keyboardShortcut(",")
            }

            Section {
                if let url = NSWorkspace.shared.urlForApplication(
                    withBundleIdentifier: "com.apple.ActivityMonitor",
                ) {
                    Button("Open Activity Monitor") {
                        dismiss()

                        NSWorkspace.shared.openApplication(at: url, configuration: .init())
                    }
                }
            }

            Section {
                Button("Quit MemoryActivity") {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("q")
            }
        } label: {
            Label("Menu", systemImage: "ellipsis.circle")
                .labelStyle(.iconOnly)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
}

#Preview {
    AppMenu()
        .padding()
}
