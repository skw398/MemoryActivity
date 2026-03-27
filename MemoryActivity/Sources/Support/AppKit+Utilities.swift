import AppKit

extension NSStatusBarButton {
    @discardableResult
    func performClickSilently() -> Bool {
        if let action {
            return NSApp.sendAction(action, to: target, from: self)
        }

        return false
    }
}

extension NSApplication {
    var menuBarExtraStatusItem: NSStatusItem? {
        guard let menuBarExtraStatusBarWindow else {
            return nil
        }

        return menuBarExtraStatusBarWindow.value(forKey: "statusItem") as? NSStatusItem
    }

    var menuBarExtraStatusBarWindow: NSWindow? {
        windows.first(where: \.isNSStatusBarWindow)
    }
}

extension NSWindow {
    fileprivate var isNSStatusBarWindow: Bool {
        className.contains("NSStatusBarWindow")
    }
}
