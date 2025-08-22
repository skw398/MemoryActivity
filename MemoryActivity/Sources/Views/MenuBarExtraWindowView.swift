import SwiftUI

struct MenuBarExtraWindowView: View {
    let model: Model

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            MemoryDataViewContainer(memoryData: model.memoryData)
                .padding(6)
                .background(.background, in: .rect(cornerRadius: 4))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(.separator))

            AppMenu()
        }
        .frame(width: 210)
        .padding(8)
        .background(.windowBackground)
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

extension MenuBarExtraWindowView {
    fileprivate struct MemoryDataViewContainer: View {
        let memoryData: MemoryData

        var body: some View {
            // MenuBarExtra's view rendering can easily increase CPU usage, so pass data only when
            // necessary.
            Gate { MemoryDataView(memoryData: $0 ? memoryData : .empty) }
        }
    }
}

extension MenuBarExtraWindowView.MemoryDataViewContainer {
    fileprivate struct Gate<Content: View>: View {
        var content: (_: Bool) -> Content

        var body: some View {
            if #available(macOS 15, *) {
                ViewLifecycleBased(content: content)
            } else {
                KeyWindowBased(content: content)
            }
        }

        private struct ViewLifecycleBased: View {
            @State private var isVisible = true

            var content: (_: Bool) -> Content

            var body: some View {
                content(isVisible)
                    .onAppear {
                        isVisible = true
                    }
                    .onDisappear {
                        isVisible = false
                    }
            }
        }

        @available(macOS, deprecated: 15)
        private struct KeyWindowBased: View {
            var content: (_: Bool) -> Content

            var body: some View {
                content(KeyWindowObserver.instance.value != nil)
            }
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
