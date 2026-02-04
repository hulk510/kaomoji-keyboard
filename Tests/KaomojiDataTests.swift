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
        let happyExpr = Expression(id: "test", face: "test", category: "happy", tags: ["bright", "cute"], variations: nil)
        let hands = data.recommendedHands(for: happyExpr)
        // "none" は compatibleWith が空なのでスコア0、タグマッチするものが先頭に来る
        XCTAssertFalse(hands.isEmpty)
        if hands.count > 1 {
            XCTAssertNotEqual(hands.first?.id, "none", "none should not be first for happy expression")
        }
    }

    func testRecommendedHandsSortByMatchScore() {
        let data = KaomojiData.shared
        // タグが多くマッチする表情を使う
        let expr = Expression(id: "test", face: "test", category: "happy", tags: ["cute", "bright", "friendly"], variations: nil)
        let hands = data.recommendedHands(for: expr)
        // スコア順に降順ソートされていることを確認
        for i in 0..<hands.count - 1 {
            let score1 = Set(expr.tags).intersection(hands[i].compatibleWith).count
            let score2 = Set(expr.tags).intersection(hands[i + 1].compatibleWith).count
            XCTAssertGreaterThanOrEqual(score1, score2,
                "Hand '\(hands[i].id)' (score \(score1)) should be >= '\(hands[i + 1].id)' (score \(score2))")
        }
    }

    func testRecommendedDecorationsRespectTags() {
        let data = KaomojiData.shared
        let expr = Expression(id: "test", face: "test", category: "happy", tags: ["cute"], variations: nil)
        let decos = data.recommendedDecorations(for: expr)
        // タグ "cute" を持つ装飾がスコア0の装飾より前に来ること
        let firstMatchIndex = decos.firstIndex { $0.compatibleWith.contains("cute") }
        let firstNoMatchIndex = decos.firstIndex { !$0.compatibleWith.contains("cute") && $0.id != "none" }
        if let matchIdx = firstMatchIndex, let noMatchIdx = firstNoMatchIndex {
            XCTAssertLessThan(matchIdx, noMatchIdx,
                "Decorations matching tags should appear before non-matching ones")
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

    // MARK: - 顔パーツテスト

    func testFacePartsLoad() {
        let data = KaomojiData.shared
        XCTAssertFalse(data.faceParts.isEmpty, "faceParts should not be empty")
    }

    func testFacePartsByType() {
        let data = KaomojiData.shared
        for type in FacePartType.allCases {
            let parts = data.faceParts(for: type)
            XCTAssertFalse(parts.isEmpty, "\(type.rawValue) should have face parts")
            // 全パーツが正しい型であること
            for part in parts {
                XCTAssertEqual(part.type, type, "Part '\(part.id)' should be type \(type.rawValue)")
            }
        }
    }

    func testFacePartUniqueIDs() {
        let data = KaomojiData.shared
        let partIDs = data.faceParts.map(\.id)
        XCTAssertEqual(partIDs.count, Set(partIDs).count, "face part IDs must be unique")
    }

    func testFacePartVariationsExist() {
        let data = KaomojiData.shared
        let allIDs = Set(data.faceParts.map(\.id))
        for part in data.faceParts {
            for varID in part.variations {
                XCTAssertTrue(allIDs.contains(varID),
                    "Variation '\(varID)' referenced by '\(part.id)' does not exist")
            }
        }
    }

    func testVariationsReturnValidParts() {
        let data = KaomojiData.shared
        guard let firstPart = data.faceParts.first(where: { !$0.variations.isEmpty }) else {
            XCTFail("No face parts with variations found")
            return
        }
        let vars = data.variations(for: firstPart.id)
        XCTAssertFalse(vars.isEmpty, "Should return variations for '\(firstPart.id)'")
        XCTAssertEqual(vars.count, firstPart.variations.count)
    }

    func testExpressionVariationsExist() {
        let data = KaomojiData.shared
        let allIDs = Set(data.expressions.map(\.id))
        for expr in data.expressions {
            for varID in (expr.variations ?? []) {
                XCTAssertTrue(allIDs.contains(varID),
                    "Expression variation '\(varID)' referenced by '\(expr.id)' does not exist")
            }
        }
    }

    func testExpressionVariationsReturnValid() {
        let data = KaomojiData.shared
        guard let expr = data.expressions.first(where: { ($0.variations ?? []).isEmpty == false }) else {
            XCTFail("No expressions with variations found")
            return
        }
        let vars = data.expressionVariations(for: expr.id)
        XCTAssertFalse(vars.isEmpty)
        XCTAssertEqual(vars.count, (expr.variations ?? []).count)
    }

    func testRecommendedFaceParts() {
        let data = KaomojiData.shared
        let selectedPart = FacePart(id: "test", char: "´", type: .leftEye, tags: ["bright", "cute"], variations: [])
        let recommended = data.recommendedFaceParts(for: .mouth, selectedParts: [selectedPart])
        XCTAssertFalse(recommended.isEmpty)
    }
}
