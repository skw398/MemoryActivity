import ServiceManagement

@MainActor @Observable class OpenAtLogin {
    var isOn: Bool {
        didSet {
            guard isOn != oldValue else {
                return
            }

            do {
                try isOn ? service.register() : service.unregister()
            } catch {
                print(error.localizedDescription)
            }

            refresh()
        }
    }

    private let service = SMAppService.mainApp

    init() {
        isOn = service.status == .enabled
    }

    func refresh() {
        isOn = service.status == .enabled
    }
}
