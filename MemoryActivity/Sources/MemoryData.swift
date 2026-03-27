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
        var data: [DataPoint] = []
        var capacity: Int

        init(capacity: Int) {
            self.capacity = capacity
        }

        init(data: [DataPoint], capacity: Int) {
            self.data = data
            self.capacity = capacity
        }

        mutating func append(_ data: DataPoint) {
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
