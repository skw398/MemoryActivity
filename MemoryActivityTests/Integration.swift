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

    let modelStore = ModelStore.instance(.live)

    #expect(modelStore.menuBarExtraIconModel.memoryPressureLebel != nil)

    let memoryPressureDataCount =
        modelStore.menuBarExtraWindowViewModel.memoryData.memoryPressure.data.count
    #expect(memoryPressureDataCount > 0)
    #expect(modelStore.menuBarExtraWindowViewModel.memoryData.physicalMemory ?? -1 > 0)
    #expect(modelStore.menuBarExtraWindowViewModel.memoryData.memoryUsed ?? -1 > 0)
    #expect(modelStore.menuBarExtraWindowViewModel.memoryData.appMemory ?? -1 > 0)
    #expect(modelStore.menuBarExtraWindowViewModel.memoryData.wiredMemory ?? -1 >= 0)
    #expect(modelStore.menuBarExtraWindowViewModel.memoryData.compressed ?? -1 >= 0)
    #expect(modelStore.menuBarExtraWindowViewModel.memoryData.cachedFiles ?? -1 >= 0)
    #expect(modelStore.menuBarExtraWindowViewModel.memoryData.swapUsed ?? -1 >= 0)

    try await Task.sleep(for: .milliseconds(1_000))
    #expect(
        modelStore.menuBarExtraWindowViewModel.memoryData.memoryPressure.data.count
            > memoryPressureDataCount,
    )
}
