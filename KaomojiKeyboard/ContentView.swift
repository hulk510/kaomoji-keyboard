import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // ヘッダー
                Text("( ´∀`)و✧")
                    .font(.system(size: 60))
                    .padding(.top, 40)
                
                Text("顔文字キーボード")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // セットアップ手順
                VStack(alignment: .leading, spacing: 16) {
                    SetupStepView(
                        number: 1,
                        title: "設定を開く",
                        description: "設定 > 一般 > キーボード"
                    )
                    
                    SetupStepView(
                        number: 2,
                        title: "キーボードを追加",
                        description: "「キーボード」>「新しいキーボードを追加」"
                    )
                    
                    SetupStepView(
                        number: 3,
                        title: "顔文字キーボードを選択",
                        description: "一覧から「KaomojiKeyboard」を選択"
                    )
                    
                    SetupStepView(
                        number: 4,
                        title: "使い始める",
                        description: "キーボードの🌐ボタンで切り替え"
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // 設定を開くボタン
                Button(action: openSettings) {
                    HStack {
                        Image(systemName: "gear")
                        Text("設定を開く")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct SetupStepView: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}
