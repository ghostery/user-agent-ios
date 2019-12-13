//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

class PrivacyStatementDisclosureCell: PrivacyStatementCell {

    var title: String? {
        get {
            return self.textLabel?.text
        }
        set {
            self.textLabel?.text = newValue
        }
    }

    var detailTitle: String? {
        get {
            return self.detailTextLabel?.text
        }
        set {
            self.detailTextLabel?.text = newValue
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.textColor = Theme.tableView.rowText
        self.detailTextLabel?.textColor = UIColor.Grey80
        self.accessoryType = .disclosureIndicator
        self.tintColor = .red
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
