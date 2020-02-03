import UIKit

extension PrivacyIndicator {
    class ButtonView: UIButton {
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            self.setConstrains()
        }
    }
}

fileprivate extension PrivacyIndicator.ButtonView {
    func setConstrains() {
        self.clipsToBounds = false
        guard let sv = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: sv.topAnchor),
            self.bottomAnchor.constraint(equalTo: sv.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: -10),
            self.trailingAnchor.constraint(equalTo: sv.trailingAnchor, constant: 10),
        ])
    }
}
