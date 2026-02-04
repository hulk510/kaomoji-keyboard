import XCTest
@testable import KaomojiKeyboard

final class KaomojiDataTests: XCTestCase {

    func testDataLoads() {
        let data = KaomojiData.shared
        XCTAssertFalse(data.expressions.isEmpty, "expressions should not be empty")
        XCTAssertFalse(data.brackets.isEmpty, "brackets should not be empty")
        XCTAssertFalse(data.hands.isEmpty, "hands should not be empty")
        XCTAssertFalse(data.decorations.isEmpty, "decorations should not be empty")
        XCTAssertFalse(data.actions.isEmpty, "actions should not be empty")
    }

    func testAllCategoriesHaveExpressions() {
        let data = KaomojiData.shared
        for category in ExpressionCategory.allCases {
            let expressions = data.expressions(for: category)
            XCTAssertFalse(expressions.isEmpty, "\(category.rawValue) should have expressions")
        }
    }

    func testNoneOptionsExist() {
        let data = KaomojiData.shared
        XCTAssertTrue(data.brackets.contains { $0.id == "none" }, "brackets should have 'none'")
        XCTAssertTrue(data.hands.contains { $0.id == "none" }, "hands should have 'none'")
        XCTAssertTrue(data.decorations.contains { $0.id == "none" }, "decorations should have 'none'")
        XCTAssertTrue(data.actions.contains { $0.id == "none" }, "actions should have 'none'")
    }

    func testUniqueIDs() {
        let data = KaomojiData.shared
        let exprIDs = data.expressions.map(\.id)
        XCTAssertEqual(exprIDs.count, Set(exprIDs).count, "expression IDs must be unique")

        let bracketIDs = data.brackets.map(\.id)
        XCTAssertEqual(bracketIDs.count, Set(bracketIDs).count, "bracket IDs must be unique")

        let handIDs = data.hands.map(\.id)
        XCTAssertEqual(handIDs.count, Set(handIDs).count, "hand IDs must be unique")

        let decoIDs = data.decorations.map(\.id)
        XCTAssertEqual(decoIDs.count, Set(decoIDs).count, "decoration IDs must be unique")

        let actionIDs = data.actions.map(\.id)
        XCTAssertEqual(actionIDs.count, Set(actionIDs).count, "action IDs must be unique")
    }

    func testRecommendedSorting() {
        let data = KaomojiData.shared
        let happyExpr = Expression(id: "test", face: "test", category: "happy", tags: ["bright", "cute"])
        let hands = data.recommendedHands(for: happyExpr)
        // "none" は compatibleWith が空なのでスコア0、タグマッチするものが先頭に来る
        XCTAssertFalse(hands.isEmpty)
        if hands.count > 1 {
            XCTAssertNotEqual(hands.first?.id, "none", "none should not be first for happy expression")
        }
    }

    func testNoEmojiInDecorations() {
        let data = KaomojiData.shared
        for deco in data.decorations {
            for scalar in deco.char.unicodeScalars {
                // Emoji_Presentation のスカラーを拒否（記号系は許可）
                if scalar.properties.isEmojiPresentation {
                    XCTFail("Decoration '\(deco.id)' contains emoji: \(deco.char)")
                }
            }
        }
    }

    func testNoEmojiInHands() {
        let data = KaomojiData.shared
        for hand in data.hands {
            for scalar in (hand.left + hand.right).unicodeScalars {
                if scalar.properties.isEmojiPresentation {
                    XCTFail("Hand '\(hand.id)' contains emoji: \(hand.left) \(hand.right)")
                }
            }
        }
    }
}
