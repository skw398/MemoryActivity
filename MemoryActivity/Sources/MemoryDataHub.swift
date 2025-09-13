@MainActor
class MemoryDataHub {
    let menuBarExtraWindowViewModel: MenuBarExtraWindowView.Model
    let menuBarExtraIconModel: MenuBarExtraIcon.Model

    static func instance(_ mode: Mode) -> MemoryDataHub {
        if let instance = instances[mode] {
            return instance
        }

        let store = MemoryDataHub(mode: mode)
        instances[mode] = store

        return store
    }

    private static var instances = [Mode: MemoryDataHub]()

    private init(mode: Mode) {
        switch mode {
        case .live:
            menuBarExtraWindowViewModel = MenuBarExtraWindowView.Model(
                memoryData: MemoryData(memoryPressure: MemoryData.MemoryPressure(capacity: 67)),
            )
            menuBarExtraIconModel = MenuBarExtraIcon.Model()

            Task {
                let clock = SuspendingClock()

                for await _ in clock.stream(every: .seconds(1)) {
                    let snapshot = MemoryData.Snapshot.get()

                    menuBarExtraWindowViewModel.update(with: snapshot)
                    menuBarExtraIconModel.update(with: snapshot)
                }
            }
        case .sample:
            let sample = MemoryData.sample

            menuBarExtraWindowViewModel = MenuBarExtraWindowView.Model(memoryData: sample)
            menuBarExtraIconModel = MenuBarExtraIcon.Model(
                memoryPressureLebel: sample.memoryPressure.data.last?.level,
            )
        }
    }

    deinit {
        fatalError()
    }
}

extension MemoryDataHub {
    enum Mode {
        case live
        case sample
    }
}
