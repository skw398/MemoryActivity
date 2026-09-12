import SwiftUI

@main
struct MemoryActivityApp: App {
    let store: MemoryDataStore

    init() {
        _ = OpenAtLogin.instance
        _ = Sparkle.instance
        store = .live
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarExtraWindowView(store: store)
                .background(.windowBackground)
        } label: {
            MenuBarExtraIcon(store: store)
        }
        .menuBarExtraStyle(.window)

        Settings {
            AppSettings()
        }
    }
}
