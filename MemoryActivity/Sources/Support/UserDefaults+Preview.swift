import Foundation

extension UserDefaults {
    static func preview(applying values: [String: Any] = [:]) -> Self {
        let defaults = Self(suiteName: "preview")!
        for (key, value) in values {
            defaults.set(value, forKey: key)
        }
        return defaults
    }
}
