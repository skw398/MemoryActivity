import AppKit
import Testing

@testable import MemoryActivity

@Test(.enabled(if: macOS15Available))
@MainActor
func `menu bar extra toggles and memory data is populated`() async throws {
    let button = try #require(NSApp.menuBarExtraStatusItem?.button)

    let performClickSilentlySucceeded = button.performClickSilently()
    #expect(performClickSilentlySucceeded)
    try await waitUntil { MenuBarExtraWindowViewVisibilityCheck.value }

    button.performClickSilently()
    try await waitUntil { MenuBarExtraWindowViewVisibilityCheck.value == false }

    button.performClickSilently()
    try await waitUntil { MenuBarExtraWindowViewVisibilityCheck.value }

    try await Task.sleep(for: .milliseconds(1_000))

    let hub = MemoryDataHub.live

    #expect(hub.menuBarExtraIconModel.memoryPressureLevel != nil)

    let memoryPressureDataCount =
        hub.menuBarExtraWindowViewModel.memoryData.memoryPressure.data.count
    #expect(memoryPressureDataCount > 0)
    #expect(hub.menuBarExtraWindowViewModel.memoryData.physicalMemory ?? -1 > 0)
    #expect(hub.menuBarExtraWindowViewModel.memoryData.memoryUsed ?? -1 > 0)
    #expect(hub.menuBarExtraWindowViewModel.memoryData.appMemory ?? -1 > 0)
    #expect(hub.menuBarExtraWindowViewModel.memoryData.wiredMemory ?? -1 >= 0)
    #expect(hub.menuBarExtraWindowViewModel.memoryData.compressed ?? -1 >= 0)
    #expect(hub.menuBarExtraWindowViewModel.memoryData.cachedFiles ?? -1 >= 0)
    #expect(hub.menuBarExtraWindowViewModel.memoryData.swapUsed ?? -1 >= 0)

    try await Task.sleep(for: .milliseconds(1_000))
    #expect(
        hub.menuBarExtraWindowViewModel.memoryData.memoryPressure.data.count
            > memoryPressureDataCount,
    )
}

@MainActor
private func waitUntil(
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

    #expect(Bool(false), "Condition not met within \(timeout).")
}
