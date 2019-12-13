//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

struct PrivacyStatementSettingCellUI {
    static let labelLeftOffset: CGFloat = 50.0
    static let separatorHeight: CGFloat = 1.0
    static let infoButtonSize: CGFloat = 30.0
    static let infoButtonImageOffset: CGFloat = 5.0
}

protocol PrivacyStatementSettingCellDelegate: class {
    func onClickInfoButton()
}

class PrivacyStatementSettingCell: ThemedTableViewCell {

    private var topSeparatorView: UIView?
    private var bottomSeparatorView: UIView?
    private var infoButton: UIButton?
    
    weak var delegate: PrivacyStatementSettingCellDelegate?

    var hasTopSeparator: Bool = false {
        didSet {
            self.updateTopSeparatorView()
        }
    }

    var hasBottomSeparator: Bool = false {
        didSet {
            self.updateBottomSeparatorView()
        }
    }

    var bottomSeparatorOffsets: (leftOffset: CGFloat, rightOffset: CGFloat) = (0, 0) {
        didSet {
            if self.bottomSeparatorView != nil {
                self.bottomSeparatorView?.snp.remakeConstraints({ (make) in
                    make.bottom.equalTo(self)
                    make.height.equalTo(PrivacyStatementSettingCellUI.separatorHeight)
                    make.left.equalTo(self).offset(self.bottomSeparatorOffsets.leftOffset)
                    make.right.equalTo(self).offset(-self.bottomSeparatorOffsets.rightOffset)
                })
            }
        }
    }

    var topSeparatorOffsets: (leftOffset: CGFloat, rightOffset: CGFloat) = (0, 0) {
        didSet {
            if self.topSeparatorView != nil {
                self.topSeparatorView?.snp.remakeConstraints({ (make) in
                    make.top.equalTo(self)
                    make.height.equalTo(PrivacyStatementSettingCellUI.separatorHeight)
                    make.left.equalTo(self).offset(self.topSeparatorOffsets.leftOffset)
                    make.right.equalTo(self).offset(-self.topSeparatorOffsets.rightOffset)
                })
            }
        }
    }

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

    override func layoutSubviews() {
        super.layoutSubviews()
        if let frame = self.textLabel?.frame {
            self.textLabel?.frame = CGRect(x: PrivacyStatementSettingCellUI.labelLeftOffset, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
        }
        if let frame = self.detailTextLabel?.frame {
            self.detailTextLabel?.frame = CGRect(x: PrivacyStatementSettingCellUI.labelLeftOffset, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
        }
    }

    // MARK: - Actions

    @objc func infoButtonAction() {
        self.delegate?.onClickInfoButton()
    }

    // MARK: - Private methods

    private func updateBottomSeparatorView() {
        if self.hasBottomSeparator {
            if self.bottomSeparatorView == nil {
                self.bottomSeparatorView = UIView()
                self.bottomSeparatorView?.backgroundColor = UIColor.Grey40
                self.addSubview(self.bottomSeparatorView!)
                self.bottomSeparatorView?.snp.makeConstraints({ (make) in
                    make.bottom.equalTo(self)
                    make.height.equalTo(PrivacyStatementSettingCellUI.separatorHeight)
                    make.left.equalTo(self).offset(self.bottomSeparatorOffsets.leftOffset)
                    make.right.equalTo(self).offset(-self.bottomSeparatorOffsets.rightOffset)
                })
            }
        } else {
            self.bottomSeparatorView?.removeFromSuperview()
            self.bottomSeparatorView = nil
        }
    }

    private func updateTopSeparatorView() {
        if self.hasTopSeparator {
            if self.topSeparatorView == nil {
                self.topSeparatorView = UIView()
                self.topSeparatorView?.backgroundColor = UIColor.Grey40
                self.addSubview(self.topSeparatorView!)
                self.topSeparatorView?.snp.makeConstraints({ (make) in
                    make.top.equalTo(self)
                    make.height.equalTo(PrivacyStatementSettingCellUI.separatorHeight)
                    make.left.equalTo(self).offset(self.topSeparatorOffsets.leftOffset)
                    make.right.equalTo(self).offset(-self.topSeparatorOffsets.rightOffset)
                })
            }
        } else {
            self.topSeparatorView?.removeFromSuperview()
            self.topSeparatorView = nil
        }
    }

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
                    make.centerY.equalTo(self.textLabel!.snp.centerY)
                    make.height.equalTo(PrivacyStatementSettingCellUI.infoButtonSize)
                    make.width.equalTo(self.infoButton!.snp.height)
                    make.right.equalTo(self.textLabel!.snp.left)
                })
            }
            self.infoButton?.setImage(self.infoButtonImage, for: .normal)
        }
    }
}
