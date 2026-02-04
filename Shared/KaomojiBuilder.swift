import Foundation

struct KaomojiBuilder {
    var expression: Expression?
    var bracket: Bracket?
    var hand: Hand?
    var decoration: Decoration?
    var action: Action?

    // パーツモード用（テンプレの部分上書き）
    var leftEye: FacePart?
    var mouth: FacePart?
    var rightEye: FacePart?

    /// テンプレベースの表情文字列からパーツ上書きを適用した最終的な顔文字列
    /// - テンプレのみ → テンプレのface
    /// - パーツのみ → leftEye.char + mouth.char + rightEye.char
    /// - テンプレ＋パーツ → テンプレをベースにパーツで指定した部分だけ置き換え
    var faceString: String? {
        let hasExpression = expression != nil
        let hasParts = leftEye != nil || mouth != nil || rightEye != nil

        if hasExpression && !hasParts {
            return expression!.face
        }

        if hasParts && !hasExpression {
            let l = leftEye?.char ?? ""
            let m = mouth?.char ?? ""
            let r = rightEye?.char ?? ""
            return l + m + r
        }

        if hasExpression && hasParts {
            // テンプレをベースにして、パーツで指定された部分だけ置き換え
            // テンプレのfaceを3分割（左目、口、右目）して上書き
            let baseFace = expression!.face
            let parts = splitFace(baseFace)
            let l = leftEye?.char ?? parts.left
            let m = mouth?.char ?? parts.mouth
            let r = rightEye?.char ?? parts.right
            return l + m + r
        }

        return nil
    }

    // 顔文字を組み立てる
    // 組み立て順序: [装飾][手][枠開][表情][枠閉][手][装飾][アクション]
    func build() -> String {
        guard let face = faceString else {
            return ""
        }

        let bracketOpen = bracket?.open ?? "("
        let bracketClose = bracket?.close ?? ")"
        let leftHand = hand?.left ?? ""
        let rightHand = hand?.right ?? ""
        let leftDecoration = decoration?.char ?? ""
        let rightDecoration = decoration?.char ?? ""
        let actionSuffix = action?.suffix ?? ""

        return "\(leftDecoration)\(leftHand)\(bracketOpen)\(face)\(bracketClose)\(rightHand)\(rightDecoration)\(actionSuffix)"
    }

    // プレビュー用
    func preview() -> String {
        if !hasSelection {
            return ""  // 空 → View側でプレースホルダー表示
        }

        // 表情未選択でも他パーツの構成を見せる
        let face = faceString ?? "__"
        let bracketOpen = bracket?.open ?? "("
        let bracketClose = bracket?.close ?? ")"
        let leftHand = hand?.left ?? ""
        let rightHand = hand?.right ?? ""
        let leftDecoration = decoration?.char ?? ""
        let rightDecoration = decoration?.char ?? ""
        let actionSuffix = action?.suffix ?? ""

        return "\(leftDecoration)\(leftHand)\(bracketOpen)\(face)\(bracketClose)\(rightHand)\(rightDecoration)\(actionSuffix)"
    }

    // リセット
    mutating func reset() {
        expression = nil
        bracket = nil
        hand = nil
        decoration = nil
        action = nil
        leftEye = nil
        mouth = nil
        rightEye = nil
    }

    // 何か選択されているか
    var hasSelection: Bool {
        expression != nil || bracket != nil || hand != nil || decoration != nil || action != nil
            || leftEye != nil || mouth != nil || rightEye != nil
    }

    // MARK: - 状態のシリアライズ/デシリアライズ

    /// 現在の選択状態をBuilderStateにシリアライズ
    func toBuilderState() -> BuilderState {
        BuilderState(
            expressionID: expression?.id,
            bracketID: bracket?.id,
            handID: hand?.id,
            decorationID: decoration?.id,
            actionID: action?.id,
            leftEyeID: leftEye?.id,
            mouthID: mouth?.id,
            rightEyeID: rightEye?.id
        )
    }

    /// BuilderStateからビルダーを復元
    mutating func restore(from state: BuilderState, data: KaomojiData) {
        expression = state.expressionID.flatMap { id in data.expressions.first { $0.id == id } }
        bracket = state.bracketID.flatMap { id in data.brackets.first { $0.id == id } }
        hand = state.handID.flatMap { id in data.hands.first { $0.id == id } }
        decoration = state.decorationID.flatMap { id in data.decorations.first { $0.id == id } }
        action = state.actionID.flatMap { id in data.actions.first { $0.id == id } }
        leftEye = state.leftEyeID.flatMap { id in data.faceParts.first { $0.id == id } }
        mouth = state.mouthID.flatMap { id in data.faceParts.first { $0.id == id } }
        rightEye = state.rightEyeID.flatMap { id in data.faceParts.first { $0.id == id } }
    }

    // MARK: - 顔文字分割ユーティリティ

    /// 顔文字の表情文字列を左目・口・右目に3分割する
    /// 大まかにcharacter数で3等分する簡易的なアプローチ
    private func splitFace(_ face: String) -> (left: String, mouth: String, right: String) {
        let chars = Array(face)
        let count = chars.count
        guard count >= 3 else {
            // 短すぎる場合はそのまま
            if count == 0 { return ("", "", "") }
            if count == 1 { return ("", String(chars[0]), "") }
            if count == 2 { return (String(chars[0]), "", String(chars[1])) }
            return ("", face, "")
        }
        let third = count / 3
        let remainder = count % 3
        // 口に余りを割り当て
        let leftCount = third
        let mouthCount = third + remainder
        let left = String(chars[0..<leftCount])
        let mouth = String(chars[leftCount..<(leftCount + mouthCount)])
        let right = String(chars[(leftCount + mouthCount)..<count])
        return (left, mouth, right)
    }
}
