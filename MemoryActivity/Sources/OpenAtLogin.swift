import ServiceManagement

@MainActor
@Observable
class OpenAtLogin {
    static let instance = OpenAtLogin()

    var isOn: Bool {
        didSet {
            guard isOn != oldValue else {
                return
            }

            do {
                if isOn {
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
        isOn = service.status == .enabled
    }

    deinit {
        fatalError()
    }

    func refresh() {
        isOn = service.status == .enabled
    }
}
