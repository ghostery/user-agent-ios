//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

class FileDownloadActivity: UIActivity {

    static let activityType: ActivityType = ActivityType("download.activity.type")

    override class var activityCategory: UIActivity.Category {
        return .action
    }

    override var activityTitle: String? {
        return Strings.Downloads.Alert.DownloadNowButtonTitle
    }

    override var activityType: UIActivity.ActivityType? {
        return FileDownloadActivity.activityType
    }

    override var activityImage: UIImage? {
        return UIImage(named: "menu-downloads")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        if let url = activityItems.first(where: { $0 is URL }) as? URL {
            return url.isFileURL
        }
        return false
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityDidFinish(true)
    }
}
