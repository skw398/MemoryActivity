import ServiceManagement

@MainActor
@Observable
class OpenAtLogin {
    static let instance = OpenAtLogin()

    @ObservationIgnored private var _isOn: Bool

    var isOn: Bool {
        get {
            access(keyPath: \.isOn)
            return _isOn
        }
        set {
            let oldValue = _isOn
            guard newValue != oldValue else {
                return
            }

            withMutation(keyPath: \.isOn) {
                _isOn = newValue
            }

            do {
                if newValue {
                    try service.register()
                } else {
                    try service.unregister()
                }
            } catch {
                print(error.localizedDescription)
            }

            refresh()
        }
    }

    private let service = SMAppService.mainApp

    private init() {
        _isOn = service.status == .enabled
    }

    deinit {
        fatalError()
    }

    func refresh() {
        withMutation(keyPath: \.isOn) {
            _isOn = service.status == .enabled
        }
    }
}
