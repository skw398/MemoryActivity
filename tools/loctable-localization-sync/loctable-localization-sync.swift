import Foundation

struct Entry {
    let path: String
    let keys: [Key]

    struct Key {
        let loctableKey: String
        let xcstringsKey: String
    }
}

struct CommandError: Error, CustomStringConvertible {
    let command: String
    let status: Int32

    var description: String {
        "\(command) exited with status \(status)"
    }
}

let entries: [Entry] = [
    Entry(
        path: "/System/Applications/Utilities/Activity Monitor.app/Contents/Resources/ActivityMonitor.loctable",
        keys: [
            .init(loctableKey: "301577.title", xcstringsKey: "MEMORY PRESSURE"),
            .init(loctableKey: "100849.title", xcstringsKey: "Physical Memory:"),
            .init(loctableKey: "101989.title", xcstringsKey: "Memory Used:"),
            .init(loctableKey: "100806.title", xcstringsKey: "App Memory:"),
            .init(loctableKey: "100802.title", xcstringsKey: "Wired Memory:"),
            .init(loctableKey: "301973.title", xcstringsKey: "Compressed:"),
            .init(loctableKey: "101993.title", xcstringsKey: "Cached Files:"),
            .init(loctableKey: "301506.title", xcstringsKey: "Swap Used:"),
            .init(loctableKey: "100939.title", xcstringsKey: "n/a"),
        ]
    ),
]

let fileManager = FileManager.default
let scriptURL = URL(fileURLWithPath: #filePath).standardizedFileURL
let rootURL = scriptURL
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
let projectURL = rootURL.appendingPathComponent("MemoryActivity.xcodeproj")
let exportURL = URL(fileURLWithPath: "/tmp/loctable-localization-sync-export")
let macOSVersionURL = scriptURL.deletingLastPathComponent().appendingPathComponent("macosversion.txt")

func run(_ executable: String, _ arguments: [String]) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    process.standardOutput = FileHandle.standardOutput
    process.standardError = FileHandle.standardError

    try process.run()
    process.waitUntilExit()

    guard process.terminationStatus == 0 else {
        throw CommandError(command: ([executable] + arguments).joined(separator: " "), status: process.terminationStatus)
    }
}

func capture(_ executable: String, _ arguments: [String]) throws -> Data {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    process.standardError = FileHandle.standardError

    let pipe = Pipe()
    process.standardOutput = pipe

    try process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()

    guard process.terminationStatus == 0 else {
        throw CommandError(command: ([executable] + arguments).joined(separator: " "), status: process.terminationStatus)
    }

    return data
}

func elements(named name: String, in element: XMLElement) -> [XMLElement] {
    (element.children ?? []).compactMap { node in
        guard let child = node as? XMLElement, child.localName == name else {
            return nil
        }
        return child
    }
}

func languageTag(from code: String) -> String {
    code.replacingOccurrences(of: "_", with: "-")
}

func loctableCode(from languageTag: String) -> String {
    languageTag.replacingOccurrences(of: "-", with: "_")
}

func xliffURLs(in directory: URL) -> [URL] {
    guard let enumerator = fileManager.enumerator(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
    ) else {
        return []
    }

    return enumerator.compactMap { item in
        guard let url = item as? URL, url.pathExtension == "xliff" else {
            return nil
        }
        return url
    }.sorted { $0.path < $1.path }
}

func collectTranslations() throws -> [String: [String: String]] {
    var translations: [String: [String: String]] = [:]

    for entry in entries {
        let fileURL = URL(fileURLWithPath: entry.path)

        guard
            fileManager.fileExists(atPath: entry.path),
            let dictionary = NSDictionary(contentsOf: fileURL)
        else {
            throw NSError(domain: "Loctable2Xcstrings", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "File not found: \(entry.path)",
            ])
        }

        for (codeValue, localizationsValue) in dictionary {
            guard
                let code = codeValue as? String,
                code != "LocProvenance"
            else {
                continue
            }

            guard let localization = localizationsValue as? [String: Any] else {
                throw NSError(domain: "Loctable2Xcstrings", code: 6, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid localization entry in \(entry.path) for code: \(code)",
                ])
            }

            for key in entry.keys {
                guard let value = localization[key.loctableKey] as? String else {
                    throw NSError(domain: "Loctable2Xcstrings", code: 2, userInfo: [
                        NSLocalizedDescriptionKey: "Missing key: \(key.loctableKey) in \(entry.path) for code: \(code)",
                    ])
                }

                translations[code, default: [:]][key.xcstringsKey] = value
            }
        }
    }

    return translations
}

