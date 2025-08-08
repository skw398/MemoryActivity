import SwiftUI

struct MenuBarExtraWindowView: View {
    let model: Model

    @Environment(KeyWindowObserver.self)
    private var keyWindowObserver

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            MemoryDataView(
                // MenuBarExtra's view rendering easily increases CPU usage.
                // So, data is passed only when necessary.
                // Looking for another approach.
                memoryData: keyWindowObserver.value != nil ? model.memoryData : .empty
            )
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

#Preview {
    MenuBarExtraWindowView(model: .init(memoryData: .sample))
        .environment(KeyWindowObserver.preview)
        .environment(Sparkle())
}

extension MemoryData {
    fileprivate static let empty = Self(memoryPressure: .init(capacity: 0))
}
