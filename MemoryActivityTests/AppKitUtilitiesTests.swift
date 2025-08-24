import AppKit
import Testing

@testable import MemoryActivity

@Suite(.serialized)
@MainActor
struct AppKitUtilitiesTests {
    @Test
    func menuBarExtraStatusBarWindow() {
        #expect(NSApp.menuBarExtraStatusBarWindow != nil)
    }

    @Test
    func menuBarExtraStatusItem() {
        #expect(NSApp.menuBarExtraStatusItem != nil)
    }

    @Test
    func menuBarExtraStatusItemButtonPerformClickSilently() {
        #expect(NSApp.menuBarExtraStatusItem?.button?.performClickSilently() ?? false)
    }
}
