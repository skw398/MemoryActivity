import DeveloperToolsSupport

extension MemoryData.MemoryPressure.Data.Level {
    var colorResource: ColorResource {
        switch self {
        case .normal:
            .normal
        case .warning:
            .warning
        case .critical:
            .critical
        }
    }
}
