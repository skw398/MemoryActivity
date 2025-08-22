import SwiftUI

struct AppMenu: View {
    @Environment(\.openSettings)
    private var openSettings

    var body: some View {
        Menu {
            Section {
                Button("About MemoryActivity") {
                    NSApp.menuBarExtraLabelStatusItem?.button?.performClickSilently()
                    NSApp.activate(ignoringOtherApps: true)

                    NSApp.orderFrontStandardAboutPanel(nil)
                }

                Button("Check for Updates…") {
                    NSApp.menuBarExtraLabelStatusItem?.button?.performClickSilently()

                    Sparkle.instance.checkForUpdates()
                }
                .badge(
                    Sparkle.instance.shouldDeliverGentleScheduledUpdateReminder ? "1 update" : nil
                )
                .disabled(!Sparkle.instance.canCheckForUpdates)
            }

            Section {
                Button("Settings…") {
                    NSApp.menuBarExtraLabelStatusItem?.button?.performClickSilently()
                    NSApp.activate(ignoringOtherApps: true)

                    openSettings()
                }
                .keyboardShortcut(",")
            }

            Section {
                if let url = NSWorkspace.shared.urlForApplication(
                    withBundleIdentifier: "com.apple.ActivityMonitor"
                ) {
                    Button("Open Activity Monitor") {
                        NSApp.menuBarExtraLabelStatusItem?.button?.performClickSilently()

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
