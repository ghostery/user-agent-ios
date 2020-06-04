//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

struct PrivacyStatementSettingCellUI {
    static let infoButtonSize: CGFloat = 30.0
    static let infoButtonImageOffset: CGFloat = 5.0
}

protocol PrivacyStatementSettingCellDelegate: class {
    func onClickInfoButton()
}

class PrivacyStatementSettingCell: PrivacyStatementCell {

    private (set) var infoButton: UIButton?

    weak var delegate: PrivacyStatementSettingCellDelegate?

    var infoButtonImage: UIImage? {
        didSet {
            self.updateInfoButton()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc func infoButtonAction() {
        self.delegate?.onClickInfoButton()
    }

    // MARK: - Private methods

    private func updateInfoButton() {
        if self.infoButtonImage == nil {
            self.infoButton?.removeFromSuperview()
            self.infoButton = nil
        } else {
            if self.infoButton == nil {
                self.infoButton = UIButton()
                self.infoButton?.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
                self.infoButton?.imageEdgeInsets = UIEdgeInsets(equalInset: PrivacyStatementSettingCellUI.infoButtonImageOffset)
                self.addSubview(self.infoButton!)
                self.infoButton?.snp.makeConstraints({ (make) in
                    make.top.equalTo(self.titleLabel.snp.top)
                    make.height.equalTo(PrivacyStatementSettingCellUI.infoButtonSize)
                    make.width.equalTo(self.infoButton!.snp.height)
                    make.right.equalTo(self.titleLabel.snp.left).offset(-PrivacyStatementSettingCellUI.infoButtonImageOffset)
                })
            }
            self.infoButton?.setImage(self.infoButtonImage, for: .normal)
        }
    }
}
