import AppKit

extension NSStatusBarButton {
    func performClickSilently() {
        if let action {
            NSApp.sendAction(action, to: target, from: self)
        }
    }
}

extension NSApplication {
    var menuBarExtraStatusItem: NSStatusItem? {
        guard let window = windows.first(where: \.isNSStatusBarWindow) else {
            return nil
        }

        return window.value(forKey: "statusItem") as? NSStatusItem
    }
}

extension NSWindow {
    fileprivate var isNSStatusBarWindow: Bool {
        className.contains("NSStatusBarWindow")
    }
}
