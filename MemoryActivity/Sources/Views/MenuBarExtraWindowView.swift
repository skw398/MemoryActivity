import SwiftUI

struct MenuBarExtraWindowView: View {
    let store: MemoryDataStore

    @State private var isVisible = false {
        didSet {
            MenuBarExtraWindowViewVisibilityCheck.value = isVisible
        }
    }

    var body: some View {
        let shouldShowMemoryData =
            macOS15Available ? isVisible : KeyWindowObserver.instance.value != nil

        VStack(alignment: .trailing, spacing: 8) {
            // MenuBarExtra's view rendering can easily increase CPU usage, so pass data only when
            // necessary.
            MemoryDataView(memoryData: shouldShowMemoryData ? store.memoryData : .empty)
                .padding(macOS26Available ? 8 : 6)
                .background(.background, in: .rect(cornerRadius: macOS26Available ? 12 : 4))
                .overlay(
                    RoundedRectangle(cornerRadius: macOS26Available ? 12 : 4).stroke(.separator),
                )

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

extension MemoryData {
    static let empty = Self(memoryPressure: .init(capacity: 0))
}

#Preview {
    MenuBarExtraWindowView(store: .sample)
}
