import SwiftUI

struct MenuBarExtraWindowView: View {
    let model: Model

    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // MenuBarExtra's view rendering can easily increase CPU usage, so pass data only when
            // necessary.
            MemoryDataView(
                memoryData: macOS15Available
                    ? isVisible ? model.memoryData : .empty
                    : KeyWindowObserver.instance.value != nil ? model.memoryData : .empty,
            )
            .padding(macOS26Available ? 8 : 6)
            .background(.background, in: .rect(cornerRadius: macOS26Available ? 12 : 4))
            .overlay(RoundedRectangle(cornerRadius: macOS26Available ? 12 : 4).stroke(.separator))

            AppMenu()
        }
        .onAppear {
            isVisible = true
        }
        .onDisappear {
            isVisible = false
        }
        .frame(width: 198 + (macOS26Available ? 16 : 12))
        .padding(8)
        .background(.fill.quaternary)
    }
}

extension MenuBarExtraWindowView {
    @MainActor
    @Observable
    class Model {
        private(set) var memoryData: MemoryData

        init(memoryData: MemoryData) {
            self.memoryData = memoryData
        }

        func update(with snapshot: MemoryData.Snapshot) {
            memoryData.update(with: snapshot)
        }
    }
}

extension MemoryData {
    @MainActor
    fileprivate mutating func update(with snapshot: Snapshot) {
        if let value = snapshot.pressureValue, let level = snapshot.pressureLevel {
            guard let level = MemoryPressure.Data.Level(rawValue: level) else {
                fatalError()
            }

            memoryPressure.append(MemoryPressure.Data(value: value, level: level))
        }
        physicalMemory = snapshot.physicalMemory
        memoryUsed = snapshot.memoryUsed
        appMemory = snapshot.appMemory
        wiredMemory = snapshot.wiredMemory
        compressed = snapshot.compressed
        cachedFiles = snapshot.cachedFiles
        swapUsed = snapshot.swapUsed
    }

    fileprivate static let empty = Self(memoryPressure: .init(capacity: 0))
}

#Preview {
    MenuBarExtraWindowView(model: .init(memoryData: .sample))
}
