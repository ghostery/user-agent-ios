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
        let faviconView = UIImageView()
        faviconView.backgroundColor = .clear
        faviconView.layer.cornerRadius = 6
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

    func clean() {
        switch Features.Icons.type {
        case .cliqz:
            self.logoView.url = nil
        case .favicon:
            self.faviconView.image = nil
        }
    }

    func setTabIcon(tab: Tab) {
        switch Features.Icons.type {
        case .cliqz:
            self.logoView.url = tab.logoURL.absoluteString
        case .favicon:
            if let urlString = tab.displayFavicon?.url, let url = URL(string: urlString) {
                self.faviconView.sd_setImage(with: url, placeholderImage: nil, options: [], completed: nil)
            } else {
                self.faviconView.image = nil
            }
        }
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
            }
        }
    }

    func getIcon(site: Site, scaled: CGSize? = nil) {
        switch Features.Icons.type {
        case .cliqz:
            self.logoView.url = site.url
        case .favicon:
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let profile = appDelegate.profile else { return }
            profile.favicons.getFaviconImage(forSite: site).uponQueue(.main) { result in
                guard let image = result.successValue else {
                    return
                }
                if let scaled = scaled {
                    self.faviconView.image = image.createScaled(scaled)
                } else {
                    self.faviconView.image = image
                }
            }
        }
    }

    func updateIcon(engine: OpenSearchEngine, scaled: CGSize) {
        switch Features.Icons.type {
        case .cliqz:
            if let url = URL(string: engine.searchTemplate.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""), url.isWebPage() {
                self.logoView.url = url.absoluteString
            }
        case .favicon:
            self.faviconView.image = engine.image?.createScaled(scaled)
        }
    }

}
