@MainActor
class MemoryDataHub {
    let menuBarExtraWindowViewModel: MenuBarExtraWindowView.Model
    let menuBarExtraIconModel: MenuBarExtraIcon.Model

    static let live = MemoryDataHub(
        menuBarExtraWindowViewModel: MenuBarExtraWindowView.Model(
            memoryData: MemoryData(memoryPressure: MemoryData.MemoryPressure(capacity: 67)),
        ),
        menuBarExtraIconModel: MenuBarExtraIcon.Model(),
        startPolling: true,
    )

    static let sample: MemoryDataHub = {
        let sample = MemoryData.sample
        return MemoryDataHub(
            menuBarExtraWindowViewModel: MenuBarExtraWindowView.Model(memoryData: sample),
            menuBarExtraIconModel: MenuBarExtraIcon.Model(
                memoryPressureLevel: sample.memoryPressure.data.last?.level,
            ),
            startPolling: false,
        )
    }()

    private init(
        menuBarExtraWindowViewModel: MenuBarExtraWindowView.Model,
        menuBarExtraIconModel: MenuBarExtraIcon.Model,
        startPolling: Bool,
    ) {
        self.menuBarExtraWindowViewModel = menuBarExtraWindowViewModel
        self.menuBarExtraIconModel = menuBarExtraIconModel

        if startPolling {
            Task {
                let clock = SuspendingClock()

                for await _ in clock.stream(every: .seconds(1)) {
                    let snapshot = MemoryData.Snapshot.current()

                    menuBarExtraWindowViewModel.update(with: snapshot)
                    menuBarExtraIconModel.update(with: snapshot)
                }
            }
        }
    }

    deinit {
        fatalError()
    }
}
