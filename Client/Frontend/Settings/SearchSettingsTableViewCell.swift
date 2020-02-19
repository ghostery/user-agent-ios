//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

private let logoWidth: CGFloat = 29

class SearchSettingsTableViewCell: ThemedTableViewCell {
    let logoView = LogoView()
    let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.logoView)
        self.label.adjustsFontSizeToFitWidth = true
        self.label.minimumScaleFactor = 0.5
        self.layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateLogo(url: String) {
        self.logoView.url = url
    }

    private func layout() {
        self.logoView.snp.makeConstraints { make in
            make.height.equalTo(logoWidth)
            make.width.equalTo(logoWidth)
            make.top.greaterThanOrEqualTo(self.contentView).offset(8)
            make.bottom.greaterThanOrEqualTo(self.contentView).offset(-8)
            make.centerY.equalTo(self.contentView)
            make.leading.equalTo(self.contentView.snp.leading).offset(20)
        }
        self.label.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(10)
            make.bottom.equalTo(self.contentView).offset(-10)
            make.leading.equalTo(self.logoView.snp.trailing).offset(20)
            make.right.equalTo(self.contentView).offset(-10)
        }
    }
}
