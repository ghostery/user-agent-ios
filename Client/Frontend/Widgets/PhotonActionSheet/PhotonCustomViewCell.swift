//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

public protocol PhotonCustomViewCellContent: UIView {
    var onSizeChange: (() -> Void)? { get set }
}

class PhotonCustomViewCell: UITableViewCell {
    public var onSizeChange: (() -> Void)? {
        didSet {
            guard let newCustomView = customView else { return }
            newCustomView.onSizeChange = onSizeChange
        }
    }

    var customView: PhotonCustomViewCellContent? {
        didSet {
            backgroundColor = UIColor.clear

            oldValue?.removeFromSuperview()
            guard let newCustomView = customView else { return }

            newCustomView.tintColor = tintColor
            contentView.addSubview(newCustomView)
            newCustomView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().offset(-10)
                make.left.equalToSuperview().offset(PhotonActionSheetCell.Padding)
                make.right.equalToSuperview().offset(-PhotonActionSheetCell.Padding)
            }
        }
    }

    override var tintColor: UIColor! { didSet { customView?.tintColor = tintColor }}
}
