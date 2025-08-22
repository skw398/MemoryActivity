import SwiftUI

struct MenuBarExtraIcon: View {
    let model: Model

    @AppStorage("showMemoryPressureIndicator")
    var showMemoryPressureIndicator = true

    var body: some View {
        if showMemoryPressureIndicator, let level = model.memoryPressureLebel {
            level.memorychipBadge
        } else {
            Image.memorychip
        }
    }
}

extension MenuBarExtraIcon {
    @MainActor
    @Observable
    class Model {
        typealias MemoryPressureLevel = MemoryData.MemoryPressure.Data.Level

        private(set) var memoryPressureLebel: MemoryPressureLevel?

        init(memoryPressureLebel: MemoryPressureLevel? = nil) {
            self.memoryPressureLebel = memoryPressureLebel
        }

        func update(with snapshot: MemoryData.Snapshot) {
            guard let pressureLevel = snapshot.pressureLevel else {
                memoryPressureLebel = nil
                return
            }

            let level = MemoryPressureLevel(rawValue: pressureLevel)!

            // MenuBarExtra's view rendering can easily increase CPU usage, so update data only when
            // necessary.
            if level != memoryPressureLebel {
                memoryPressureLebel = level
            }
        }
    }
}

extension MemoryData.MemoryPressure.Data.Level {
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
                        .init(paletteColors: [NSColor(resource: level.colorResource), .textColor])
                    )
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
            accessibilityDescription: "Memory chip symbol"
        )!.withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))!
    )
}

#Preview {
    HStack {
        MenuBarExtraIcon(model: .init())
        ForEach(MenuBarExtraIcon.Model.MemoryPressureLevel.allCases, id: \.rawValue) { level in
            MenuBarExtraIcon(model: .init(memoryPressureLebel: level))
        }
    }
    .padding()
    .defaultAppStorage(.preview(applying: ["showMemoryPressureIndicator": true]))
}
