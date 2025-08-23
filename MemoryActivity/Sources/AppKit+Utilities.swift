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
        windows
            .filter { $0.className.contains("NSStatusBarWindow") }
            .compactMap { window -> NSStatusItem? in
                guard
                    let statusItem = window.value(forKey: "statusItem") as? NSStatusItem,
                    statusItem.className
                        == (macOS26Available ? "NSSceneStatusItem" : "NSStatusItem")
                else {
                    return nil
                }

                return statusItem
            }
            .first
    }
}
