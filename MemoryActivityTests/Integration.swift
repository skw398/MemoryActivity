import Testing

@testable import MemoryActivity

@Test
@MainActor
func `memory data is populated`() async throws {
    try await Task.sleep(for: .milliseconds(1_000))

    let store = MemoryDataStore.live

    #expect(store.memoryPressureLevel != nil)

    let memoryPressureDataCount = store.memoryData.memoryPressure.data.count
    #expect(memoryPressureDataCount > 0)
    #expect(store.memoryData.physicalMemory ?? -1 > 0)
    #expect(store.memoryData.memoryUsed ?? -1 > 0)
    #expect(store.memoryData.appMemory ?? -1 > 0)
    #expect(store.memoryData.wiredMemory ?? -1 >= 0)
    #expect(store.memoryData.compressed ?? -1 >= 0)
    #expect(store.memoryData.cachedFiles ?? -1 >= 0)
    #expect(store.memoryData.swapUsed ?? -1 >= 0)

    try await Task.sleep(for: .milliseconds(1_000))
    #expect(store.memoryData.memoryPressure.data.count > memoryPressureDataCount)
}
