import Foundation

class KaomojiData {
    static let shared = KaomojiData()

    let expressions: [Expression]
    let brackets: [Bracket]
    let hands: [Hand]
    let decorations: [Decoration]
    let actions: [Action]

    // カテゴリ別に事前分割してキャッシュ
    private let expressionsByCategory: [String: [Expression]]

    private init() {
        guard let url = Bundle.main.url(forResource: "expressions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dataSet = try? JSONDecoder().decode(KaomojiDataSet.self, from: data) else {
            self.expressions = []
            self.brackets = [Bracket(id: "round", open: "(", close: ")")]
            self.hands = [Hand(id: "none", left: "", right: "", compatibleWith: [])]
            self.decorations = [Decoration(id: "none", char: "", compatibleWith: [])]
            self.actions = [Action(id: "none", suffix: "", compatibleWith: [])]
            self.expressionsByCategory = [:]
            return
        }

        self.expressions = dataSet.expressions
        self.brackets = dataSet.brackets
        self.hands = dataSet.hands
        self.decorations = dataSet.decorations
        self.actions = dataSet.actions

        // 起動時に一度だけカテゴリ分類（毎回filterしない）
        var grouped: [String: [Expression]] = [:]
        for expr in dataSet.expressions {
            grouped[expr.category, default: []].append(expr)
        }
        self.expressionsByCategory = grouped
    }

    // MARK: - カテゴリでフィルタリング（キャッシュ済み）

    func expressions(for category: ExpressionCategory) -> [Expression] {
        expressionsByCategory[category.rawValue] ?? []
    }

    // MARK: - おすすめ機能（相性ベース）

    func recommendedHands(for expression: Expression) -> [Hand] {
        let tags = Set(expression.tags)
        return hands.sorted { matchScore($0.compatibleWith, tags) > matchScore($1.compatibleWith, tags) }
    }

    func recommendedDecorations(for expression: Expression) -> [Decoration] {
        let tags = Set(expression.tags)
        return decorations.sorted { matchScore($0.compatibleWith, tags) > matchScore($1.compatibleWith, tags) }
    }

    func recommendedActions(for expression: Expression) -> [Action] {
        let tags = Set(expression.tags)
        return actions.sorted { matchScore($0.compatibleWith, tags) > matchScore($1.compatibleWith, tags) }
    }

    private func matchScore(_ compatibleWith: [String], _ tags: Set<String>) -> Int {
        compatibleWith.reduce(0) { score, tag in
            tags.contains(tag) ? score + 1 : score
        }
    }
}
