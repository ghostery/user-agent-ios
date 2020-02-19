//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

struct PrivacyStatementMessageCellUI {
    static let titleFontSize: CGFloat = 12.0
    static let titleOffset: CGFloat = 10.0
    static let iconWidth: CGFloat = 17.0
    static let iconHeight: CGFloat = 13.0
    static let iconOffet: CGFloat = 5.0
}

protocol PrivacyStatementMessageCellDelegate: class {
    func onClickMessageButton()
}

class PrivacyStatementMessageCell: ThemedTableViewCell {

    private var messageIconImageView: UIImageView?
    private var titleButton: UIButton?

    weak var delegate: PrivacyStatementMessageCellDelegate?

    var icon: UIImage? {
        didSet {
            self.messageIconImageView?.image = self.icon
        }
    }

    var title: String? {
        didSet {
            self.titleButton?.setTitle(self.title, for: .normal)
        }
    }

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc func messageButtonAction() {
        self.delegate?.onClickMessageButton()
    }

    // MARK: - Private methods

    private func setup() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.titleButton = UIButton(type: .system)
        self.titleButton?.addTarget(self, action: #selector(messageButtonAction), for: .touchUpInside)
        self.titleButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: PrivacyStatementMessageCellUI.titleFontSize)
        self.titleButton?.setTitleColor(Theme.general.controlTint, for: .normal)
        self.addSubview(self.titleButton!)
        self.titleButton?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.safeAreaLayoutGuide).offset(-PrivacyStatementMessageCellUI.titleOffset * 2)
            make.top.equalTo(self).offset(PrivacyStatementMessageCellUI.titleOffset / 2)
            make.height.equalTo(2 * PrivacyStatementMessageCellUI.iconHeight)
        })
        self.messageIconImageView = UIImageView()
        self.messageIconImageView?.tintColor = Theme.general.controlTint
        self.addSubview(self.messageIconImageView!)
        self.messageIconImageView?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.titleButton!.snp.centerY)
            make.right.equalTo(self.titleButton!.snp.left).offset(-PrivacyStatementMessageCellUI.iconOffet)
            make.width.equalTo(PrivacyStatementMessageCellUI.iconWidth)
            make.height.equalTo(PrivacyStatementMessageCellUI.iconHeight)
        })
    }

}
