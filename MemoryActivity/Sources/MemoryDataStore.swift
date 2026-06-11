import Observation

@MainActor
@Observable
class MemoryDataStore {
    private(set) var memoryData: MemoryData
    private(set) var memoryPressureLevel: MemoryData.PressureLevel?

    static let live: MemoryDataStore = {
        let store = MemoryDataStore(
            memoryData: MemoryData(memoryPressure: MemoryData.MemoryPressure(capacity: 67)),
        )
        store.activate()
        return store
    }()

    static let sample = MemoryDataStore(memoryData: MemoryData.sample)

    private init(memoryData: MemoryData) {
        self.memoryData = memoryData
        memoryPressureLevel = memoryData.memoryPressure.data.last??.level
    }

    deinit {
        fatalError()
    }

    private func activate() {
        Task {
            let clock = SuspendingClock()

            for await _ in clock.stream(every: .seconds(1)) {
                memoryData.update()

                // MenuBarExtra's view rendering can easily increase CPU usage, so update data only
                // when necessary.
                let currentPressureLevel = memoryData.memoryPressure.data.last??.level
                if currentPressureLevel != memoryPressureLevel {
                    memoryPressureLevel = currentPressureLevel
                }
            }
        }
    }
}
