import SwiftUI

struct AppMenu: View {
    @Environment(\.openSettings) private var openSettings

    @Environment(Sparkle.self) var sparkle

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

                    sparkle.checkForUpdates()
                }
                .badge(sparkle.shouldDeliverGentleScheduledUpdateReminder ? "1 update" : nil)
                .disabled(!sparkle.canCheckForUpdates)
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
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.ActivityMonitor") {
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
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
}

#Preview {
    AppMenu()
        .padding()
        .environment(Sparkle())
}
