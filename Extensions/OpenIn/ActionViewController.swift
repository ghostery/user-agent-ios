//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import MobileCoreServices
import Shared

class ActionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (url, error) in
                        OperationQueue.main.addOperation {
                            if let url = url as? URL {
                                print(url)
                                self.openUserAgent(withUrl: url)
                            }
                            self.done()
                        }
                    })
                    break
                }
            }
        }
    }

    func openUserAgent(withUrl url: URL) {
        // Telemetry is handled in the app delegate that receives this event.
//        let profile = BrowserProfile(localName: "profile")
//        profile.prefs.setBool(true, forKey: PrefsKeys.AppExtensionTelemetryOpenUrl)

        let protocolName = AppInfo.protocolName
        let encoded = url.absoluteString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics) ?? ""
        let path = "\(protocolName)://open-url?url=\(encoded)"
        guard let url = URL(string: path) else { return }
        var responder = self as UIResponder?
        let selectorOpenURL = sel_registerName("openURL:")
        while let current = responder {
            if current.responds(to: selectorOpenURL) {
                current.perform(selectorOpenURL, with: url, afterDelay: 0)
                break
            }
            responder = current.next
        }
    }

    func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
