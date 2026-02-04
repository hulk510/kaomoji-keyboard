import Foundation

/// App Group経由の共有設定マネージャ
/// メインアプリで書き込み → キーボードエクステンションで読み取り
struct SharedSettings {
    static let groupID = "group.com.tsugu-labs.KaomojiKeyboard"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: groupID)
    }

    // MARK: - 設定キー

    private enum Key {
        static let gridColumns = "gridColumns"
        static let defaultBracketID = "defaultBracketID"
        static let hiddenTabs = "hiddenTabs"
        static let featureFlags = "featureFlags"
    }

    // MARK: - グリッド列数（デフォルト4）

    static var gridColumns: Int {
        get { defaults?.integer(forKey: Key.gridColumns).nonZero ?? 4 }
        set { defaults?.set(newValue, forKey: Key.gridColumns) }
    }

    // MARK: - デフォルト枠

    static var defaultBracketID: String {
        get { defaults?.string(forKey: Key.defaultBracketID) ?? "round" }
        set { defaults?.set(newValue, forKey: Key.defaultBracketID) }
    }

    // MARK: - 非表示タブ

    static var hiddenTabs: [String] {
        get { defaults?.stringArray(forKey: Key.hiddenTabs) ?? [] }
        set { defaults?.set(newValue, forKey: Key.hiddenTabs) }
    }

    // MARK: - Feature Flags

    static func featureFlag(_ name: String) -> Bool {
        guard let flags = defaults?.dictionary(forKey: Key.featureFlags) as? [String: Bool] else {
            return false
        }
        return flags[name] ?? false
    }

    static func setFeatureFlags(_ flags: [String: Bool]) {
        defaults?.set(flags, forKey: Key.featureFlags)
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
