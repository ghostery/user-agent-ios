//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

protocol CliqzRefreshControlDelegate: class {
    func refreshControllAlphaDidChange(alpha: CGFloat)
    func refreshControllMinimumHeight() -> CGFloat
    func refreshControllDidRefresh()
}

struct CliqzRefreshControlUI {
    static let minimumActionHeight: CGFloat = 20.0
    static let maximumActionHeight: CGFloat = 40.0
}

class CliqzRefreshControl: UIView {

    private let centerAction = UIView()
    private weak var scrollView: UIScrollView?
    private var pullToRefreshAllowed: Bool = true

    weak var delegate: CliqzRefreshControlDelegate?

    init(scrollView: UIScrollView) {
        super.init(frame: CGRect.zero)
        self.scrollView = scrollView
        self.clipsToBounds = false
        self.backgroundColor = .red//Theme.browser.background
        self.setupContentView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.scrollView?.removeObserver(self, forKeyPath: "contentOffset")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.centerAction.layer.cornerRadius = self.centerAction.frame.width / 2
    }

    private func setupContentView() {
        self.centerAction.backgroundColor = .yellow
        self.addSubview(self.centerAction)
        self.centerAction.snp.makeConstraints { (make) in
            make.width.equalTo(self.centerAction.snp.height)
            make.height.greaterThanOrEqualTo(CliqzRefreshControlUI.minimumActionHeight).priority(.high)
            make.height.lessThanOrEqualTo(CliqzRefreshControlUI.maximumActionHeight).priority(.high)
            make.height.equalToSuperview().multipliedBy(0.2).priority(.medium)
            make.center.equalToSuperview()
        }
        self.scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = self.scrollView else {
            return
        }
        if self.pullToRefreshAllowed {
            if scrollView.contentOffset.y < 0.0 {
                let alpha = abs(scrollView.contentOffset.y) / 20
                self.alpha = min(alpha, 1.0)
            } else {
                self.pullToRefreshAllowed = scrollView.isTracking || scrollView.contentOffset.y == 0.0
                self.alpha = 0.0
            }
            self.delegate?.refreshControllAlphaDidChange(alpha: self.alpha)
            let headerHeight = self.delegate?.refreshControllMinimumHeight() ?? 0
            let offset = scrollView.contentOffset.y < 0 ? abs(scrollView.contentOffset.y) : 0
            self.snp.updateConstraints({ (make) in
                make.height.equalTo(max(headerHeight, headerHeight + offset))
            })
            let getMaxValue = self.centerAction.frame.height >= CliqzRefreshControlUI.maximumActionHeight
            if getMaxValue {
                self.centerAction.backgroundColor = .green
            } else {
                self.centerAction.backgroundColor = .yellow
            }
            if !scrollView.isDragging && getMaxValue {
                self.delegate?.refreshControllDidRefresh()
            }
        } else {
            if scrollView.isDecelerating {
                self.pullToRefreshAllowed  = scrollView.contentOffset.y == 0.0
            } else {
                self.pullToRefreshAllowed = !scrollView.isDragging && scrollView.contentOffset.y == 0.0
            }
        }
    }

}
