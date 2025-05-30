import SwiftUI

struct MemoryDataView: View {
    let memoryData: MemoryData

    var body: some View {
        VStack(spacing: 6) {
            VStack(spacing: 2) {
                Text("MEMORY PRESSURE")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                Divider()

                VStack(spacing: 1) {
                    MemoryPressureGraph(memoryPressure: memoryData.memoryPressure)
                        .frame(height: 58)
                    Divider()
                }
            }

            VStack(spacing: 5) {
                LabeledContent("Physical Memory:", byteCount: memoryData.physicalMemory)
                Divider()
                LabeledContent("Memory Used:", byteCount: memoryData.memoryUsed)
                VStack(spacing: 3) {
                    LabeledContent("App Memory:", byteCount: memoryData.appMemory)
                    LabeledContent("Wired Memory:", byteCount: memoryData.wiredMemory)
                    LabeledContent("Compressed:", byteCount: memoryData.compressed)
                }
                .padding(.leading, 12)
                Divider()
                LabeledContent("Cached Files:", byteCount: memoryData.cachedFiles)
                Divider()
                LabeledContent("Swap Used:", byteCount: memoryData.swapUsed)
            }
            .labeledContentStyle(MemoryDataViewStyle())
        }
    }
}

#Preview {
    MemoryDataView(memoryData: .sample)
        .frame(width: 198)
        .padding(12)
}

extension LabeledContent where Label == Text, Content == Text {
    fileprivate init(_ titleKey: LocalizedStringKey, byteCount: Int64?) {
        if let byteCount {
            self.init(titleKey, value: byteCount, format: MemoryActivityByteCountFormatStyle())
        } else {
            self.init(titleKey, value: String(localized: "n/a"))
        }
    }
}

private struct MemoryDataViewStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            configuration.content
                .monospacedDigit()
        }
        .padding(.horizontal, 4)
        .font(.system(size: 10.5))
    }
}

#Preview("LabeledContent+ByteCount") {
    VStack {
        LabeledContent("Physical Memory:", byteCount: Int64(16 * 1024 * 1024 * 1024))
        LabeledContent("Memory Used:", byteCount: Int64(123.45 * 1024 * 1024 * 1024))
        LabeledContent("Memory Used:", byteCount: Int64(123.45 * 1024 * 1024))
        LabeledContent("Memory Used:", byteCount: Int64(123.45 * 1024))
        LabeledContent("Memory Used:", byteCount: Int64(123.45))
        LabeledContent("Memory Used:", byteCount: Int64(0))
        LabeledContent("Memory Used:", byteCount: nil)
    }
    .labeledContentStyle(MemoryDataViewStyle())
    .fixedSize()
    .padding()
}
