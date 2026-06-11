import Darwin

enum Mach {
    struct VMStatistics64 {
        var wireCount: UInt32
        var compressorPageCount: UInt32
        var internalPageCount: UInt32
        var externalPageCount: UInt32
        var purgeableCount: UInt32
        var freeCount: UInt32
        var speculativeCount: UInt32
    }

    static var vmStatistics64: VMStatistics64? {
        var size = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size,
        )
        var vmStats = vm_statistics64_data_t()
        let host = mach_host_self()
        defer {
            mach_port_deallocate(mach_task_self_, host)
        }

        let result = withUnsafeMutablePointer(to: &vmStats) { vmStatsPointer -> kern_return_t in
            vmStatsPointer.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { pointer in
                host_statistics64(host, HOST_VM_INFO64, pointer, &size)
            }
        }

        guard result == KERN_SUCCESS else {
            return nil
        }

        return VMStatistics64(
            wireCount: vmStats.wire_count,
            compressorPageCount: vmStats.compressor_page_count,
            internalPageCount: vmStats.internal_page_count,
            externalPageCount: vmStats.external_page_count,
            purgeableCount: vmStats.purgeable_count,
            freeCount: vmStats.free_count,
            speculativeCount: vmStats.speculative_count,
        )
    }
}

enum Sysctl {
    static var hwPageSize: Int32? {
        var mib: [Int32] = [CTL_HW, HW_PAGESIZE]
        return readInt32(mib: &mib)
    }

    static var hwMemSize: UInt64? {
        var mib: [Int32] = [CTL_HW, HW_MEMSIZE]
        return readUInt64(mib: &mib)
    }

    private static var vmSwapUsage: xsw_usage? {
        var mib: [Int32] = [CTL_VM, VM_SWAPUSAGE]
        var value = xsw_usage()
        var size = MemoryLayout<xsw_usage>.size
        let result = sysctl(&mib, UInt32(mib.count), &value, &size, nil, 0)
        return result == 0 ? value : nil
    }

    static var vmSwapUsed: UInt64? {
        vmSwapUsage.map(\.xsu_used)
    }

    static var kernMemorystatusLevel: Int32? {
        readInt32(name: "kern.memorystatus_level")
    }

    static var kernMemorystatusVMPressureLevel: Int32? {
        readInt32(name: "kern.memorystatus_vm_pressure_level")
    }

    private static func readUInt64(mib: inout [Int32]) -> UInt64? {
        var size = MemoryLayout<UInt64>.size
        var value: UInt64 = 0
        let result = sysctl(&mib, UInt32(mib.count), &value, &size, nil, 0)
        return result == 0 ? value : nil
    }

    private static func readInt32(mib: inout [Int32]) -> Int32? {
        var size = MemoryLayout<Int32>.size
        var value: Int32 = 0
        let result = sysctl(&mib, UInt32(mib.count), &value, &size, nil, 0)
        return result == 0 ? value : nil
    }

    private static func readInt32(name: String) -> Int32? {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        let result = sysctlbyname(name, &value, &size, nil, 0)
        return result == 0 ? value : nil
    }
}