func updateXLIFF(at url: URL, translations: [String: [String: String]]) throws -> String? {
    let document = try XMLDocument(contentsOf: url, options: [.nodePreserveWhitespace])

    guard let root = document.rootElement() else {
        throw NSError(domain: "Loctable2Xcstrings", code: 7, userInfo: [
            NSLocalizedDescriptionKey: "Missing root element in \(url.path)",
        ])
    }

    var updatedLanguage: String?
    var foundLocalizableFile = false

    for fileElement in elements(named: "file", in: root) {
        guard
            fileElement.attribute(forName: "original")?.stringValue == "MemoryActivity/Localizable.xcstrings"
        else {
            continue
        }

        foundLocalizableFile = true

        guard
            let targetLanguage = fileElement.attribute(forName: "target-language")?.stringValue,
            let languageTranslations = translations[loctableCode(from: targetLanguage)]
        else {
            throw NSError(domain: "Loctable2Xcstrings", code: 8, userInfo: [
                NSLocalizedDescriptionKey: "Missing or unsupported target language in \(url.path)",
            ])
        }

        guard let body = elements(named: "body", in: fileElement).first else {
            throw NSError(domain: "Loctable2Xcstrings", code: 9, userInfo: [
                NSLocalizedDescriptionKey: "Missing body in \(url.path)",
            ])
        }

        var remainingKeys = Set(languageTranslations.keys)

        for transUnit in elements(named: "trans-unit", in: body) {
            guard
                let id = transUnit.attribute(forName: "id")?.stringValue,
                let value = languageTranslations[id]
            else {
                continue
            }

            if let target = elements(named: "target", in: transUnit).first {
                target.setStringValue(value, resolvingEntities: false)
                target.removeAttribute(forName: "state")
                target.addAttribute(XMLNode.attribute(withName: "state", stringValue: "translated") as! XMLNode)
            } else {
                let target = XMLElement(name: "target", stringValue: value)
                target.addAttribute(XMLNode.attribute(withName: "state", stringValue: "translated") as! XMLNode)

                if let source = elements(named: "source", in: transUnit).first,
                   let sourceIndex = transUnit.children?.firstIndex(of: source) {
                    transUnit.insertChild(target, at: sourceIndex + 1)
                } else {
                    transUnit.addChild(target)
                }
            }

            remainingKeys.remove(id)
            updatedLanguage = targetLanguage
        }

        guard remainingKeys.isEmpty else {
            throw NSError(domain: "Loctable2Xcstrings", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "Missing trans-unit(s) in \(url.path): \(remainingKeys.sorted().joined(separator: ", "))",
            ])
        }
    }

    guard foundLocalizableFile else {
        throw NSError(domain: "Loctable2Xcstrings", code: 10, userInfo: [
            NSLocalizedDescriptionKey: "Missing Localizable.xcstrings file entry in \(url.path)",
        ])
    }

    guard let updatedLanguage else {
        throw NSError(domain: "Loctable2Xcstrings", code: 11, userInfo: [
            NSLocalizedDescriptionKey: "No Localizable.xcstrings translations were updated in \(url.path)",
        ])
    }

    let data = document.xmlData(options: [.nodePrettyPrint])
    try data.write(to: url, options: .atomic)

    return updatedLanguage
}

do {
    let translations = try collectTranslations()
    let languages = translations.keys.sorted().map(languageTag(from:))

    if fileManager.fileExists(atPath: exportURL.path) {
        try fileManager.removeItem(at: exportURL)
    }
    try fileManager.createDirectory(at: exportURL, withIntermediateDirectories: true)

    var exportArguments = [
        "xcodebuild",
        "-exportLocalizations",
        "-project", projectURL.path,
        "-localizationPath", exportURL.path,
    ]

    for language in languages {
        exportArguments.append(contentsOf: ["-exportLanguage", language])
    }

    try run("/usr/bin/xcrun", exportArguments)

    let xliffURLs = xliffURLs(in: exportURL)
    guard !xliffURLs.isEmpty else {
        throw NSError(domain: "Loctable2Xcstrings", code: 4, userInfo: [
            NSLocalizedDescriptionKey: "No XLIFF files were exported to \(exportURL.path)",
        ])
    }

    let expectedLanguages = Set(languages)
    var updatedLanguages: Set<String> = []
    for url in xliffURLs {
        if let language = try updateXLIFF(at: url, translations: translations) {
            updatedLanguages.insert(language)
        }
    }

    guard updatedLanguages == expectedLanguages else {
        let missing = expectedLanguages.subtracting(updatedLanguages).sorted()
        let unexpected = updatedLanguages.subtracting(expectedLanguages).sorted()
        throw NSError(domain: "Loctable2Xcstrings", code: 5, userInfo: [
            NSLocalizedDescriptionKey: "Updated languages did not match expected languages. Missing: \(missing.joined(separator: ", ")); unexpected: \(unexpected.joined(separator: ", "))",
        ])
    }

    let imports = try fileManager.contentsOfDirectory(
        at: exportURL,
        includingPropertiesForKeys: [.isDirectoryKey],
        options: [.skipsHiddenFiles]
    )
    .filter { $0.pathExtension == "xcloc" }
    .sorted { $0.path < $1.path }

    guard !imports.isEmpty else {
        throw NSError(domain: "Loctable2Xcstrings", code: 12, userInfo: [
            NSLocalizedDescriptionKey: "No xcloc packages were exported to \(exportURL.path)",
        ])
    }

    let importLanguages = Set(imports.map { $0.deletingPathExtension().lastPathComponent })
    guard importLanguages == expectedLanguages else {
        let missing = expectedLanguages.subtracting(importLanguages).sorted()
        let unexpected = importLanguages.subtracting(expectedLanguages).sorted()
        throw NSError(domain: "Loctable2Xcstrings", code: 13, userInfo: [
            NSLocalizedDescriptionKey: "Exported xcloc packages did not match expected languages. Missing: \(missing.joined(separator: ", ")); unexpected: \(unexpected.joined(separator: ", "))",
        ])
    }

    for url in imports {
        try run("/usr/bin/xcrun", [
            "xcodebuild",
            "-importLocalizations",
            "-project", projectURL.path,
            "-localizationPath", url.path,
        ])
    }

    let macOSVersion = try capture("/usr/bin/sw_vers", [])
    try macOSVersion.write(to: macOSVersionURL, options: .atomic)

    print("Updated \(updatedLanguages.count) XLIFF file(s) and imported localizations with xcodebuild.")
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
