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
        memoryPressureLevel = memoryData.memoryPressure.data.last?.level
    }

    deinit {
        fatalError()
    }

    private func activate() {
        Task {
            let clock = SuspendingClock()

            for await _ in clock.stream(every: .seconds(1)) {
                update(with: MemoryData.Snapshot.current())
            }
        }
    }

    private func update(with snapshot: MemoryData.Snapshot) {
        memoryData.update(with: snapshot)

        guard let pressureLevel = snapshot.pressureLevel else {
            memoryPressureLevel = nil
            return
        }

        let level = MemoryData.PressureLevel(rawValue: pressureLevel)!

        // MenuBarExtra's view rendering can easily increase CPU usage, so update data only when
        // necessary.
        if level != memoryPressureLevel {
            memoryPressureLevel = level
        }
    }
}
