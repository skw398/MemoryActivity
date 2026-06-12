import Observation
import Testing

@testable import MemoryActivity

@MainActor
struct MemoryDataStoreTests {
    private static func memoryData(level: MemoryData.PressureLevel) -> MemoryData {
        MemoryData(memoryPressure: .init(data: [.init(value: 50, level: level)], capacity: 10))
    }

    private static func store(level: MemoryData.PressureLevel) -> MemoryDataStore {
        MemoryDataStore(memoryData: memoryData(level: level))
    }

    @Test
    func `memoryPressureLevel is initialized from memoryData`() {
        let store = Self.store(level: .normal)
        #expect(store.memoryPressureLevel == .normal)
    }

    @Test
    func `memoryPressureLevel updates when pressure level changes`() {
        let store = Self.store(level: .normal)
        store.memoryData = Self.memoryData(level: .warning)
        #expect(store.memoryPressureLevel == .warning)
    }

    @Test
    func `memoryData changes but memoryPressureLevel does not when pressure level is unchanged`() {
        let store = Self.store(level: .normal)

        nonisolated(unsafe) var memoryDataChanged = false
        nonisolated(unsafe) var pressureLevelChanged = false
        withObservationTracking {
            _ = store.memoryData
        } onChange: {
            memoryDataChanged = true
        }
        withObservationTracking {
            _ = store.memoryPressureLevel
        } onChange: {
            pressureLevelChanged = true
        }

        store.memoryData = Self.memoryData(level: .normal)

        #expect(memoryDataChanged)
        #expect(!pressureLevelChanged)
    }

    @Test
    func `memoryPressureLevel triggers observation when pressure level changes`() {
        let store = Self.store(level: .normal)

        nonisolated(unsafe) var didObserveChange = false
        withObservationTracking {
            _ = store.memoryPressureLevel
        } onChange: {
            didObserveChange = true
        }

        store.memoryData = Self.memoryData(level: .warning)

        #expect(didObserveChange)
    }
}
