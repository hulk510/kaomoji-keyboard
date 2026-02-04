import XCTest
@testable import KaomojiKeyboard

final class KaomojiStorageTests: XCTestCase {

    private var storage: KaomojiStorage!

    override func setUp() {
        super.setUp()
        storage = KaomojiStorage.shared
        // テスト前にクリア
        clearStorage()
    }

    override func tearDown() {
        clearStorage()
        super.tearDown()
    }

    private func clearStorage() {
        let defaults = UserDefaults(suiteName: SharedSettings.groupID)
        defaults?.removeObject(forKey: "kaomojiHistory")
        defaults?.removeObject(forKey: "kaomojiFavorites")
        defaults?.removeObject(forKey: "kaomojiRegistered")
    }

    // MARK: - 履歴テスト

    func testAddToHistory() {
        storage.addToHistory("(´∀`)")
        let history = storage.getHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.kaomoji, "(´∀`)")
    }

    func testHistoryDeduplication() {
        storage.addToHistory("(´∀`)")
        storage.addToHistory("(･ω･)")
        storage.addToHistory("(´∀`)")  // 重複
        let history = storage.getHistory()
        XCTAssertEqual(history.count, 2)
        // 最新が先頭
        XCTAssertEqual(history.first?.kaomoji, "(´∀`)")
    }

    func testHistoryMaxLimit() {
        for i in 0..<60 {
            storage.addToHistory("kaomoji_\(i)")
        }
        let history = storage.getHistory()
        XCTAssertLessThanOrEqual(history.count, 50)
    }

    func testHistoryOrder() {
        storage.addToHistory("first")
        storage.addToHistory("second")
        storage.addToHistory("third")
        let history = storage.getHistory()
        XCTAssertEqual(history.first?.kaomoji, "third")
        XCTAssertEqual(history.last?.kaomoji, "first")
    }

    // MARK: - お気に入りテスト

    func testAddToFavorites() {
        storage.addToFavorites("(´∀`)")
        XCTAssertTrue(storage.isFavorite("(´∀`)"))
        let favorites = storage.getFavorites()
        XCTAssertEqual(favorites.count, 1)
    }

    func testRemoveFromFavorites() {
        storage.addToFavorites("(´∀`)")
        storage.removeFromFavorites("(´∀`)")
        XCTAssertFalse(storage.isFavorite("(´∀`)"))
        XCTAssertTrue(storage.getFavorites().isEmpty)
    }

    func testFavoriteDeduplication() {
        storage.addToFavorites("(´∀`)")
        storage.addToFavorites("(´∀`)")  // 重複追加は無視
        XCTAssertEqual(storage.getFavorites().count, 1)
    }

    func testFavoriteStatusInHistory() {
        storage.addToHistory("(´∀`)")
        storage.addToFavorites("(´∀`)")
        let history = storage.getHistory()
        XCTAssertTrue(history.first?.isFavorite == true)
    }

    func testUnfavoriteUpdatesHistory() {
        storage.addToHistory("(´∀`)")
        storage.addToFavorites("(´∀`)")
        storage.removeFromFavorites("(´∀`)")
        let history = storage.getHistory()
        XCTAssertTrue(history.first?.isFavorite == false)
    }

    // MARK: - 登録済み顔文字テスト

    func testAddRegistered() {
        let state = BuilderState(expressionID: "t1")
        let entry = storage.addRegistered("(´∀`)", builderState: state)
        XCTAssertEqual(entry.kaomoji, "(´∀`)")
        let items = storage.getRegistered()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.kaomoji, "(´∀`)")
        XCTAssertEqual(items.first?.builderState.expressionID, "t1")
    }

    func testRemoveRegistered() {
        let state = BuilderState(expressionID: "t1")
        let entry = storage.addRegistered("(´∀`)", builderState: state)
        storage.removeRegistered(entry.id)
        XCTAssertTrue(storage.getRegistered().isEmpty)
    }

    func testUpdateRegistered() {
        let state = BuilderState(expressionID: "t1")
        let entry = storage.addRegistered("(´∀`)", builderState: state)
        let newState = BuilderState(expressionID: "t2", bracketID: "b1")
        storage.updateRegistered(entry.id, kaomoji: "(´ω`)", builderState: newState)
        let items = storage.getRegistered()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.kaomoji, "(´ω`)")
        XCTAssertEqual(items.first?.builderState.expressionID, "t2")
        XCTAssertEqual(items.first?.builderState.bracketID, "b1")
    }

    func testReorderRegistered() {
        let state = BuilderState()
        let a = storage.addRegistered("aaa", builderState: state)
        let b = storage.addRegistered("bbb", builderState: state)
        let c = storage.addRegistered("ccc", builderState: state)
        // 逆順に並び替え
        storage.reorderRegistered([c.id, b.id, a.id])
        let items = storage.getRegistered()
        XCTAssertEqual(items.map(\.kaomoji), ["ccc", "bbb", "aaa"])
    }

    func testRegisteredSortOrder() {
        let state = BuilderState()
        let a = storage.addRegistered("aaa", builderState: state)
        let b = storage.addRegistered("bbb", builderState: state)
        XCTAssertEqual(a.sortOrder, 0)
        XCTAssertEqual(b.sortOrder, 1)
        let items = storage.getRegistered()
        XCTAssertEqual(items.first?.kaomoji, "aaa")
        XCTAssertEqual(items.last?.kaomoji, "bbb")
    }
}
