import Foundation

struct MemoryActivityByteCountFormatStyle: FormatStyle {
    typealias FormatInput = Int64

    typealias FormatOutput = String

    func format(_ value: Int64) -> String {
        // Use ByteCountFormatter instead of ByteCountFormatStyle to match Activity Monitor's
        // display format.
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowsNonnumericFormatting = false
        formatter.zeroPadsFractionDigits = true
        return formatter.string(fromByteCount: value)
    }
}
