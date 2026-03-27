import DeveloperToolsSupport

extension MemoryData.PressureLevel {
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
