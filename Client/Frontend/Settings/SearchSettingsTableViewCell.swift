//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared

private let logoWidth: CGFloat = 29
private let IconSize = CGSize(width: OpenSearchEngine.PreferredIconSize, height: OpenSearchEngine.PreferredIconSize)

class SearchSettingsTableViewCell: ThemedTableViewCell {
    let iconView = IconView()
    let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.iconView)
        self.label.adjustsFontSizeToFitWidth = true
        self.label.minimumScaleFactor = 0.5
        self.layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateLogo(engine: OpenSearchEngine) {
        self.iconView.updateIcon(engine: engine, scaled: IconSize)
    }

    private func layout() {
        self.iconView.snp.makeConstraints { make in
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
            make.leading.equalTo(self.iconView.snp.trailing).offset(20)
            make.right.equalTo(self.contentView).offset(-10)
        }
    }
}
