import mabackend

private let backend = mabackend.instance

extension MemoryData {
    struct Snapshot {
        var pressureValue: Int?
        var pressureLevel: Int?
        var physicalMemory: Int64?
        var memoryUsed: Int64?
        var appMemory: Int64?
        var wiredMemory: Int64?
        var compressed: Int64?
        var cachedFiles: Int64?
        var swapUsed: Int64?

        static func get() -> Self {
            let snapshot = backend.get()

            return .init(
                pressureValue: snapshot.pressureValue,
                pressureLevel: snapshot.pressureLevel,
                physicalMemory: snapshot.physicalMemory,
                memoryUsed: snapshot.memoryUsed,
                appMemory: snapshot.appMemory,
                wiredMemory: snapshot.wiredMemory,
                compressed: snapshot.compressed,
                cachedFiles: snapshot.cachedFiles,
                swapUsed: snapshot.swapUsed
            )
        }

        private init(
            pressureValue: Int?,
            pressureLevel: Int?,
            physicalMemory: Int64?,
            memoryUsed: Int64?,
            appMemory: Int64?,
            wiredMemory: Int64?,
            compressed: Int64?,
            cachedFiles: Int64?,
            swapUsed: Int64?
        ) {
            self.pressureValue = pressureValue
            self.pressureLevel = pressureLevel
            self.physicalMemory = physicalMemory
            self.memoryUsed = memoryUsed
            self.appMemory = appMemory
            self.wiredMemory = wiredMemory
            self.compressed = compressed
            self.cachedFiles = cachedFiles
            self.swapUsed = swapUsed
        }
    }
}
