import SwiftUI

/// フリック情報（ID + 表示ラベル）
struct FlickVariation: Equatable {
    let id: String
    let label: String
}

struct FlickKeyView: View {
    let label: String
    let isSelected: Bool
    let variations: [FlickVariation]  // 左右のバリエーション（最大2つ: [左, 右]）
    let onTap: () -> Void
    let onFlick: (String) -> Void  // フリックで選ばれたバリエーションID

    let keyBg: Color
    let selectedKeyBg: Color
    let textColor: Color
    let keyShadow: Color

    @State private var flickedLabel: String?
    @State private var showPopup = false

    private let flickThreshold: CGFloat = 25

    var body: some View {
        Text(label)
            .font(.system(size: 17))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(isSelected ? selectedKeyBg : keyBg)
            .cornerRadius(5)
            .shadow(color: keyShadow, radius: 0, x: 0, y: 1)
            .overlay(popupOverlay, alignment: .top)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            .simultaneousGesture(flickGesture)
    }

    private var flickGesture: some Gesture {
        DragGesture(minimumDistance: flickThreshold)
            .onEnded { value in
                guard !variations.isEmpty else { return }

                let dx = value.translation.width
                let dy = value.translation.height

                // 縦方向のドラッグはScrollViewに任せる
                guard abs(dx) > abs(dy) else { return }

                // 左フリック → index 0, 右フリック → index 1
                let index = dx > 0 ? 1 : 0
                guard index < variations.count else { return }

                let variation = variations[index]
                flickedLabel = variation.label
                showPopup = true
                onFlick(variation.id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    showPopup = false
                    flickedLabel = nil
                }
            }
    }

    @ViewBuilder
    private var popupOverlay: some View {
        if showPopup, let flicked = flickedLabel {
            Text(flicked)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(textColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(selectedKeyBg)
                .cornerRadius(4)
                .shadow(color: keyShadow, radius: 1, x: 0, y: 1)
                .offset(y: -32)
                .allowsHitTesting(false)
        }
    }
}
