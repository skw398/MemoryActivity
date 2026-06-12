import Observation

@MainActor
@Observable
class MemoryDataStore {
    var memoryData: MemoryData {
        didSet {
            memoryPressureLevel = memoryData.memoryPressure.data.last??.level
        }
    }

    private(set) var memoryPressureLevel: MemoryData.PressureLevel?

    static let live: MemoryDataStore = {
        let store = MemoryDataStore(
            memoryData: MemoryData(memoryPressure: MemoryData.MemoryPressure(capacity: 67)),
        )
        store.activate()
        return store
    }()

    static let sample = MemoryDataStore(memoryData: MemoryData.sample)

    init(memoryData: MemoryData) {
        self.memoryData = memoryData
        memoryPressureLevel = memoryData.memoryPressure.data.last??.level
    }

    private func activate() {
        Task {
            let clock = SuspendingClock()

            for await _ in clock.stream(every: .seconds(1)) {
                memoryData.update()
            }
        }
    }
}
