//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

struct ChatBubbleViewCellUI {
    static let offset: CGFloat = 30.0
}

class ChatBubbleViewCell: UITableViewCell {

    private var bubbleView: BubbleView!
    private var label: UILabel!

    private var message: String?

    init(message: String) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        self.message = message
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Private methods

    private func setup() {
        self.backgroundColor = .clear
        self.setupLabel()
        self.setupBubbleView()
    }

    private func setupLabel() {
        self.label = UILabel()
        self.label.text = self.message
        self.label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = Theme.tableView.rowText
        self.addSubview(self.label)
        self.label.snp.makeConstraints { (make) in
            make.top.left.equalTo(self).offset(ChatBubbleViewCellUI.offset)
            make.bottom.equalTo(self).offset(-ChatBubbleViewCellUI.offset)
            make.width.equalTo(self).multipliedBy(0.6)
        }
    }

    private func setupBubbleView() {
        self.bubbleView = BubbleView()
        self.bubbleView.backgroundColor = .clear
        self.addSubview(self.bubbleView)
        self.bringSubviewToFront(self.label)
        self.bubbleView.snp.makeConstraints { (make) in
            make.top.left.equalTo(self.label).offset(-ChatBubbleViewCellUI.offset / 2)
            make.bottom.right.equalTo(self.label).offset(ChatBubbleViewCellUI.offset / 2)
        }
    }

}
