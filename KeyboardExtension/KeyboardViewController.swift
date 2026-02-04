import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<KeyboardView>?
    private var heightConstraintSet = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // データを先にロード（viewDidLoadはキーボード表示前に呼ばれる）
        _ = KaomojiData.shared
        _ = KaomojiStorage.shared

        setupKeyboardView()
    }

    private func setupKeyboardView() {
        let keyboardView = KeyboardView(
            onInsertText: { [weak self] text in
                self?.textDocumentProxy.insertText(text)
            },
            onDeleteBackward: { [weak self] in
                self?.textDocumentProxy.deleteBackward()
            }
        )

        let hostingController = UIHostingController(rootView: keyboardView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        if #available(iOS 16.4, *) {
            hostingController.safeAreaRegions = []
        }

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.hostingController = hostingController
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !heightConstraintSet {
            let constraint = view.heightAnchor.constraint(equalToConstant: 216)
            constraint.priority = .required
            constraint.isActive = true
            heightConstraintSet = true
        }
    }
}
