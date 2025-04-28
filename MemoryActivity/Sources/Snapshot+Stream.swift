extension MemoryData.Snapshot {
    static func stream(every interval: Duration) -> AsyncStream<Self> {
        AsyncStream { continuation in
            let clock = SuspendingClock()

            let task = Task {
                continuation.yield(Self.get())

                for await _ in clock.stream(every: interval) {
                    guard !Task.isCancelled else {
                        continuation.finish()
                        return
                    }

                    continuation.yield(Self.get())
                }

                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

extension SuspendingClock {
    fileprivate func stream(every interval: Duration) -> AsyncStream<Instant> {
        AsyncStream { continuation in
            let task = Task {
                var last = now

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
