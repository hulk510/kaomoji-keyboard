import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // キーボードセットアップ手順
                Section("キーボードセットアップ") {
                    SetupStepView(number: 1, title: "設定を開く", description: "設定 > 一般 > キーボード")
                    SetupStepView(number: 2, title: "キーボードを追加", description: "「キーボード」>「新しいキーボードを追加」")
                    SetupStepView(number: 3, title: "顔文字キーボードを選択", description: "一覧から「KaomojiKeyboard」を選択")
                    SetupStepView(number: 4, title: "使い始める", description: "キーボードの🌐ボタンで切り替え")
                }

                Section {
                    Button(action: openSettings) {
                        HStack {
                            Image(systemName: "gear")
                            Text("設定を開く")
                        }
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
