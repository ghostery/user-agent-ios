//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Storage
import Shared

protocol DownloadsDelegate: AnyObject {
    func downloadsDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool)
    func downloads(didSelectURL url: URL, visitType: VisitType)
}

class DownloadsViewController: UIViewController {

    var profile: Profile!

    weak var delegate: DownloadsDelegate?

    private lazy var downloadsView: UIView = {
        let downloadsView = DownloadsView(profile: self.profile)
        downloadsView.delegate = self
        downloadsView.documentDelegate = self
        return downloadsView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button on right side of the Downloads view controller title bar"), style: .done, target: self, action: #selector(closeButtonAction))
        self.title = Strings.AppMenuDownloadsTitleString
        self.view.addSubview(self.downloadsView)
        self.downloadsView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }

    @objc func closeButtonAction() {
        self.dismiss(animated: true)
    }

}

extension DownloadsViewController: LibraryViewDelegate {

    func libraryDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool) {
        self.delegate?.downloadsDidRequestToOpenInNewTab(url, isPrivate: isPrivate)
    }

    func library(didSelectURL url: URL, visitType: VisitType) {
        self.delegate?.downloads(didSelectURL: url, visitType: visitType)
    }

    func library(wantsToPresent viewController: UIViewController) {
        self.present(viewController, animated: true)
    }

}

extension DownloadsViewController: DownloadsViewDocumentDelegate {

    func downlaodsView(wantsToPresentDocument path: URL) {
        let dc = UIDocumentInteractionController(url: path)
        dc.delegate = self
        dc.presentPreview(animated: true)
    }

}

extension DownloadsViewController: UIDocumentInteractionControllerDelegate {

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

}
