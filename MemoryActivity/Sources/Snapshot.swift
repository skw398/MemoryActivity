#if canImport(mabackend)
    import mabackend
#endif

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

extension MemoryData.Snapshot {
    static func get() -> Self {
        #if canImport(mabackend)
            let snapshot = mabackend.getSnapshot()

            return Self(
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
        #else
            #if DEBUG
                let physicalMemory = 192.0 * 1_024 * 1_024 * 1_024

                return Self(
                    pressureValue: Int.random(in: 0...100),
                    pressureLevel: Int.random(in: 0...2),
                    physicalMemory: Int64(physicalMemory),
                    memoryUsed: Int64(physicalMemory * Double.random(in: 0...1)),
                    appMemory: Int64(physicalMemory * Double.random(in: 0...1)),
                    wiredMemory: Int64(physicalMemory * Double.random(in: 0...1)),
                    compressed: Int64(physicalMemory * Double.random(in: 0...1)),
                    cachedFiles: Int64(physicalMemory * Double.random(in: 0...1)),
                    swapUsed: Int64(physicalMemory * Double.random(in: 0...1))
                )
            #else
                preconditionFailure()
            #endif
        #endif
    }
}

extension MemoryData {
    mutating func update(with snapshot: Snapshot) {
        if let value = snapshot.pressureValue, let level = snapshot.pressureLevel {
            memoryPressure.append(MemoryPressure.Data(value: value, level: .init(rawValue: level)!))
        }
        physicalMemory = snapshot.physicalMemory
        memoryUsed = snapshot.memoryUsed
        appMemory = snapshot.appMemory
        wiredMemory = snapshot.wiredMemory
        compressed = snapshot.compressed
        cachedFiles = snapshot.cachedFiles
        swapUsed = snapshot.swapUsed
    }
}
