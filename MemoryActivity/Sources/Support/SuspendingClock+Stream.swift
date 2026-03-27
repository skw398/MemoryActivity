extension SuspendingClock {
    func stream(every interval: Duration) -> AsyncStream<Instant> {
        AsyncStream { continuation in
            let task = Task {
                var last = now

                continuation.yield(now)
                while !Task.isCancelled {
                    let next = last.advanced(by: interval)

                    do {
                        try await self.sleep(until: next)
                    } catch {
                        continuation.finish()
                        return
                    }
                    let now = now

                    last = next
                    continuation.yield(now)
                }

                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
