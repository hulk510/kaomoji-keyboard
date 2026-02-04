import SwiftUI

struct KeyboardView: View {
    let onInsertText: (String) -> Void
    let onDeleteBackward: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    @State private var builder = KaomojiBuilder()
    @State private var selectedTab: KeyboardTab = .expression
    @State private var selectedCategory: ExpressionCategory = .happy
    @State private var previewScale: CGFloat = 1.0
    @State private var dragOffset: CGFloat = 0

    private let data = KaomojiData.shared

    private var isDark: Bool { colorScheme == .dark }
    private var keyBg: Color { isDark ? Color(white: 0.35) : .white }
    private var specialBg: Color { isDark ? Color(white: 0.22) : Color(UIColor(white: 0.72, alpha: 1)) }
    private var selectedKeyBg: Color { isDark ? Color(white: 0.45) : Color(UIColor(white: 0.82, alpha: 1)) }
    private var textColor: Color { isDark ? .white : .black }
    private var subColor: Color { isDark ? Color(white: 0.55) : .gray }
    private var keyShadow: Color { isDark ? .clear : Color(UIColor(white: 0.5, alpha: 0.3)) }

    enum KeyboardTab: String, CaseIterable {
        case expression = "顔"
        case bracket = "枠"
        case hand = "手"
        case decoration = "飾"
        case action = "技"
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            gridArea
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            bottomTabBar
        }
    }

    // MARK: - トップバー

    private var topBar: some View {
        HStack(spacing: 4) {
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
        .padding(.top, 3)
        .padding(.bottom, 2)
    }

    // MARK: - グリッド

    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

    private var gridArea: some View {
        Group {
            switch selectedTab {
            case .expression: expressionView
            case .bracket:    partsGrid(makeBracketItems()) { id in builder.bracket = data.brackets.first { $0.id == id } }
            case .hand:       partsGrid(makeHandItems()) { id in builder.hand = data.hands.first { $0.id == id } }
            case .decoration: partsGrid(makeDecorationItems()) { id in builder.decoration = data.decorations.first { $0.id == id } }
            case .action:     partsGrid(makeActionItems()) { id in builder.action = data.actions.first { $0.id == id } }
            }
        }
    }

    // MARK: - 表情: スワイプでカテゴリ切り替え（1カテゴリだけレンダリング）

    private var expressionView: some View {
        VStack(spacing: 0) {
            // カテゴリインジケーター
            HStack(spacing: 0) {
                Text(selectedCategory.displayName)
                    .font(.system(size: 11))
                    .foregroundColor(subColor)
                Spacer()
                // ドットインジケーター
                HStack(spacing: 3) {
                    ForEach(ExpressionCategory.allCases, id: \.self) { cat in
                        Circle()
                            .fill(cat == selectedCategory ? textColor : subColor.opacity(0.4))
                            .frame(width: 5, height: 5)
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)

            // グリッド（現在のカテゴリのみ）
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 4) {
                    ForEach(data.expressions(for: selectedCategory)) { expression in
                        keyButton(
                            label: expression.face,
                            isSelected: builder.expression?.id == expression.id
                        ) {
                            builder.expression = expression
                            if builder.bracket == nil {
                                builder.bracket = data.brackets.first
                            }
                        }
                    }
                }
                .padding(.horizontal, 3)
                .padding(.vertical, 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onEnded { value in
                        let horizontal = value.translation.width
                        let vertical = value.translation.height
                        // 横方向の移動が縦より大きい場合のみカテゴリ切り替え
                        guard abs(horizontal) > abs(vertical) else { return }
                        let allCases = ExpressionCategory.allCases
                        guard let idx = allCases.firstIndex(of: selectedCategory) else { return }
                        if horizontal < 0 && idx < allCases.count - 1 {
                            selectedCategory = allCases[idx + 1]
                        } else if horizontal > 0 && idx > 0 {
                            selectedCategory = allCases[idx - 1]
                        }
                    }
            )
        }
    }

    // MARK: - パーツデータ生成

    private struct PartItem: Identifiable {
        let id: String
        let label: String
        let isSelected: Bool
    }

    private func makeBracketItems() -> [PartItem] {
        data.brackets.map { PartItem(id: $0.id, label: $0.id == "none" ? "なし" : "\($0.open) \($0.close)", isSelected: builder.bracket?.id == $0.id) }
    }

    private func makeHandItems() -> [PartItem] {
        let list = builder.expression.map { data.recommendedHands(for: $0) } ?? data.hands
        return list.map { PartItem(id: $0.id, label: $0.id == "none" ? "なし" : "\($0.left) \($0.right)", isSelected: builder.hand?.id == $0.id) }
    }

    private func makeDecorationItems() -> [PartItem] {
        let list = builder.expression.map { data.recommendedDecorations(for: $0) } ?? data.decorations
        return list.map { PartItem(id: $0.id, label: $0.id == "none" ? "なし" : $0.char, isSelected: builder.decoration?.id == $0.id) }
    }

    private func makeActionItems() -> [PartItem] {
        let list = builder.expression.map { data.recommendedActions(for: $0) } ?? data.actions
        return list.map { PartItem(id: $0.id, label: $0.id == "none" ? "なし" : $0.suffix, isSelected: builder.action?.id == $0.id) }
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
        HStack(spacing: 0) {
            ForEach(KeyboardTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? textColor : subColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(selectedTab == tab ? keyBg : Color.clear)
                        .cornerRadius(5)
                }
            }

            if builder.hasSelection {
                Button {
                    builder.reset()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(subColor)
                        .frame(width: 32, height: 32)
                        .background(specialBg)
                        .cornerRadius(5)
                }
            }
        }
        .padding(.horizontal, 3)
        .padding(.vertical, 2)
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

#Preview {
    KeyboardView(
        onInsertText: { _ in },
        onDeleteBackward: { }
    )
    .frame(height: 216)
}
