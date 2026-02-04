import SwiftUI

struct KeyboardView: View {
    let onInsertText: (String) -> Void
    let onDeleteBackward: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    @State private var builder = KaomojiBuilder()
    @State private var selectedTab: KeyboardTab = .dictionary
    @State private var activeEntry: RegisteredKaomoji?
    @State private var previewScale: CGFloat = 1.0
    @State private var selectedCategory: ExpressionCategory = .happy
    @State private var didPickInitialTab = false

    private let data = KaomojiData.shared
    private let storage = KaomojiStorage.shared

    private var isDark: Bool { colorScheme == .dark }
    private var keyBg: Color { isDark ? Color(white: 0.35) : .white }
    private var specialBg: Color { isDark ? Color(white: 0.22) : Color(UIColor(white: 0.72, alpha: 1)) }
    private var selectedKeyBg: Color { isDark ? Color(white: 0.45) : Color(UIColor(white: 0.82, alpha: 1)) }
    private var textColor: Color { isDark ? .white : .black }
    private var subColor: Color { isDark ? Color(white: 0.55) : .gray }
    private var keyShadow: Color { isDark ? .clear : Color(UIColor(white: 0.5, alpha: 0.3)) }
    private var chipBg: Color { isDark ? Color(white: 0.28) : Color(UIColor(white: 0.9, alpha: 1)) }
    private var chipSelectedBg: Color { isDark ? Color(white: 0.45) : Color(UIColor(white: 0.78, alpha: 1)) }

