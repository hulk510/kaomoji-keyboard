import XCTest
@testable import KaomojiKeyboard

final class PerformanceTests: XCTestCase {

    func testDataLoadPerformance() {
        // JSONパース + カテゴリ分類が十分高速であること
        measure {
            let url = Bundle.main.url(forResource: "expressions", withExtension: "json")!
            let data = try! Data(contentsOf: url)
            _ = try! JSONDecoder().decode(KaomojiDataSet.self, from: data)
        }
    }

    func testCategoryFilterPerformance() {
        let data = KaomojiData.shared
        measure {
            for _ in 0..<100 {
                for category in ExpressionCategory.allCases {
                    _ = data.expressions(for: category)
                }
            }
        }
    }

    func testRecommendationPerformance() {
        let data = KaomojiData.shared
        let expr = data.expressions.first!
        measure {
            for _ in 0..<100 {
                _ = data.recommendedHands(for: expr)
                _ = data.recommendedDecorations(for: expr)
                _ = data.recommendedActions(for: expr)
            }
        }
    }

    func testBuildPerformance() {
        var builder = KaomojiBuilder()
        builder.expression = Expression(id: "t", face: "´∀`", category: "happy", tags: [], variations: nil)
        builder.bracket = Bracket(id: "b", open: "(", close: ")")
        builder.hand = Hand(id: "h", left: "ヽ", right: "ノ", compatibleWith: [])
        builder.decoration = Decoration(id: "d", char: "✧", compatibleWith: [])
        builder.action = Action(id: "a", suffix: "ﾉ", compatibleWith: [])
        measure {
            for _ in 0..<1000 {
                _ = builder.build()
            }
        }
    }

    func testJSONSizeUnderLimit() {
        // expressions.json が 50KB 以下であること（メモリ効率）
        let url = Bundle.main.url(forResource: "expressions", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        XCTAssertLessThan(data.count, 50_000, "expressions.json should be under 50KB, got \(data.count) bytes")
    }

    func testTotalPartsCount() {
        // パーツ総数が妥当な範囲であること（メモリ予算）
        let data = KaomojiData.shared
        let total = data.expressions.count + data.brackets.count + data.hands.count
            + data.decorations.count + data.actions.count + data.faceParts.count
        XCTAssertLessThan(total, 400, "Total parts should be under 400, got \(total)")
    }

    func testFacePartsFilterPerformance() {
        let data = KaomojiData.shared
        measure {
            for _ in 0..<100 {
                for type in FacePartType.allCases {
                    _ = data.faceParts(for: type)
                }
            }
        }
    }

    func testVariationLookupPerformance() {
        let data = KaomojiData.shared
        let partIDs = data.faceParts.map(\.id)
        measure {
            for _ in 0..<100 {
                for id in partIDs {
                    _ = data.variations(for: id)
                }
            }
        }
    }
}
