import SwiftUI

@main
struct MemoryActivityApp: App {
    let store: ModelStore

    init() {
        _ = KeyWindowObserver.instance
        _ = OpenAtLogin.instance
        _ = Sparkle.instance

        store = .instance(.live)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarExtraWindowView(model: store.menuBarExtraWindowViewModel)
        } label: {
            MenuBarExtraIcon(model: store.menuBarExtraIconModel)
                .onAppear {
                    KeyWindowObserver.instance.configure()
                }
        }
        .menuBarExtraStyle(.window)

        Settings {
            AppSettings()
        }
    }
}
