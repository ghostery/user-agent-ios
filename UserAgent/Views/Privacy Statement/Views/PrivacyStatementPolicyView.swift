//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

class PrivacyStatementPolicyView: UIView {
    let primaryLabel = UILabel()
    let secondaryLabel = UILabel()
    let arrowImageView = UIImageView()
    var tapAction: (() -> Void)?

    init() {
        super.init(frame: .zero)
        self.primaryLabel.text = "Cliqz Privacy" //TODO: lokalize
        self.primaryLabel.numberOfLines = 1
        self.primaryLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(self.primaryLabel)

        self.secondaryLabel.text = "Designated to be read"
        self.secondaryLabel.numberOfLines = 1
        self.secondaryLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        self.addSubview(self.secondaryLabel)

        // TODO: setup arrow button


        // TODO: add tap gesture recognizer and connect with closure

        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        self.primaryLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.top.equalTo(self).offset(5)
        }

        self.secondaryLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.bottom.equalTo(self).offset(-5)
            make.top.equalTo(self.primaryLabel).offset(5).priority(250)
        }
    }
}