    enum KeyboardTab: String, CaseIterable {
        case dictionary = "辞書"
        case expression = "顔"
        case bracket = "枠"
        case hand = "手"
        case decoration = "飾"
        case history = "履歴"
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            gridArea
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .clipped()
            bottomTabBar
        }
        .frame(height: 216)
        .onAppear {
            if !didPickInitialTab {
                didPickInitialTab = true
                if storage.getRegistered().isEmpty {
                    selectedTab = .expression
                }
            }
        }
    }

    // MARK: - トップバー

    private var topBar: some View {
        HStack(spacing: 4) {
            // プレビュー
            HStack(spacing: 0) {
                let preview = builder.preview()
                if preview.isEmpty {
                    Text("タップで入力")
                        .font(.system(size: 14))
                        .foregroundColor(subColor)
                } else {
                    Text(preview)
                        .font(.system(size: 18))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(keyBg)
            .cornerRadius(5)
            .shadow(color: keyShadow, radius: 0, x: 0, y: 1)
            .scaleEffect(previewScale)
            .contentShape(Rectangle())
            .onTapGesture {
                let text = builder.build()
                if !text.isEmpty {
                    withAnimation(.easeInOut(duration: 0.07)) { previewScale = 0.96 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                        withAnimation(.easeInOut(duration: 0.07)) { previewScale = 1.0 }
                    }
                    onInsertText(text)
                    storage.addToHistory(text)
                }
            }

            Button(action: onDeleteBackward) {
                Image(systemName: "delete.left")
                    .font(.system(size: 18))
                    .foregroundColor(textColor)
                    .frame(width: 40, height: 30)
                    .background(specialBg)
                    .cornerRadius(5)
                    .shadow(color: keyShadow, radius: 0, x: 0, y: 1)
            }
        }
        .padding(.horizontal, 3)
        .padding(.top, 6)
        .padding(.bottom, 3)
    }

    // MARK: - グリッド

    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

    private var gridArea: some View {
        Group {
            switch selectedTab {
            case .dictionary:
                dictionaryView
            case .expression:
                expressionView
            case .bracket:
                partsGrid(makeBracketItems()) { id in
                    builder.bracket = data.brackets.first { $0.id == id }
                }
            case .hand:
                partsGrid(makeHandItems()) { id in
                    builder.hand = data.hands.first { $0.id == id }
                }
            case .decoration:
                decorationView
            case .history:
                historyView
            }
        }
    }

    // MARK: - 辞書タブ

    private var dictionaryView: some View {
        let items = storage.getRegistered()
        return Group {
            if items.isEmpty {
                VStack {
                    Spacer()
                    Text("アプリで顔文字を登録しよう")
                        .font(.system(size: 13))
                        .foregroundColor(subColor)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 4) {
                        ForEach(items) { item in
                            keyButton(label: item.kaomoji, isSelected: activeEntry?.id == item.id) {
                                // プレビューにセット（タップ入力はプレビューバーから）
                                activeEntry = item
                                builder.restore(from: item.builderState, data: data)
                            }
                        }
                    }
                    .padding(.horizontal, 3)
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: - 顔タブ（テンプレ表情選択）

    private var expressionView: some View {
        VStack(spacing: 0) {
            // カテゴリチップス
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(ExpressionCategory.allCases, id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category.shortName)
                                .font(.system(size: 12, weight: selectedCategory == category ? .semibold : .regular))
                                .foregroundColor(selectedCategory == category ? textColor : subColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(selectedCategory == category ? chipSelectedBg : chipBg)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 3)
                .padding(.vertical, 2)
            }
            .frame(height: 26)

            // 表情グリッド
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 4) {
                    ForEach(data.expressions(for: selectedCategory)) { expr in
                        let variations = data.expressionVariations(for: expr.id).map {
                            FlickVariation(id: $0.id, label: $0.face)
                        }
                        FlickKeyView(
                            label: expr.face,
                            isSelected: builder.expression?.id == expr.id,
                            variations: Array(variations.prefix(2)),
                            onTap: {
                                builder.expression = expr
                                if builder.bracket == nil {
                                    builder.bracket = data.brackets.first
                                }
                            },
                            onFlick: { varID in
                                if let varExpr = data.expressions.first(where: { $0.id == varID }) {
                                    builder.expression = varExpr
                                    if builder.bracket == nil {
                                        builder.bracket = data.brackets.first
                                    }
                                }
                            },
                            keyBg: keyBg,
                            selectedKeyBg: selectedKeyBg,
                            textColor: textColor,
                            keyShadow: keyShadow
                        )
                    }
                }
                .padding(.horizontal, 3)
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - 履歴タブ

    private var historyView: some View {
        let items = storage.getHistory()
        return Group {
            if items.isEmpty {
                VStack {
                    Spacer()
                    Text("まだ履歴がありません")
                        .font(.system(size: 13))
                        .foregroundColor(subColor)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 4) {
                        ForEach(items) { item in
                            keyButton(label: item.kaomoji, isSelected: false) {
                                onInsertText(item.kaomoji)
                                storage.addToHistory(item.kaomoji)
                            }
                        }
                    }
                    .padding(.horizontal, 3)
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: - 飾タブ（装飾＋アクション統合）

    private var decorationView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                sectionHeader("装飾")
                LazyVGrid(columns: gridColumns, spacing: 4) {
                    ForEach(makeDecorationItems()) { item in
                        keyButton(label: item.label, isSelected: item.isSelected) {
                            builder.decoration = data.decorations.first { $0.id == item.id }
                        }
                    }
                }

                sectionHeader("アクション")
                LazyVGrid(columns: gridColumns, spacing: 4) {
                    ForEach(makeActionItems()) { item in
                        keyButton(label: item.label, isSelected: item.isSelected) {
                            builder.action = data.actions.first { $0.id == item.id }
                        }
                    }
                }
            }
            .padding(.horizontal, 3)
            .padding(.vertical, 2)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(subColor)
            .padding(.leading, 2)
            .padding(.top, 2)
    }

    // MARK: - パーツデータ生成

    private struct PartItem: Identifiable {
        let id: String
        let label: String
        let isSelected: Bool
    }

    private func makeBracketItems() -> [PartItem] {
        noneFirst(data.brackets.map {
            PartItem(id: $0.id, label: $0.id == "none" ? "なし" : "\($0.open) \($0.close)", isSelected: builder.bracket?.id == $0.id)
        })
    }

    private func makeHandItems() -> [PartItem] {
        let list = builder.expression.map { data.recommendedHands(for: $0) } ?? data.hands
        return noneFirst(list.map {
            PartItem(id: $0.id, label: $0.id == "none" ? "なし" : "\($0.left) \($0.right)", isSelected: builder.hand?.id == $0.id)
        })
    }

    private func makeDecorationItems() -> [PartItem] {
        let list = builder.expression.map { data.recommendedDecorations(for: $0) } ?? data.decorations
        return noneFirst(list.map {
            PartItem(id: $0.id, label: $0.id == "none" ? "なし" : $0.char, isSelected: builder.decoration?.id == $0.id)
        })
    }

    private func makeActionItems() -> [PartItem] {
        let list = builder.expression.map { data.recommendedActions(for: $0) } ?? data.actions
        return noneFirst(list.map {
            PartItem(id: $0.id, label: $0.id == "none" ? "なし" : $0.suffix, isSelected: builder.action?.id == $0.id)
        })
    }

    private func noneFirst(_ items: [PartItem]) -> [PartItem] {
        let none = items.filter { $0.id == "none" }
        let rest = items.filter { $0.id != "none" }
        return none + rest
    }

    private func partsGrid(_ items: [PartItem], onSelect: @escaping (String) -> Void) -> some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 4) {
                ForEach(items) { item in
                    keyButton(label: item.label, isSelected: item.isSelected) {
                        onSelect(item.id)
                    }
                }
            }
            .padding(.horizontal, 3)
            .padding(.vertical, 2)
        }
    }

    // MARK: - 下部タブバー

    private var bottomTabBar: some View {
        HStack(spacing: 2) {
            ForEach(KeyboardTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 15, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? textColor : subColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .contentShape(Rectangle())
                        .background(selectedTab == tab ? keyBg : Color.clear)
                        .cornerRadius(5)
                }
            }

            if builder.hasSelection {
                Button {
                    builder.reset()
                    activeEntry = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(subColor)
                        .frame(width: 36, height: 36)
                        .background(specialBg)
                        .cornerRadius(5)
                }
            }
        }
        .padding(.horizontal, 3)
        .padding(.vertical, 3)
    }

    // MARK: - キーボタン

    private func keyButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(isSelected ? selectedKeyBg : keyBg)
                .cornerRadius(5)
                .shadow(color: keyShadow, radius: 0, x: 0, y: 1)
        }
    }
}

// MARK: - カテゴリ短縮名

extension ExpressionCategory {
    var shortName: String {
        switch self {
        case .happy: return "嬉"
        case .sad: return "悲"
        case .angry: return "怒"
        case .surprised: return "驚"
        case .shy: return "照"
        case .smug: return "煽"
        case .neutral: return "無"
        case .animal: return "動"
        }
    }
}

#Preview {
    KeyboardView(
        onInsertText: { _ in },
        onDeleteBackward: { }
    )
    .frame(height: 216)
}
