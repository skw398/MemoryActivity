struct MemoryData {
    var memoryPressure: MemoryPressure
    var physicalMemory: Int64?
    var memoryUsed: Int64?
    var appMemory: Int64?
    var wiredMemory: Int64?
    var compressed: Int64?
    var cachedFiles: Int64?
    var swapUsed: Int64?
}

extension MemoryData {
    struct MemoryPressure {
        var data: [DataPoint?] = []
        var capacity: Int

        init(capacity: Int) {
            self.capacity = capacity
        }

        init(data: [DataPoint?], capacity: Int) {
            self.data = data
            self.capacity = capacity
        }

        mutating func append(_ data: DataPoint?) {
            self.data.append(data)
            if self.data.count > capacity {
                self.data.removeFirst()
            }
        }
    }
}

extension MemoryData {
    typealias PressureLevel = MemoryPressure.DataPoint.Level
}

extension MemoryData.MemoryPressure {
    struct DataPoint {
        var value: Int
        var level: Level

        enum Level: Int, CaseIterable {
            case normal
            case warning
            case critical
        }
    }
}

extension MemoryData {
    mutating func update() {
        if let memorystatusLevel = Sysctl.kernMemorystatusLevel,
            let vmPressureLevel = Sysctl.kernMemorystatusVMPressureLevel,
            let pressureLevel = PressureLevel(vmPressureLevel: vmPressureLevel)
        {
            memoryPressure.append(
                MemoryPressure.DataPoint(
                    value: 100 - Int(memorystatusLevel),
                    level: pressureLevel,
                ),
            )
        } else {
            memoryPressure.append(nil)
        }

        physicalMemory = Sysctl.hwMemSize.flatMap { Int64(exactly: $0) }
        memoryUsed = nil
        appMemory = nil
        wiredMemory = nil
        compressed = nil
        cachedFiles = nil
        swapUsed = Sysctl.vmSwapUsed.flatMap { Int64(exactly: $0) }

        guard let hwPageSize = Sysctl.hwPageSize, let vmStats = Mach.vmStatistics64 else {
            return
        }

        let pageSize = Int64(hwPageSize)
        let wired = Int64(vmStats.wireCount) * pageSize
        let compressed = Int64(vmStats.compressorPageCount) * pageSize
        let internalPages = Int64(vmStats.internalPageCount) * pageSize
        let external = Int64(vmStats.externalPageCount) * pageSize
        let purgeable = Int64(vmStats.purgeableCount) * pageSize
        let free = Int64(vmStats.freeCount) * pageSize
        let speculative = Int64(vmStats.speculativeCount) * pageSize

        if let physicalMemory {
            memoryUsed = physicalMemory - free - external + speculative
        }
        appMemory = internalPages - purgeable
        wiredMemory = wired
        self.compressed = compressed
        cachedFiles = purgeable + external
    }
}

extension MemoryData.PressureLevel {
    fileprivate init?(vmPressureLevel: Int32) {
        switch vmPressureLevel {
        case 1:
            self = .normal
        case 2:
            self = .warning
        case 4:
            self = .critical
        default:
            return nil
        }
    }
}
