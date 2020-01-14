//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class CliqzRefreshControl: UIRefreshControl {
    private let contentView = UIView()
    private let centerAction = UIView()

    override init() {
        super.init()
        self.clipsToBounds = false
        self.backgroundColor = .clear
        self.setupContentView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeight(height: CGFloat) {
        self.contentView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        var proposedHeight = self.contentView.frame.size.height / 4
        proposedHeight = max(proposedHeight, 30)
        self.centerAction.layer.cornerRadius = proposedHeight / 2
        self.centerAction.snp.updateConstraints { (make) in
            make.width.height.greaterThanOrEqualTo(proposedHeight)
        }
    }

    override func endRefreshing() {
        super.endRefreshing()
        self.centerAction.alpha = 0.2
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: [.curveLinear, .repeat, .autoreverse],
                       animations: { self.centerAction.alpha = 1.0 },
                       completion: nil)

    }

    private func setupContentView() {
        self.contentView.backgroundColor = Theme.browser.background
        self.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        self.setupActions()
    }

    private func setupActions() {
        self.centerAction.backgroundColor = .blue
        self.contentView.addSubview(self.centerAction)
        self.centerAction.snp.makeConstraints { (make) in
            make.width.height.greaterThanOrEqualTo(30).priority(1000)
            make.center.equalToSuperview()
        }
    }

}
