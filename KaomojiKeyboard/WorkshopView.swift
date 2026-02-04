import SwiftUI

struct WorkshopView: View {
    /// 編集モードで開く場合の既存登録データ
    var editingEntry: RegisteredKaomoji?
    var onSaved: (() -> Void)?

    @State private var builder = KaomojiBuilder()
    @State private var selectedTab: WorkshopTab = .expression
    @State private var expressionMode: ExpressionMode = .template
    @State private var selectedCategory: ExpressionCategory = .happy
    @State private var copiedFeedback = false
    @State private var savedFeedback: String?

    private let data = KaomojiData.shared
    private let storage = KaomojiStorage.shared
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    enum WorkshopTab: String, CaseIterable {
        case expression = "顔"
        case bracket = "枠"
        case hand = "手"
        case decoration = "飾"
    }

    enum ExpressionMode {
        case template, parts
    }

    var body: some View {
        VStack(spacing: 0) {
            previewArea
            tabSelector
            contentArea
            actionBar
        }
        .onAppear {
            if let entry = editingEntry {
                builder.restore(from: entry.builderState, data: data)
            }
        }
    }

    // MARK: - プレビュー

    private var previewArea: some View {
        VStack(spacing: 8) {
            let preview = builder.preview()
            Text(preview.isEmpty ? "顔文字を作ろう" : preview)
                .font(.system(size: preview.isEmpty ? 24 : 60))
                .foregroundColor(preview.isEmpty ? .secondary : .primary)
                .minimumScaleFactor(0.3)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .contentShape(Rectangle())
                .onTapGesture {
                    let text = builder.build()
                    guard !text.isEmpty else { return }
                    UIPasteboard.general.string = text
                    withAnimation { copiedFeedback = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { copiedFeedback = false }
                    }
                }

            if copiedFeedback {
                Text("コピーしました")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }

            if let feedback = savedFeedback {
                Text(feedback)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - タブセレクタ

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(WorkshopTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == tab ? Color.accentColor.opacity(0.1) : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    // MARK: - コンテンツ

    private var contentArea: some View {
        Group {
            switch selectedTab {
            case .expression: expressionContent
            case .bracket: bracketContent
            case .hand: handContent
            case .decoration: decorationContent
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - 顔タブ

    private var expressionContent: some View {
        VStack(spacing: 0) {
            // テンプレ/パーツ切り替え
            Picker("モード", selection: $expressionMode) {
                Text("テンプレ").tag(ExpressionMode.template)
                Text("パーツ").tag(ExpressionMode.parts)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 4)

            if expressionMode == .template {
                templateContent
            } else {
                partsContent
            }
        }
    }

    private var templateContent: some View {
        VStack(spacing: 0) {
            // カテゴリチップス
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ExpressionCategory.allCases, id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category.displayName)
                                .font(.system(size: 14, weight: selectedCategory == category ? .semibold : .regular))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedCategory == category ? Color.accentColor.opacity(0.15) : Color(.systemGray5))
                                .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }

            // 表情グリッド
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 8) {
                    ForEach(data.expressions(for: selectedCategory)) { expr in
                        WorkshopGridCell(
                            label: expr.face,
                            isSelected: builder.expression?.id == expr.id
                        ) {
                            builder.expression = expr
                            // テンプレ選択時はパーツ上書きをクリア
                            builder.leftEye = nil
                            builder.mouth = nil
                            builder.rightEye = nil
                            if builder.bracket == nil {
                                builder.bracket = data.brackets.first
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
    }

    private var partsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                facePartSection(type: .leftEye, label: "左目")
                facePartSection(type: .mouth, label: "口")
                facePartSection(type: .rightEye, label: "右目")
            }
            .padding(.top, 8)
        }
    }

    private func facePartSection(type: FacePartType, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading)

            LazyVGrid(columns: gridColumns, spacing: 8) {
                // 「なし」を先頭に
                nonePartCell(type: type)

                ForEach(data.faceParts(for: type)) { part in
                    let isSelected: Bool = {
                        switch type {
                        case .leftEye: return builder.leftEye?.id == part.id
                        case .mouth: return builder.mouth?.id == part.id
                        case .rightEye: return builder.rightEye?.id == part.id
                        }
                    }()
                    WorkshopGridCell(
                        label: part.char,
                        isSelected: isSelected
                    ) {
                        switch type {
                        case .leftEye: builder.leftEye = part
                        case .mouth: builder.mouth = part
                        case .rightEye: builder.rightEye = part
                        }
                        if builder.bracket == nil {
                            builder.bracket = data.brackets.first
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func nonePartCell(type: FacePartType) -> some View {
        let isSelected: Bool = {
            switch type {
            case .leftEye: return builder.leftEye == nil
            case .mouth: return builder.mouth == nil
            case .rightEye: return builder.rightEye == nil
            }
        }()
        return WorkshopGridCell(
            label: "なし",
            isSelected: isSelected
        ) {
            switch type {
            case .leftEye: builder.leftEye = nil
            case .mouth: builder.mouth = nil
            case .rightEye: builder.rightEye = nil
            }
        }
    }

    // MARK: - 枠/手/飾タブ

    private var bracketContent: some View {
        let sorted = noneFirst(data.brackets)
        return ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(sorted) { bracket in
                    WorkshopGridCell(
                        label: bracket.id == "none" ? "なし" : "\(bracket.open) \(bracket.close)",
                        isSelected: builder.bracket?.id == bracket.id
                    ) {
                        builder.bracket = bracket
                    }
                }
            }
            .padding()
        }
    }

    private var handContent: some View {
        let list = builder.expression.map { data.recommendedHands(for: $0) } ?? data.hands
        let sorted = noneFirst(list)
        return ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(sorted) { hand in
                    WorkshopGridCell(
                        label: hand.id == "none" ? "なし" : "\(hand.left) \(hand.right)",
                        isSelected: builder.hand?.id == hand.id
                    ) {
                        builder.hand = hand
                    }
                }
            }
            .padding()
        }
    }

    private var decorationContent: some View {
        let decoList = noneFirst(builder.expression.map { data.recommendedDecorations(for: $0) } ?? data.decorations)
        let actionList = noneFirst(builder.expression.map { data.recommendedActions(for: $0) } ?? data.actions)
        return ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("装飾")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading)

                LazyVGrid(columns: gridColumns, spacing: 8) {
                    ForEach(decoList) { deco in
                        WorkshopGridCell(
                            label: deco.id == "none" ? "なし" : deco.char,
                            isSelected: builder.decoration?.id == deco.id
                        ) {
                            builder.decoration = deco
                        }
                    }
                }

                Text("アクション")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                    .padding(.top, 4)

                LazyVGrid(columns: gridColumns, spacing: 8) {
                    ForEach(actionList) { action in
                        WorkshopGridCell(
                            label: action.id == "none" ? "なし" : action.suffix,
                            isSelected: builder.action?.id == action.id
                        ) {
                            builder.action = action
                        }
                    }
                }
            }
            .padding()
        }
    }

    /// 「なし」(id == "none") を先頭に移動
    private func noneFirst<T: Identifiable>(_ items: [T]) -> [T] where T.ID == String {
        let none = items.filter { $0.id == "none" }
        let rest = items.filter { $0.id != "none" }
        return none + rest
    }

    // MARK: - アクションバー

    private var actionBar: some View {
        HStack(spacing: 16) {
            Button {
                builder.reset()
            } label: {
                Text("リセット")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)

            Button {
                let text = builder.build()
                guard !text.isEmpty else { return }
                let state = builder.toBuilderState()
                let isEdit = editingEntry != nil
                if let entry = editingEntry {
                    storage.updateRegistered(entry.id, kaomoji: text, builderState: state)
                } else {
                    storage.addRegistered(text, builderState: state)
                }
                withAnimation { savedFeedback = isEdit ? "更新しました" : "登録しました" }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { savedFeedback = nil }
                }
                onSaved?()
            } label: {
                Text(editingEntry != nil ? "更新" : "登録")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(builder.hasSelection ? Color.accentColor : Color.gray)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .disabled(!builder.hasSelection)
        }
        .padding()
    }
}
