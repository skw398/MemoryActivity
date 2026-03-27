import AppKit
import Testing

@testable import MemoryActivity

@Test(.enabled(if: macOS15Available))
@MainActor
func `menu bar extra toggles and memory data is populated`() async throws {
    let button = try #require(NSApp.menuBarExtraStatusItem?.button)

    let performClickSilentlySucceeded = button.performClickSilently()
    #expect(performClickSilentlySucceeded)
    try await waitUntil("menu bar extra opens") {
        MenuBarExtraWindowViewVisibilityCheck.value
    }

    button.performClickSilently()
    try await waitUntil("menu bar extra closes") {
        MenuBarExtraWindowViewVisibilityCheck.value == false
    }

    button.performClickSilently()
    try await waitUntil("menu bar extra reopens") {
        MenuBarExtraWindowViewVisibilityCheck.value
    }

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

@MainActor
private func waitUntil(
    _ description: String = "condition",
    timeout: Duration = .seconds(2),
    condition: @MainActor () -> Bool,
) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now + timeout

    while clock.now < deadline {
        if condition() {
            return
        }
        try await Task.sleep(for: .milliseconds(10))
    }

    #expect(Bool(false), "'\(description)' was not met within \(timeout).")
}
