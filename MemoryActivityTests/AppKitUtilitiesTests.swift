import AppKit
import Testing

@testable import MemoryActivity

@Suite(.serialized)
@MainActor
struct AppKitUtilitiesTests {
    @Test
    func `menuBarExtraStatusBarWindow is not nil`() {
        #expect(NSApp.menuBarExtraStatusBarWindow != nil)
    }

    @Test
    func `menuBarExtraStatusItem is not nil`() {
        #expect(NSApp.menuBarExtraStatusItem != nil)
    }

    @Test
    func `menuBarExtraStatusItem button performClickSilently returns true`() {
        #expect(NSApp.menuBarExtraStatusItem?.button?.performClickSilently() ?? false)
    }
}
