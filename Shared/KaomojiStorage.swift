import Foundation

/// 顔文字の履歴・お気に入り永続化マネージャ
/// App Group UserDefaults経由（SharedSettingsパターン踏襲）
class KaomojiStorage {
    static let shared = KaomojiStorage()

    private let defaults: UserDefaults?
    private let historyKey = "kaomojiHistory"
    private let favoritesKey = "kaomojiFavorites"
    private let registeredKey = "kaomojiRegistered"
    private let maxHistoryCount = 50

    private init() {
        defaults = UserDefaults(suiteName: SharedSettings.groupID)
    }

    // MARK: - 履歴

    func addToHistory(_ kaomoji: String) {
        var history = getHistory()
        // 重複排除: 既存を削除してから先頭に追加
        history.removeAll { $0.kaomoji == kaomoji }
        let entry = SavedKaomoji(
            id: UUID(),
            kaomoji: kaomoji,
            createdAt: Date(),
            isFavorite: isFavorite(kaomoji)
        )
        history.insert(entry, at: 0)
        // 上限適用
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        saveHistory(history)
    }

    func getHistory() -> [SavedKaomoji] {
        guard let data = defaults?.data(forKey: historyKey),
              let items = try? JSONDecoder().decode([SavedKaomoji].self, from: data) else {
            return []
        }
        return items
    }

    private func saveHistory(_ items: [SavedKaomoji]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults?.set(data, forKey: historyKey)
    }

    // MARK: - お気に入り

    func addToFavorites(_ kaomoji: String) {
        var favorites = getFavorites()
        guard !favorites.contains(where: { $0.kaomoji == kaomoji }) else { return }
        let entry = SavedKaomoji(
            id: UUID(),
            kaomoji: kaomoji,
            createdAt: Date(),
            isFavorite: true
        )
        favorites.insert(entry, at: 0)
        saveFavorites(favorites)

        // 履歴内のisFavoriteフラグも更新
        var history = getHistory()
        for i in history.indices where history[i].kaomoji == kaomoji {
            history[i].isFavorite = true
        }
        saveHistory(history)
    }

    func removeFromFavorites(_ kaomoji: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0.kaomoji == kaomoji }
        saveFavorites(favorites)

        // 履歴内のisFavoriteフラグも更新
        var history = getHistory()
        for i in history.indices where history[i].kaomoji == kaomoji {
            history[i].isFavorite = false
        }
        saveHistory(history)
    }

    func getFavorites() -> [SavedKaomoji] {
        guard let data = defaults?.data(forKey: favoritesKey),
              let items = try? JSONDecoder().decode([SavedKaomoji].self, from: data) else {
            return []
        }
        return items
    }

    func isFavorite(_ kaomoji: String) -> Bool {
        getFavorites().contains { $0.kaomoji == kaomoji }
    }

    private func saveFavorites(_ items: [SavedKaomoji]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults?.set(data, forKey: favoritesKey)
    }

    // MARK: - 登録済み顔文字

    func getRegistered() -> [RegisteredKaomoji] {
        guard let data = defaults?.data(forKey: registeredKey),
              let items = try? JSONDecoder().decode([RegisteredKaomoji].self, from: data) else {
            return []
        }
        return items.sorted { $0.sortOrder < $1.sortOrder }
    }

    @discardableResult
    func addRegistered(_ kaomoji: String, builderState: BuilderState) -> RegisteredKaomoji {
        var items = getRegistered()
        let nextOrder = (items.map(\.sortOrder).max() ?? -1) + 1
        let entry = RegisteredKaomoji(
            id: UUID(),
            kaomoji: kaomoji,
            builderState: builderState,
            createdAt: Date(),
            sortOrder: nextOrder
        )
        items.append(entry)
        saveRegistered(items)
        return entry
    }

    func updateRegistered(_ id: UUID, kaomoji: String, builderState: BuilderState) {
        var items = getRegistered()
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let updated = RegisteredKaomoji(
            id: id,
            kaomoji: kaomoji,
            builderState: builderState,
            createdAt: items[index].createdAt,
            sortOrder: items[index].sortOrder
        )
        items[index] = updated
        saveRegistered(items)
    }

    func removeRegistered(_ id: UUID) {
        var items = getRegistered()
        items.removeAll { $0.id == id }
        saveRegistered(items)
    }

    func reorderRegistered(_ ids: [UUID]) {
        let items = getRegistered()
        var reordered: [RegisteredKaomoji] = []
        for (index, id) in ids.enumerated() {
            if var item = items.first(where: { $0.id == id }) {
                item.sortOrder = index
                reordered.append(item)
            }
        }
        // 含まれなかったアイテムも保持
        for item in items where !ids.contains(item.id) {
            reordered.append(item)
        }
        saveRegistered(reordered)
    }

    private func saveRegistered(_ items: [RegisteredKaomoji]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults?.set(data, forKey: registeredKey)
    }
}
