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
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [], variations: nil)
        // デフォルト枠 ()
        XCTAssertEqual(builder.build(), "(´∀`)")
    }

    func testBuildWithAllParts() {
        var builder = KaomojiBuilder()
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [], variations: nil)
        builder.bracket = Bracket(id: "b1", open: "（", close: "）")
        builder.hand = Hand(id: "h1", left: "ヽ", right: "ノ", compatibleWith: [])
        builder.decoration = Decoration(id: "d1", char: "✧", compatibleWith: [])
        builder.action = Action(id: "a1", suffix: "ﾉｼ", compatibleWith: [])
        XCTAssertEqual(builder.build(), "✧ヽ（´∀`）ノ✧ﾉｼ")
    }

    func testBuildWithNoBracket() {
        var builder = KaomojiBuilder()
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [], variations: nil)
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
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [], variations: nil)
        builder.bracket = Bracket(id: "b1", open: "(", close: ")")
        builder.reset()
        XCTAssertFalse(builder.hasSelection)
        XCTAssertNil(builder.expression)
        XCTAssertNil(builder.bracket)
        XCTAssertNil(builder.hand)
        XCTAssertNil(builder.decoration)
        XCTAssertNil(builder.action)
        XCTAssertNil(builder.leftEye)
        XCTAssertNil(builder.mouth)
        XCTAssertNil(builder.rightEye)
    }

    func testHasSelection() {
        var builder = KaomojiBuilder()
        XCTAssertFalse(builder.hasSelection)
        builder.decoration = Decoration(id: "d1", char: "♡", compatibleWith: [])
        XCTAssertTrue(builder.hasSelection)
    }

    // MARK: - パーツモードテスト

    func testBuildWithPartsOnly() {
        var builder = KaomojiBuilder()
        builder.leftEye = FacePart(id: "le1", char: "´", type: .leftEye, tags: [], variations: [])
        builder.mouth = FacePart(id: "m1", char: "ω", type: .mouth, tags: [], variations: [])
        builder.rightEye = FacePart(id: "re1", char: "`", type: .rightEye, tags: [], variations: [])
        XCTAssertEqual(builder.build(), "(´ω`)")
    }

    func testPartsOnlyFaceString() {
        var builder = KaomojiBuilder()
        builder.leftEye = FacePart(id: "le1", char: "◕", type: .leftEye, tags: [], variations: [])
        builder.mouth = FacePart(id: "m1", char: "‿", type: .mouth, tags: [], variations: [])
        builder.rightEye = FacePart(id: "re1", char: "◕", type: .rightEye, tags: [], variations: [])
        XCTAssertEqual(builder.faceString, "◕‿◕")
    }

    func testMergeModeTemplateAndParts() {
        var builder = KaomojiBuilder()
        // テンプレ "´∀`" → 左目=´, 口=∀, 右目=`
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [], variations: nil)
        // 口だけ上書き
        builder.mouth = FacePart(id: "m1", char: "ω", type: .mouth, tags: [], variations: [])
        let face = builder.faceString!
        XCTAssertTrue(face.contains("ω"), "Mouth should be overridden to ω, got: \(face)")
    }

    func testMergeModeKeepsTemplate() {
        var builder = KaomojiBuilder()
        // テンプレを設定
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [], variations: nil)
        // パーツで左目だけ上書き
        builder.leftEye = FacePart(id: "le1", char: "◕", type: .leftEye, tags: [], variations: [])
        // expressionは残っているはず
        XCTAssertNotNil(builder.expression)
        XCTAssertNotNil(builder.leftEye)
    }

    func testPartsModePreview() {
        var builder = KaomojiBuilder()
        builder.leftEye = FacePart(id: "le1", char: "◕", type: .leftEye, tags: [], variations: [])
        // 口と右目は未選択
        let preview = builder.preview()
        XCTAssertTrue(preview.contains("◕"), "Preview should contain the left eye")
        XCTAssertTrue(builder.hasSelection)
    }

    func testPartsWithBracketAndHand() {
        var builder = KaomojiBuilder()
        builder.leftEye = FacePart(id: "le1", char: "´", type: .leftEye, tags: [], variations: [])
        builder.mouth = FacePart(id: "m1", char: "∀", type: .mouth, tags: [], variations: [])
        builder.rightEye = FacePart(id: "re1", char: "`", type: .rightEye, tags: [], variations: [])
        builder.bracket = Bracket(id: "b1", open: "（", close: "）")
        builder.hand = Hand(id: "h1", left: "ヽ", right: "ノ", compatibleWith: [])
        XCTAssertEqual(builder.build(), "ヽ（´∀`）ノ")
    }

    func testResetClearsParts() {
        var builder = KaomojiBuilder()
        builder.leftEye = FacePart(id: "le1", char: "´", type: .leftEye, tags: [], variations: [])
        builder.mouth = FacePart(id: "m1", char: "ω", type: .mouth, tags: [], variations: [])
        builder.reset()
        XCTAssertNil(builder.leftEye)
        XCTAssertNil(builder.mouth)
        XCTAssertNil(builder.rightEye)
        XCTAssertFalse(builder.hasSelection)
    }

    func testHasSelectionWithPartsOnly() {
        var builder = KaomojiBuilder()
        builder.leftEye = FacePart(id: "le1", char: "´", type: .leftEye, tags: [], variations: [])
        XCTAssertTrue(builder.hasSelection)
    }

    func testFaceStringSplitBasic() {
        var builder = KaomojiBuilder()
        // "´∀`" は3文字 → 各1文字: 左=´, 口=∀, 右=`
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [], variations: nil)
        // パーツなし → テンプレそのまま
        XCTAssertEqual(builder.faceString, "´∀`")
    }

    func testFaceStringPartialOverride() {
        var builder = KaomojiBuilder()
        // "´∀`" → 左=´, 口=∀, 右=`
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [], variations: nil)
        // 右目だけ上書き
        builder.rightEye = FacePart(id: "re1", char: "ˋ", type: .rightEye, tags: [], variations: [])
        let face = builder.faceString!
        // 最後がˋに変わっているはず
        XCTAssertTrue(face.hasSuffix("ˋ"), "Right eye should be overridden, got: \(face)")
    }

    func testFaceStringNilWhenNothingSelected() {
        let builder = KaomojiBuilder()
        XCTAssertNil(builder.faceString)
    }

    func testPartialPartsOnlyMode() {
        var builder = KaomojiBuilder()
        // 左目だけ
        builder.leftEye = FacePart(id: "le1", char: "◕", type: .leftEye, tags: [], variations: [])
        // 口と右目は空文字
        XCTAssertEqual(builder.faceString, "◕")
    }

    // MARK: - BuilderState テスト

    func testToBuilderState() {
        var builder = KaomojiBuilder()
        builder.expression = Expression(id: "t1", face: "´∀`", category: "happy", tags: [], variations: nil)
        builder.bracket = Bracket(id: "b1", open: "(", close: ")")
        builder.hand = Hand(id: "h1", left: "ヽ", right: "ノ", compatibleWith: [])
        builder.decoration = Decoration(id: "d1", char: "✧", compatibleWith: [])
        builder.action = Action(id: "a1", suffix: "ﾉｼ", compatibleWith: [])
        builder.leftEye = FacePart(id: "le1", char: "´", type: .leftEye, tags: [], variations: [])
        builder.mouth = FacePart(id: "m1", char: "ω", type: .mouth, tags: [], variations: [])
        builder.rightEye = FacePart(id: "re1", char: "`", type: .rightEye, tags: [], variations: [])

        let state = builder.toBuilderState()
        XCTAssertEqual(state.expressionID, "t1")
        XCTAssertEqual(state.bracketID, "b1")
        XCTAssertEqual(state.handID, "h1")
        XCTAssertEqual(state.decorationID, "d1")
        XCTAssertEqual(state.actionID, "a1")
        XCTAssertEqual(state.leftEyeID, "le1")
        XCTAssertEqual(state.mouthID, "m1")
        XCTAssertEqual(state.rightEyeID, "re1")
    }

    func testRestoreFromBuilderState() {
        let data = KaomojiData.shared
        // 実データから最初の表情と枠を使ってビルダーを構成
        var original = KaomojiBuilder()
        if let expr = data.expressions.first {
            original.expression = expr
        }
        if let bracket = data.brackets.first {
            original.bracket = bracket
        }
        let originalResult = original.build()
        let state = original.toBuilderState()

        // 復元
        var restored = KaomojiBuilder()
        restored.restore(from: state, data: data)
        let restoredResult = restored.build()

        XCTAssertEqual(originalResult, restoredResult)
    }

    func testBuilderStateCodable() {
        let state = BuilderState(
            expressionID: "t1",
            bracketID: "b1",
            handID: "h1",
            decorationID: "d1",
            actionID: "a1",
            leftEyeID: "le1",
            mouthID: "m1",
            rightEyeID: "re1"
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        guard let data = try? encoder.encode(state),
              let decoded = try? decoder.decode(BuilderState.self, from: data) else {
            XCTFail("BuilderState should encode/decode")
            return
        }
        XCTAssertEqual(state, decoded)
    }
}
