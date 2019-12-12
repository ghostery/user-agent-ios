//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared

struct PrivacyStatementHeaderViewUI {
    static let titleFontSize: CGFloat = 40.0
    static let profileFieldFontSize: CGFloat = 15.0
    static let offset: CGFloat = 30.0
    static let height: CGFloat = 200.0
    static let profileImageSize: CGFloat = 60.0
}

class PrivacyStatementHeaderView: UIView {

    private var titleLabel: UILabel!
    private var profileImageView: UIImageView!
    private var profileInfoLabel: UILabel!

    let profile: PrivacyStatementProfile

    init(profile: PrivacyStatementProfile) {
        self.profile = profile
        super.init(frame: .zero)
        self.setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setup() {
        self.setupTitle()
        self.setupProfileImage()
        self.setupProfileInfo()
    }

    private func setupTitle() {
        self.titleLabel = UILabel()
        self.titleLabel.text = Strings.PrivacyStatement.Title
        self.titleLabel.textColor = Theme.tableView.rowText
        self.titleLabel.numberOfLines = 2
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: PrivacyStatementHeaderViewUI.titleFontSize)
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self).offset(PrivacyStatementHeaderViewUI.offset)
        }
    }

    private func setupProfileImage() {
        self.profileImageView = UIImageView(image: self.profile.avatar)
        self.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(PrivacyStatementHeaderViewUI.offset)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(PrivacyStatementHeaderViewUI.offset)
            make.height.equalTo(PrivacyStatementHeaderViewUI.profileImageSize)
            make.width.equalTo(self.profileImageView.snp.height)
        }
    }

    private func setupProfileInfo() {
        self.profileInfoLabel = UILabel()
        self.profileInfoLabel.numberOfLines = 2
        let text = NSMutableAttributedString(string: self.profile.name + "\n" + self.profile.title)
        text.addAttributes([NSAttributedString.Key.foregroundColor: Theme.tableView.rowText, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: PrivacyStatementHeaderViewUI.profileFieldFontSize)], range: NSRange(location: 0, length: self.profile.name.count))
        text.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: PrivacyStatementHeaderViewUI.profileFieldFontSize)], range: NSRange(location: self.profile.name.count + 1, length: self.profile.title.count))
        self.profileInfoLabel.attributedText = text
        self.addSubview(self.profileInfoLabel)
        self.profileInfoLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.profileImageView.snp.right).offset(PrivacyStatementHeaderViewUI.offset / 2)
            make.centerY.equalTo(self.profileImageView.snp.centerY)
            make.right.greaterThanOrEqualTo(self).offset(PrivacyStatementHeaderViewUI.offset)
        }
    }

}
