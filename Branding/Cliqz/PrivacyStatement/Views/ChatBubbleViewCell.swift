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

    var labelOffsets: (topOffset: CGFloat, bottomOffset: CGFloat) = (ChatBubbleViewCellUI.offset, ChatBubbleViewCellUI.offset) {
        didSet {
            self.label.snp.updateConstraints { (make) in
                make.top.equalTo(self).offset(self.labelOffsets.topOffset)
                make.bottom.equalTo(self).offset(-self.labelOffsets.bottomOffset)
            }
            self.bubbleView.snp.updateConstraints { (make) in
                let minOffset = min(self.labelOffsets.topOffset, self.labelOffsets.bottomOffset)
                make.top.equalTo(self.label).offset(-minOffset / 2)
                make.bottom.equalTo(self.label).offset(minOffset / 2)
            }
        }
    }

    init(message: String) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        self.selectionStyle = .none
        self.message = message
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.bubbleView.setNeedsDisplay()
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
            make.top.equalTo(self).offset(self.labelOffsets.topOffset)
            make.bottom.equalTo(self).offset(-self.labelOffsets.bottomOffset)
            make.left.equalTo(self.safeAreaLayoutGuide).offset(ChatBubbleViewCellUI.offset)
            make.width.equalTo(self).multipliedBy(0.6)
        }
    }

    private func setupBubbleView() {
        self.bubbleView = BubbleView()
        self.bubbleView.backgroundColor = .clear
        self.addSubview(self.bubbleView)
        self.bringSubviewToFront(self.label)
        self.bubbleView.snp.makeConstraints { (make) in
            let minOffset = min(self.labelOffsets.topOffset, self.labelOffsets.bottomOffset)
            make.top.equalTo(self.label).offset(-minOffset / 2)
            make.bottom.equalTo(self.label).offset(minOffset / 2)
            make.left.equalTo(self.label).offset(-ChatBubbleViewCellUI.offset / 2)
            make.right.equalTo(self.label).offset(ChatBubbleViewCellUI.offset / 2)
        }
    }

}
