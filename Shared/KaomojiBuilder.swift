import Foundation

struct KaomojiBuilder {
    var expression: Expression?
    var bracket: Bracket?
    var hand: Hand?
    var decoration: Decoration?
    var action: Action?

    // 顔文字を組み立てる
    // 組み立て順序: [装飾][手][枠開][表情][枠閉][手][装飾][アクション]
    func build() -> String {
        guard let expression = expression else {
            return ""
        }

        let bracketOpen = bracket?.open ?? "("
        let bracketClose = bracket?.close ?? ")"
        let leftHand = hand?.left ?? ""
        let rightHand = hand?.right ?? ""
        let leftDecoration = decoration?.char ?? ""
        let rightDecoration = decoration?.char ?? ""
        let actionSuffix = action?.suffix ?? ""

        return "\(leftDecoration)\(leftHand)\(bracketOpen)\(expression.face)\(bracketClose)\(rightHand)\(rightDecoration)\(actionSuffix)"
    }

    // プレビュー用
    func preview() -> String {
        if !hasSelection {
            return ""  // 空 → View側でプレースホルダー表示
        }

        // 表情未選択でも他パーツの構成を見せる
        let face = expression?.face ?? "__"
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
    }

    // 何か選択されているか
    var hasSelection: Bool {
        expression != nil || bracket != nil || hand != nil || decoration != nil || action != nil
    }
}
