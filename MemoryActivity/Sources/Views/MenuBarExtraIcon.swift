import SwiftUI

struct MenuBarExtraIcon: View {
    let model: Model

    @AppStorage("showMemoryPressureIndicator") var showMemoryPressureIndicator = true

    var body: some View {
        if showMemoryPressureIndicator {
            model.memoryPressureLebel?.memorychipBadge ?? .memorychipBadgeQuestionmark
        } else {
            Image.memorychip
        }
    }
}

extension MenuBarExtraIcon {
    @Observable class Model {
        typealias MemoryPressureLevel = MemoryData.MemoryPressure.Data.Level

        private(set) var memoryPressureLebel: MemoryPressureLevel?

        init(memoryPressureLebel: MemoryPressureLevel?) {
            self.memoryPressureLebel = memoryPressureLebel
        }

        func update(with snapshot: MemoryData.Snapshot) {
            guard let pressureLevel = snapshot.pressureLevel else {
                memoryPressureLebel = nil
                return
            }

            let level = MemoryPressureLevel(rawValue: pressureLevel)!

            if level != memoryPressureLebel {
                memoryPressureLebel = level
            }
        }
    }
}

#Preview {
    HStack {
        MenuBarExtraIcon(model: .init(memoryPressureLebel: nil))
        ForEach(MenuBarExtraIcon.Model.MemoryPressureLevel.allCases, id: \.rawValue) {
            MenuBarExtraIcon(model: .init(memoryPressureLebel: $0))
        }
    }
    .padding()
    .defaultAppStorage(.preview(applying: ["showMemoryPressureIndicator": true]))
}

#Preview("Hide memory pressure lebel") {
    MenuBarExtraIcon(model: .init(memoryPressureLebel: .normal))
        .padding()
        .defaultAppStorage(.preview(applying: ["showMemoryPressureIndicator": false]))
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
            systemSymbolName: "memorychip", accessibilityDescription: "Memory chip symbol"
        )!.withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))!
    )

    fileprivate static let memorychipBadgeQuestionmark = Self(
        nsImage: NSImage(resource: .customMemorychipBadgeQuestionmark)
            .withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))!
    )
}
