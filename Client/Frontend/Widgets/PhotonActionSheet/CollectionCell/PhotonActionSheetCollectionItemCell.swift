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
    static let IconSize: CGFloat = 25.0

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.font = DynamicFontHelper.defaultHelper.SmallSizeRegularWeightAS
        return label
    }()

    lazy private var iconImageView: UIImageView = {
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
        self.isAccessibilityElement = true
        self.backgroundColor = .clear
        self.stackView.addArrangedSubview(self.iconImageView)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.titleLabel).priority(.medium)
            make.width.height.equalTo(PhotonActionSheetCollectionItemCell.IconSize)
        }
        self.contentView.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: PhotonActionSheetItem) {
        let image = UIImage(named: item.iconString ?? "")
        self.iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
        self.titleLabel.textColor = item.accessory == .Text ? titleLabel.textColor.withAlphaComponent(0.6) : titleLabel.textColor
        self.titleLabel.text = item.title
        self.titleLabel.font = image == nil ? DynamicFontHelper.defaultHelper.LargeSizeRegularWeightAS : DynamicFontHelper.defaultHelper.SmallSizeRegularWeightAS
        self.iconImageView.snp.updateConstraints { (make) in
            make.height.equalTo(image == nil ? 0 : PhotonActionSheetCollectionItemCell.IconSize)
        }
        self.accessibilityIdentifier = item.iconString
        self.accessibilityLabel = item.title
    }

}
