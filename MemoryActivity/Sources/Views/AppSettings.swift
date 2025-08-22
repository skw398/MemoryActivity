import SwiftUI

struct AppSettings: View {
    @AppStorage("showMemoryPressureIndicator")
    var showMemoryPressureIndicator = true

    var body: some View {
        @Bindable var openAtLogin = OpenAtLogin.instance
        @Bindable var sparkle = Sparkle.instance

        Form {
            LabeledContent("Menu Bar:") {
                Toggle("Show memory pressure indicator", isOn: $showMemoryPressureIndicator)
            }
            .padding(.bottom, 8)

            LabeledContent("Application:") {
                VStack(alignment: .leading) {
                    Toggle("Open at login", isOn: $openAtLogin.isOn)
                        .onChange(of: KeyWindowObserver.instance.value) { _, keyWindow in
                            if keyWindow != nil {
                                openAtLogin.refresh()
                            }
                        }

                    Toggle(
                        "Automatically check for updates",
                        isOn: $sparkle.automaticallyChecksForUpdates
                    )

                    Toggle(
                        "Automatically download updates",
                        isOn: $sparkle.automaticallyDownloadsUpdates
                    )
                    .disabled(!sparkle.automaticallyChecksForUpdates)
                }
            }

            Divider()

            Button("Website") {
                NSWorkspace.shared.open(URL(string: "https://github.com/skw398/MemoryActivity")!)
            }
        }
        .fixedSize()
        .scenePadding()
    }
}

#Preview {
    AppSettings()
}
