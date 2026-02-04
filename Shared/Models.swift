import Foundation

// MARK: - 表情セット
struct Expression: Codable, Identifiable, Hashable {
    let id: String
    let face: String
    let category: String
    let tags: [String]
    let variations: [String]?
}

// MARK: - 顔パーツ
enum FacePartType: String, Codable, CaseIterable {
    case leftEye, mouth, rightEye
}

struct FacePart: Codable, Identifiable, Hashable {
    let id: String
    let char: String
    let type: FacePartType
    let tags: [String]
    let variations: [String]
}

// MARK: - 保存済み顔文字
struct SavedKaomoji: Codable, Identifiable, Hashable {
    let id: UUID
    let kaomoji: String
    let createdAt: Date
    var isFavorite: Bool
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
    let faceParts: [FacePart]?
}

// MARK: - ビルダー状態（ID保存用）
struct BuilderState: Codable, Hashable {
    var expressionID: String?
    var bracketID: String?
    var handID: String?
    var decorationID: String?
    var actionID: String?
    var leftEyeID: String?
    var mouthID: String?
    var rightEyeID: String?
}

// MARK: - 登録済み顔文字
struct RegisteredKaomoji: Codable, Identifiable, Hashable {
    let id: UUID
    let kaomoji: String
    let builderState: BuilderState
    let createdAt: Date
    var sortOrder: Int
}

// MARK: - カテゴリ
enum ExpressionCategory: String, CaseIterable {
    case happy
    case sad
    case angry
    case surprised
    case shy
    case smug
    case neutral
    case animal
    
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
