//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

struct PrivacyStatementCellUI {
    static let labelLeftOffset: CGFloat = 40.0
    static let separatorHeight: CGFloat = 1.0
}

class PrivacyStatementCell: ThemedTableViewCell {

    private var topSeparatorView: UIView?
    private var bottomSeparatorView: UIView?

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
                    make.height.equalTo(PrivacyStatementCellUI.separatorHeight)
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
                    make.height.equalTo(PrivacyStatementCellUI.separatorHeight)
                    make.left.equalTo(self).offset(self.topSeparatorOffsets.leftOffset)
                    make.right.equalTo(self).offset(-self.topSeparatorOffsets.rightOffset)
                })
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.snp.updateConstraints { (make) in
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(PrivacyStatementCellUI.labelLeftOffset)
        }
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
                    make.height.equalTo(PrivacyStatementCellUI.separatorHeight)
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
                    make.height.equalTo(PrivacyStatementCellUI.separatorHeight)
                    make.left.equalTo(self).offset(self.topSeparatorOffsets.leftOffset)
                    make.right.equalTo(self).offset(-self.topSeparatorOffsets.rightOffset)
                })
            }
        } else {
            self.topSeparatorView?.removeFromSuperview()
            self.topSeparatorView = nil
        }
    }

}
