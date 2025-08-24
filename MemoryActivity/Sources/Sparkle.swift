import AppKit
import Combine
import Sparkle

@MainActor
@Observable
class Sparkle: NSObject {
    static let instance = Sparkle()

    var automaticallyChecksForUpdates: Bool = false {
        didSet {
            guard automaticallyChecksForUpdates != oldValue else {
                return
            }

            controller.updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates

            if !automaticallyChecksForUpdates {
                automaticallyDownloadsUpdates = false
            }
        }
    }

    var automaticallyDownloadsUpdates: Bool = false {
        didSet {
            guard automaticallyDownloadsUpdates != oldValue else {
                return
            }

            controller.updater.automaticallyDownloadsUpdates = automaticallyDownloadsUpdates
        }
    }

    private(set) var canCheckForUpdates = false

    private(set) var shouldDeliverGentleScheduledUpdateReminder = false {
        didSet {
            NSApp.setActivationPolicy(
                shouldDeliverGentleScheduledUpdateReminder ? .regular : .accessory,
            )
        }
    }

    private var controller: SPUStandardUpdaterController!

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    override private init() {
        super.init()

        controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: self,
        )

        controller.updater.publisher(for: \.automaticallyChecksForUpdates)
            .assign(to: \.automaticallyChecksForUpdates, on: self)
            .store(in: &cancellables)

        controller.updater.publisher(for: \.automaticallyDownloadsUpdates)
            .assign(to: \.automaticallyDownloadsUpdates, on: self)
            .store(in: &cancellables)

        controller.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: \.canCheckForUpdates, on: self)
            .store(in: &cancellables)
    }

    deinit {
        fatalError()
    }

    func checkForUpdates() {
        controller.updater.checkForUpdates()
    }
}

extension Sparkle: SPUStandardUserDriverDelegate {
    nonisolated var supportsGentleScheduledUpdateReminders: Bool {
        true
    }

    nonisolated func standardUserDriverWillHandleShowingUpdate(
        _: Bool,
        forUpdate _: SUAppcastItem,
        state _: SPUUserUpdateState,
    ) {
        Task { @MainActor in
            shouldDeliverGentleScheduledUpdateReminder = true
        }
    }

    nonisolated func standardUserDriverWillFinishUpdateSession() {
        Task { @MainActor in
            shouldDeliverGentleScheduledUpdateReminder = false
        }
    }
}
