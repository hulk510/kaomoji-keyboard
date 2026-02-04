import SwiftUI

struct HistoryView: View {
    @State private var history: [SavedKaomoji] = []
    @State private var savedFeedback: String?

    private let storage = KaomojiStorage.shared

    var body: some View {
        Group {
            if history.isEmpty {
                VStack(spacing: 16) {
                    Text("(　´ー`)")
                        .font(.system(size: 40))
                    Text("まだ履歴がありません")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(history) { item in
                        HStack(spacing: 12) {
                            Text(item.kaomoji)
                                .font(.system(size: 22))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                registerFromHistory(item)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)

                            Button {
                                UIPasteboard.general.string = item.kaomoji
                                showFeedback("コピーしました")
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 18))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .overlay(alignment: .bottom) {
            if let feedback = savedFeedback {
                Text(feedback)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .cornerRadius(20)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear { reload() }
    }

    private func reload() {
        history = storage.getHistory()
    }

    private func registerFromHistory(_ item: SavedKaomoji) {
        let state = BuilderState()
        storage.addRegistered(item.kaomoji, builderState: state)
        showFeedback("マイ顔文字に登録しました")
    }

    private func showFeedback(_ message: String) {
        withAnimation { savedFeedback = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { savedFeedback = nil }
        }
    }
}
