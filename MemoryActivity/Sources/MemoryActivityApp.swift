import SwiftUI

@main
struct MemoryActivityApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    let store: ModelStore

    init() {
        _ = OpenAtLogin.instance
        _ = Sparkle.instance

        store = .instance(.live)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarExtraWindowView(model: store.menuBarExtraWindowViewModel)
        } label: {
            MenuBarExtraIcon(model: store.menuBarExtraIconModel)
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
