import SwiftUI
import mabackend

@main
struct MemoryActivityApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    let store: MemoryDataStore

    init() {
        _ = OpenAtLogin.instance
        _ = Sparkle.instance
        _ = mabackend.instance
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

extension MemoryActivityApp {
    class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationDidFinishLaunching(_: Notification) {
            _ = KeyWindowObserver.instance
        }
    }
}
