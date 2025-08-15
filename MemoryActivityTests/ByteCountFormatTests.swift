import Foundation
import Testing

@testable import MemoryActivity

struct ByteCountFormatTests {
    @Test(.enabled(if: [.english, .japanese].contains(Locale.current.language.languageCode)))
    func format() {
        let style = MemoryActivityByteCountFormatStyle()

        #expect(Int64(123.45 * 1_024 * 1_024 * 1_024).formatted(style) == "123.45 GB")
        #expect(Int64(123.4 * 1_024 * 1_024 * 1_024).formatted(style) == "123.40 GB")
        #expect(Int64(123 * 1_024 * 1_024 * 1_024).formatted(style) == "123.00 GB")
        #expect(Int64(1_024 * 1_024 * 1_024).formatted(style) == "1.00 GB")
        #expect(Int64(1_023 * 1_024 * 1_024).formatted(style) == "1,023.0 MB")
        #expect(Int64(123.45 * 1_024 * 1_024).formatted(style) == "123.4 MB")
        #expect(Int64(123 * 1_024 * 1_024).formatted(style) == "123.0 MB")
        #expect(Int64(1_024 * 1_024).formatted(style) == "1.0 MB")
        #expect(Int64(1_023 * 1_024).formatted(style) == "1,023 KB")
        #expect(Int64(123.45 * 1_024).formatted(style) == "123 KB")
        #expect(Int64(123 * 1_024).formatted(style) == "123 KB")
        #expect(Int64(1_024).formatted(style) == "1 KB")

        if Locale.current.language.languageCode == .english {
            #expect(Int64(1_023).formatted(style) == "1,023 bytes")
            #expect(Int64(123.45).formatted(style) == "123 bytes")
            #expect(Int64(123).formatted(style) == "123 bytes")
            #expect(Int64(0).formatted(style) == "0 bytes")
        }

        if Locale.current.language.languageCode == .japanese {
            #expect(Int64(1_023).formatted(style) == "1,023 バイト")
            #expect(Int64(123.45).formatted(style) == "123 バイト")
            #expect(Int64(123).formatted(style) == "123 バイト")
            #expect(Int64(0).formatted(style) == "0 バイト")
        }
    }
}
