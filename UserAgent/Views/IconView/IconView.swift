//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared
import Storage

class IconView: UIView {

    lazy private var logoView = LogoView()

    lazy private (set) var faviconView: UIImageView = {
        let faviconView = UIImageView(image: FaviconFetcher.defaultFavicon)
        faviconView.backgroundColor = UIColor.white
        faviconView.layer.cornerRadius = 6
        faviconView.layer.borderWidth = 0.5
        faviconView.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
        faviconView.layer.masksToBounds = true
        return faviconView
    }()

    init() {
        super.init(frame: .zero)
        switch Features.Icons.type {
        case .cliqz:
            self.addSubview(self.logoView)
            self.logoView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        case .favicon:
            self.addSubview(self.faviconView)
            self.faviconView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setIcon(site: Site, scaled: CGSize? = nil) {
        switch Features.Icons.type {
        case .cliqz:
            self.logoView.url = site.url
        case .favicon:
            self.faviconView.setFavicon(forSite: site) { [weak self] in
                if let scaled = scaled {
                    self?.faviconView.image = self?.faviconView.image?.createScaled(scaled)
                }
                if self?.faviconView.backgroundColor == .clear {
                    self?.faviconView.backgroundColor = .white
                }
            }
        }
    }

    func setIcon(urlString: String?, isPrivate: Bool = false) {
        switch Features.Icons.type {
        case .cliqz:
            self.logoView.url = urlString
        case .favicon:
            if let urlString = urlString, let url = URL(string: urlString) {
                self.faviconView.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultFavicon"), options: [], completed: nil)
            } else {
                self.faviconView.image = UIImage(named: "defaultFavicon")
                if isPrivate {
                    self.faviconView.tintColor = Theme.tabTray.faviconTint
                }
            }
        }
    }

    func setTabIcon(tab: Tab) {
        switch Features.Icons.type {
        case .cliqz:
            self.logoView.url = tab.logoURL.absoluteString
        case .favicon:
            self.setIcon(urlString: tab.displayFavicon?.url, isPrivate: tab.isPrivate)
        }
    }

}
