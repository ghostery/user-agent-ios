/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

class PrivateModeButton: ToggleButton, PrivateModeUI {
    var offTint = UIColor.black
    var onTint = UIColor.black

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityLabel = Strings.ForgetMode.ToggleAccessibilityLabel
        accessibilityHint = Strings.ForgetMode.ToggleAccessibilityHint
        let maskImage = UIImage(named: "forgetMode")?.withRenderingMode(.alwaysTemplate)
        setImage(maskImage, for: [])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyUIMode(isPrivate: Bool) {
        isSelected = isPrivate

        tintColor = isPrivate ? onTint : offTint
        imageView?.tintColor = tintColor
        self.setTitleColor(self.tintColor, for: [])

        accessibilityValue = isSelected ? Strings.Accessibility.PrivateBrowsing.ToggleAccessibilityValueOn : Strings.Accessibility.PrivateBrowsing.ToggleAccessibilityValueOff
    }

}

extension UIButton {
    static func newTabButton() -> UIButton {
        let newTab = UIButton()
        newTab.setImage(UIImage.templateImageNamed("quick_action_new_tab"), for: .normal)
        newTab.accessibilityLabel = Strings.Accessibility.TabTray.NewTab
        return newTab
    }
}

extension TabsButton {
    static func tabTrayButton() -> TabsButton {
        let tabsButton = TabsButton()
        tabsButton.countLabel.text = "0"
        tabsButton.accessibilityLabel = Strings.Accessibility.TabTray.ShowTabs
        return tabsButton
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct PrivateModeButtonRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let button = PrivateModeButton()
        button.setSelected(false)
        return button
    }

    func updateUIView(_ view: UIView, context: Context) {

    }
}

@available(iOS 13.0, *)
struct PrivateModeButton_Preview: PreviewProvider {
    static var previews: some View {
        PrivateModeButtonRepresentable()
    }
}
#endif
