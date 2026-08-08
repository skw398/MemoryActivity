import SwiftUI

struct AppMenu: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.openSettings)
    private var openSettings

    var body: some View {
        Menu {
            Section {
                Button {
                    dismiss()
                    NSApp.activate(ignoringOtherApps: true)

                    NSApp.orderFrontStandardAboutPanel(nil)
                } label: {
                    Label("About MemoryActivity", systemImage: "info.circle")
                        .labelStyle(.osAdaptiveMenuItem)
                }

                Button {
                    dismiss()

                    Sparkle.instance.checkForUpdates()
                } label: {
                    Label(
                        "Check for Updates…",
                        systemImage: "arrow.trianglehead.2.clockwise.rotate.90",
                    )
                    .labelStyle(.osAdaptiveMenuItem)
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
                    Label("Settings…", systemImage: "gear")
                        .labelStyle(.osAdaptiveMenuItem)
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
                Button {
                    NSApp.terminate(nil)
                } label: {
                    Label("Quit MemoryActivity", systemImage: "xmark.rectangle")
                        .labelStyle(.osAdaptiveMenuItem)
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

extension LabelStyle where Self == AppMenu.OSAdaptiveMenuItemLabelStyle {
    fileprivate static var osAdaptiveMenuItem: Self {
        Self()
    }
}

extension AppMenu {
    fileprivate struct OSAdaptiveMenuItemLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            if macOS26Available {
                Label(configuration)
                    .labelStyle(.titleAndIcon)
            } else {
                Label(configuration)
                    .labelStyle(.titleOnly)
            }
        }
    }
}

#Preview {
    AppMenu()
        .padding()
}
