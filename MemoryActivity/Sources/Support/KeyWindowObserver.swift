import AppKit

@available(macOS, deprecated: 15)
@MainActor
@Observable
class KeyWindowObserver {
    static let instance = KeyWindowObserver()

    private(set) var value: NSWindow?

    @ObservationIgnored private var observation: NSKeyValueObservation?

    private init() {
        observation = NSApp.observe(\.keyWindow) { [weak self] app, _ in
            guard let self else {
                return
            }

            Task { @MainActor in
                value = app.keyWindow
            }
        }
    }

    deinit {
        fatalError()
    }
}
