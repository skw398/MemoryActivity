import Foundation

extension NotificationCenter {
    func voids(named name: Notification.Name) -> AsyncStream<Void> {
        AsyncStream<Void> { continuation in
            let task = Task {
                // non-Sendable Notification to Void
                for await _ in notifications(named: name).map({ _ in () }) {
                    continuation.yield(())
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
