import AppKit
import Testing

@testable import MemoryActivity

@Test(.enabled(if: macOS15Available))
@MainActor
func integration() async throws {
    #expect(NSApp.menuBarExtraStatusItem?.button != nil)
    let button = NSApp.menuBarExtraStatusItem!.button!

    let performClickSilentlySucceeded = button.performClickSilently()
    #expect(performClickSilentlySucceeded)
    try await Task.sleep(for: .milliseconds(100))

    #expect(MenuBarExtraWindowViewVisibilityCheck.value)

    button.performClickSilently()
    try await Task.sleep(for: .milliseconds(100))

    #expect(MenuBarExtraWindowViewVisibilityCheck.value == false)

    button.performClickSilently()
    try await Task.sleep(for: .milliseconds(100))

    #expect(MenuBarExtraWindowViewVisibilityCheck.value)

    try await Task.sleep(for: .milliseconds(1_000))

    let hub = MemoryDataHub.instance(.live)

    #expect(hub.menuBarExtraIconModel.memoryPressureLebel != nil)

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
