//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared

struct PrivacyStatementFooterViewUI {
    static let okButtonHeight: CGFloat = 40.0
    static let separatorHeight: CGFloat = 1.0
}

protocol PrivacyStatementFooterViewDelegate: class {
    func onClickOkButton()
}

class PrivacyStatementFooterView: UIView {

    weak var delegate: PrivacyStatementFooterViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc func okButtonAction() {
        self.delegate?.onClickOkButton()
    }

    // MARK: - Private methods

    private func setup() {
        self.backgroundColor = Theme.tableView.rowBackground
        self.setupOkButton()
        self.setupTopSeparator()
    }

    private func setupOkButton() {
        let okButton = UIButton(type: .system)
        okButton.addTarget(self, action: #selector(okButtonAction), for: .touchUpInside)
        okButton.clipsToBounds = true
        okButton.layer.cornerRadius = PrivacyStatementFooterViewUI.okButtonHeight / 2
        okButton.setTitle(Strings.PrivacyStatement.DoneButton, for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.backgroundColor = Theme.tableView.rowActionAccessory
        self.addSubview(okButton)
        okButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.height.equalTo(PrivacyStatementFooterViewUI.okButtonHeight)
            make.width.equalTo(self.snp.width).multipliedBy(0.5)
        }
    }

    private func setupTopSeparator() {
        let separator = UIView()
        separator.backgroundColor = UIColor.Grey40
        self.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self)
            make.height.equalTo(PrivacyStatementFooterViewUI.separatorHeight)
        }
    }
}
