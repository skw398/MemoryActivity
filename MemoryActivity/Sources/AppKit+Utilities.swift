import AppKit

extension NSStatusBarButton {
    func performClickSilently() {
        if let action {
            NSApp.sendAction(action, to: target, from: self)
        }
    }
}

extension NSApplication {
    var menuBarExtraLabelStatusItem: NSStatusItem? {
        // Looking for another approach.
        windows
            .filter { $0.className.contains("NSStatusBarWindow") }
            .compactMap { window -> NSStatusItem? in
                guard
                    let statusItem = window.value(forKey: "statusItem") as? NSStatusItem,
                    statusItem.className == "NSStatusItem"
                else {
                    return nil
                }

                return statusItem
            }
            .first
    }
}
