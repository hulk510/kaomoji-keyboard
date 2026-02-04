import XCTest
@testable import KaomojiKeyboard

final class KaomojiBuilderTests: XCTestCase {

    func testEmptyBuild() {
        let builder = KaomojiBuilder()
        XCTAssertEqual(builder.build(), "")
        XCTAssertFalse(builder.hasSelection)
    }

    func testPreviewWhenEmpty() {
        let builder = KaomojiBuilder()
        XCTAssertEqual(builder.preview(), "")
    }

    func testBuildWithExpressionOnly() {
        var builder = KaomojiBuilder()
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [])
        // デフォルト枠 ()
        XCTAssertEqual(builder.build(), "(´∀`)")
    }

    func testBuildWithAllParts() {
        var builder = KaomojiBuilder()
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [])
        builder.bracket = Bracket(id: "b1", open: "（", close: "）")
        builder.hand = Hand(id: "h1", left: "ヽ", right: "ノ", compatibleWith: [])
        builder.decoration = Decoration(id: "d1", char: "✧", compatibleWith: [])
        builder.action = Action(id: "a1", suffix: "ﾉｼ", compatibleWith: [])
        XCTAssertEqual(builder.build(), "✧ヽ（´∀`）ノ✧ﾉｼ")
    }

    func testBuildWithNoBracket() {
        var builder = KaomojiBuilder()
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [])
        builder.bracket = Bracket(id: "none", open: "", close: "")
        XCTAssertEqual(builder.build(), "´∀`")
    }

    func testPreviewWithoutExpression() {
        var builder = KaomojiBuilder()
        builder.bracket = Bracket(id: "b1", open: "(", close: ")")
        builder.hand = Hand(id: "h1", left: "ヽ", right: "ノ", compatibleWith: [])
        // 表情なしでもパーツ構造が見える
        XCTAssertEqual(builder.preview(), "ヽ(__)ノ")
    }

    func testReset() {
        var builder = KaomojiBuilder()
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [])
        builder.bracket = Bracket(id: "b1", open: "(", close: ")")
        builder.reset()
        XCTAssertFalse(builder.hasSelection)
        XCTAssertNil(builder.expression)
        XCTAssertNil(builder.bracket)
        XCTAssertNil(builder.hand)
        XCTAssertNil(builder.decoration)
        XCTAssertNil(builder.action)
    }

    func testHasSelection() {
        var builder = KaomojiBuilder()
        XCTAssertFalse(builder.hasSelection)
        builder.decoration = Decoration(id: "d1", char: "♡", compatibleWith: [])
        XCTAssertTrue(builder.hasSelection)
    }
}
