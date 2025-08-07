import Foundation

struct Entry: Decodable {
    let path: String
    let keys: [Key]

    struct Key: Decodable {
        let loctable_key: String
        let xcstrings_key: String
    }
}

let entries: [Entry] = [
    Entry(
        path: "/System/Applications/Utilities/Activity Monitor.app/Contents/Resources/ActivityMonitor.loctable",
        keys: [
            .init(loctable_key: "301577.title", xcstrings_key: "MEMORY PRESSURE"),
            .init(loctable_key: "100849.title", xcstrings_key: "Physical Memory:"),
            .init(loctable_key: "101989.title", xcstrings_key: "Memory Used:"),
            .init(loctable_key: "100806.title", xcstrings_key: "App Memory:"),
            .init(loctable_key: "100802.title", xcstrings_key: "Wired Memory:"),
            .init(loctable_key: "301973.title", xcstrings_key: "Compressed:"),
            .init(loctable_key: "101993.title", xcstrings_key: "Cached Files:"),
            .init(loctable_key: "301506.title", xcstrings_key: "Swap Used:"),
            .init(loctable_key: "100939.title", xcstrings_key: "n/a"),
        ]
    )
]

do {
    var translations: [String: [String: String]] = [:]

    for entry in entries {
        let path = entry.path
        let fileUrl = URL(fileURLWithPath: path)

        guard
            FileManager.default.fileExists(atPath: path),
            let dictionary = NSDictionary(contentsOf: fileUrl)
        else {
            print("File not found: \(path)")
            continue
        }

        for (code, localizations) in dictionary {
            guard let code = code as? String,
                code != "LocProvenance",
                let localization = localizations as? [String: Any]
            else {
                continue
            }

            for key in entry.keys {
                if let value = localization[key.loctable_key] as? String {
                    if translations[key.xcstrings_key] == nil {
                        translations[key.xcstrings_key] = [:]
                    }
                    translations[key.xcstrings_key]?[code] = value
                } else {
                    print("Missing key: \(key.loctable_key) in \(path) for code: \(code)")
                    exit(1)
                }
            }
        }
    }

    guard CommandLine.arguments.count > 1 else {
        print("Missing argument: path to Localizable.xcstrings")
        exit(1)
    }
    let xcstringsUrl = URL(fileURLWithPath: CommandLine.arguments[1])

    guard FileManager.default.fileExists(atPath: xcstringsUrl.path),
        let data = try? Data(contentsOf: xcstringsUrl),
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    else {
        print("Failed to load \(xcstringsUrl.path)")
        exit(1)
    }

    var xcstrings: [String: Any] = json
    var strings = xcstrings["strings"] as? [String: Any] ?? [:]

    for (key, translation) in translations {
        var existingLocalizations = (strings[key] as? [String: Any])?["localizations"] as? [String: Any] ?? [:]

        for (code, value) in translation {
            existingLocalizations[code] = [
                "stringUnit": [
                    "state": "translated",
                    "value": value,
                ]
            ]
        }

        strings[key] = ["localizations": existingLocalizations]
    }

    xcstrings["strings"] = strings

    let jsonData = try JSONSerialization.data(withJSONObject: xcstrings, options: [.prettyPrinted, .sortedKeys])
    try jsonData.write(to: xcstringsUrl)

    print("✅ File written to \(xcstringsUrl.path)")
} catch {
    print(error.localizedDescription)
}
