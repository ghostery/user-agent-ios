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

    private var canOpenUserAgent: Bool = false
    private var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (url, error) in
                        DispatchQueue.main.async {
                            if let url = url as? URL {
                                if self.canOpenUserAgent {
                                    self.openUserAgent(withUrl: url)
                                    self.done()
                                } else {
                                    self.url = url
                                }
                            }
                        }
                    })
                    break
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.canOpenUserAgent = true
        if let url = self.url {
            self.openUserAgent(withUrl: url)
            self.done()
        }
    }

    func openUserAgent(withUrl url: URL) {
        // Telemetry is handled in the app delegate that receives this event.
        let profile = BrowserProfile(localName: "profile")
        profile.prefs.setBool(true, forKey: PrefsKeys.AppExtensionTelemetryOpenUrl)

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
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

}
