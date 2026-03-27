import SwiftUI

struct MenuBarExtraIcon: View {
    let store: MemoryDataStore

    @AppStorage("showMemoryPressureIndicator")
    var showMemoryPressureIndicator = true

    var body: some View {
        if showMemoryPressureIndicator, let level = store.memoryPressureLevel {
            level.memorychipBadge
        } else {
            Image.memorychip
        }
    }
}

extension MemoryData.PressureLevel {
    fileprivate var memorychipBadge: Image {
        Self.memorychipBadges[self]!
    }

    private static let memorychipBadges: [Self: Image] = {
        var result: [Self: Image] = [:]
        for level in Self.allCases {
            let image = NSImage(resource: .customMemorychipBadge).withSymbolConfiguration(
                NSImage.SymbolConfiguration()
                    .applying(.init(scale: .large))
                    .applying(
                        .init(paletteColors: [NSColor(resource: level.colorResource), .textColor]),
                    ),
            )!
            result[level] = Image(nsImage: image)
        }
        return result
    }()
}

extension Image {
    fileprivate static let memorychip = Self(
        nsImage: NSImage(
            systemSymbolName: "memorychip",
            accessibilityDescription: "Memory chip symbol",
        )!.withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))!,
    )
}

#Preview {
    HStack {
        MenuBarExtraIcon(store: .sample)
    }
    .padding()
    .defaultAppStorage(.preview(applying: ["showMemoryPressureIndicator": true]))
}
