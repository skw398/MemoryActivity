import AppKit

@MainActor
@Observable
class KeyWindowObserver {
    private(set) var value: NSWindow?

    @ObservationIgnored private var observation: NSKeyValueObservation?

    func configure() {
        guard observation == nil else {
            return
        }

        observation = NSApp.observe(\.keyWindow) { [weak self] app, _ in
            guard let self else {
                return
            }

            Task { @MainActor in
                value = app.keyWindow
            }
        }
    }
}

extension KeyWindowObserver {
    static let preview = {
        let observer = KeyWindowObserver()
        observer.value = NSWindow()
        // swiftlint:disable:next no_empty_block
        observer.observation = NSApp.observe(\.keyWindow) { _, _ in }
        return observer
    }()
}
