import SwiftUI

@main
struct MemoryActivityApp: App {
    let store = ModelStore.instance(.live)

    let keyWindowObserver = KeyWindowObserver()
    let openAtLogin = OpenAtLogin()
    let sparkle = Sparkle()

    var body: some Scene {
        MenuBarExtra {
            MenuBarExtraWindowView(model: store.menuBarExtraWindowViewModel)
                .environment(keyWindowObserver)
                .environment(sparkle)
        } label: {
            MenuBarExtraIcon(model: store.menuBarExtraIconModel)
                .onAppear {
                    keyWindowObserver.configure()
                }
        }
        .menuBarExtraStyle(.window)

        Settings {
            AppSettings()
                .environment(keyWindowObserver)
                .environment(openAtLogin)
                .environment(sparkle)
        }
    }
}
