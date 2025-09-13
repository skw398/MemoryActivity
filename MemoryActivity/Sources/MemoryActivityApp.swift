import SwiftUI
import mabackend

@main
struct MemoryActivityApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    let hub: MemoryDataHub

    init() {
        _ = OpenAtLogin.instance
        _ = Sparkle.instance
        _ = mabackend.instance
        hub = .instance(.live)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarExtraWindowView(model: hub.menuBarExtraWindowViewModel)
                .background(.windowBackground)
        } label: {
            MenuBarExtraIcon(model: hub.menuBarExtraIconModel)
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
