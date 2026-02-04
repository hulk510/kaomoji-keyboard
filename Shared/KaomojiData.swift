import Foundation

class KaomojiData {
    static let shared = KaomojiData()

    let expressions: [Expression]
    let brackets: [Bracket]
    let hands: [Hand]
    let decorations: [Decoration]
    let actions: [Action]

    private init() {
        // JSONファイルを読み込む
        guard let url = Bundle.main.url(forResource: "expressions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dataSet = try? JSONDecoder().decode(KaomojiDataSet.self, from: data) else {
            // フォールバック（読み込み失敗時）
            self.expressions = []
            self.brackets = [Bracket(id: "round", open: "(", close: ")")]
            self.hands = [Hand(id: "none", left: "", right: "", compatibleWith: [])]
            self.decorations = [Decoration(id: "none", char: "", compatibleWith: [])]
            self.actions = [Action(id: "none", suffix: "", compatibleWith: [])]
            return
        }

        self.expressions = dataSet.expressions
        self.brackets = dataSet.brackets
        self.hands = dataSet.hands
        self.decorations = dataSet.decorations
        self.actions = dataSet.actions
    }

    // MARK: - カテゴリでフィルタリング

    func expressions(for category: ExpressionCategory) -> [Expression] {
        expressions.filter { $0.category == category.rawValue }
    }

    // MARK: - おすすめ機能（相性ベース）

    func recommendedHands(for expression: Expression) -> [Hand] {
        hands.sorted { hand1, hand2 in
            let score1 = matchScore(hand1.compatibleWith, expression.tags)
            let score2 = matchScore(hand2.compatibleWith, expression.tags)
            return score1 > score2
        }
    }

    func recommendedDecorations(for expression: Expression) -> [Decoration] {
        decorations.sorted { dec1, dec2 in
            let score1 = matchScore(dec1.compatibleWith, expression.tags)
            let score2 = matchScore(dec2.compatibleWith, expression.tags)
            return score1 > score2
        }
    }

    func recommendedActions(for expression: Expression) -> [Action] {
        actions.sorted { act1, act2 in
            let score1 = matchScore(act1.compatibleWith, expression.tags)
            let score2 = matchScore(act2.compatibleWith, expression.tags)
            return score1 > score2
        }
    }

    // タグのマッチスコアを計算
    private func matchScore(_ compatibleWith: [String], _ tags: [String]) -> Int {
        compatibleWith.reduce(0) { score, tag in
            tags.contains(tag) ? score + 1 : score
        }
    }
}
