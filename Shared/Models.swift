import Foundation

// MARK: - 表情セット
struct Expression: Codable, Identifiable, Hashable {
    let id: String
    let face: String
    let category: String
    let tags: [String]
}

// MARK: - 枠
struct Bracket: Codable, Identifiable, Hashable {
    let id: String
    let open: String
    let close: String
}

// MARK: - 手
struct Hand: Codable, Identifiable, Hashable {
    let id: String
    let left: String
    let right: String
    let compatibleWith: [String]
}

// MARK: - 装飾
struct Decoration: Codable, Identifiable, Hashable {
    let id: String
    let char: String
    let compatibleWith: [String]
}

// MARK: - アクション（技）
struct Action: Codable, Identifiable, Hashable {
    let id: String
    let suffix: String
    let compatibleWith: [String]
}

// MARK: - 全データをまとめる
struct KaomojiDataSet: Codable {
    let expressions: [Expression]
    let brackets: [Bracket]
    let hands: [Hand]
    let decorations: [Decoration]
    let actions: [Action]
}

// MARK: - カテゴリ
enum ExpressionCategory: String, CaseIterable {
    case happy = "happy"
    case sad = "sad"
    case angry = "angry"
    case surprised = "surprised"
    case shy = "shy"
    case smug = "smug"
    case neutral = "neutral"
    case animal = "animal"
    
    var displayName: String {
        switch self {
        case .happy: return "嬉しい"
        case .sad: return "悲しい"
        case .angry: return "怒り"
        case .surprised: return "驚き"
        case .shy: return "照れ"
        case .smug: return "煽り"
        case .neutral: return "無表情"
        case .animal: return "動物"
        }
    }
}
