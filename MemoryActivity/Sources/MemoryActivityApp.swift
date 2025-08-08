import SwiftUI

@main
struct MemoryActivityApp: App {
    let menuBarExtraWindowViewModel = MenuBarExtraWindowView.Model(
        memoryData: MemoryData(memoryPressure: MemoryData.MemoryPressure(capacity: 67))
    )
    let menuBarExtraIconModel = MenuBarExtraIcon.Model(memoryPressureLebel: nil)

    let keyWindowObserver = KeyWindowObserver()
    let openAtLogin = OpenAtLogin()
    let sparkle = Sparkle()

    var body: some Scene {
        MenuBarExtra {
            MenuBarExtraWindowView(model: menuBarExtraWindowViewModel)
                .environment(keyWindowObserver)
                .environment(sparkle)
        } label: {
            MenuBarExtraIcon(model: menuBarExtraIconModel)
                .onAppear {
                    keyWindowObserver.configure()
                }
                .task {
                    for await snapshot in MemoryData.Snapshot.stream(every: .seconds(1)) {
                        menuBarExtraWindowViewModel.update(with: snapshot)
                        menuBarExtraIconModel.update(with: snapshot)
                    }
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
