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
        var data: [Data] = []
        var capacity: Int

        init(capacity: Int) {
            self.capacity = capacity
        }

        mutating func append(_ data: Data) {
            self.data.append(data)
            if self.data.count > capacity {
                self.data.removeFirst()
            }
        }
    }
}

extension MemoryData.MemoryPressure {
    struct Data {
        var value: Int
        var level: Level

        enum Level: Int, CaseIterable {
            case normal
            case warning
            case critical
        }
    }
}
