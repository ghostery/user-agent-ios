//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

class PhotonActionSheetCollectionItemCell: UICollectionViewCell {

    static let VerticalPadding: CGFloat = 2

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.75 // Scale the font if we run out of space
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.font = DynamicFontHelper.defaultHelper.SmallSizeMediumWeightAS
        return label
    }()

    lazy private var iconView: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.clipsToBounds = true
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
        return icon
    }()

    lazy private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = PhotonActionSheetCollectionItemCell.VerticalPadding
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.alignment = .center
        stackView.axis = .vertical
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.stackView.addArrangedSubview(self.iconView)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.contentView.addSubview(stackView)
        self.stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: PhotonActionSheetItem) {
        self.iconView.image = UIImage(named: item.iconString ?? "")?.withRenderingMode(.alwaysTemplate)
        self.titleLabel.text = item.title
    }

}
