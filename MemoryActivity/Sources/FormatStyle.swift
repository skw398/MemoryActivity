import Foundation

struct MemoryActivityByteCountFormatStyle: FormatStyle {
    typealias FormatInput = Int64

    typealias FormatOutput = String

    func format(_ value: Int64) -> String {
        formatter.string(fromByteCount: value)
    }

    private var formatter: ByteCountFormatter {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowsNonnumericFormatting = false
        // Existing `ByteCountFormatStyle` does not have this property.
        formatter.zeroPadsFractionDigits = true
        return formatter
    }
}
