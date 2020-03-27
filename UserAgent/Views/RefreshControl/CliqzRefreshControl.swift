//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

protocol CliqzRefreshControlDelegate: class {
    func refreshControllAlphaDidChange(alpha: CGFloat)
    func refreshControllMinimumHeight() -> CGFloat
    func refreshControllDidRefresh()
    func isRefreshing() -> Bool
}

struct CliqzRefreshControlUI {
    static let minimumActionHeight: CGFloat = 20.0
    static var maximumActionHeight: CGFloat {
        if UIDevice.current.isPhone {
            if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight {
                return 30.0
            }
            return 50.0
        }
        return 60.0
    }
}

class CliqzRefreshControl: UIView {

    private let centerAction = UIView()
    private let titleLabel = UILabel()
    private let refreshImageView = UIImageView(image: UIImage(named: "nav-refresh"))

    private weak var scrollView: UIScrollView?
    private weak var animationView: UIView?
    private var pullToRefreshAllowed: Bool = true {
        didSet {
            self.isTrackingStarted = !self.pullToRefreshAllowed
        }
    }
    private var isTrackingStarted: Bool = false

    var isEnabled: Bool = true

    weak var delegate: CliqzRefreshControlDelegate?

    init(scrollView: UIScrollView) {
        super.init(frame: CGRect.zero)
        self.scrollView = scrollView
        self.clipsToBounds = true
        self.backgroundColor = Theme.browser.background
        self.alpha = 0.0
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
        self.animationView?.layer.cornerRadius = (self.animationView?.frame.width ?? 0) / 2
        self.centerAction.layer.cornerRadius = self.centerAction.frame.width / 2
    }

    private func setupContentView() {
        self.setupCenterAction()
        self.setupTitle()
        self.scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }

    private func setupCenterAction() {
        self.centerAction.backgroundColor = UIColor.Grey40
        self.addSubview(self.centerAction)
        self.centerAction.snp.makeConstraints { (make) in
            make.width.equalTo(self.centerAction.snp.height)
            make.height.greaterThanOrEqualTo(CliqzRefreshControlUI.minimumActionHeight).priority(.high)
            make.height.lessThanOrEqualTo(CliqzRefreshControlUI.maximumActionHeight).priority(.high)
            make.height.equalToSuperview().multipliedBy(0.25).priority(.medium)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(10)
        }
        self.centerAction.addSubview(self.refreshImageView)
        self.refreshImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(2 * CliqzRefreshControlUI.minimumActionHeight / 3)
        }
    }

    private func setupTitle() {
        self.titleLabel.text = Strings.RefreshControl.ReloadLabel
        self.titleLabel.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(self.titleLabel)
        self.titleLabel.isHidden = true
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.centerAction.snp.bottom).offset(5)
            make.centerX.equalTo(self.centerAction)
        }
    }

    private func animateBubble() {
        let view = UIView(frame: self.centerAction.frame)
        view.clipsToBounds = true
        view.backgroundColor = self.centerAction.backgroundColor
        view.layer.cornerRadius = view.frame.width / 2
        self.insertSubview(view, belowSubview: self.centerAction)
        self.animationView = view
        view.snp.makeConstraints { (make) in
            make.center.equalTo(self.centerAction)
            make.width.height.equalTo(self.centerAction)
        }
        UIView.animate(withDuration: 0.2, animations: {
            view.layer.cornerRadius = view.frame.width / 2
            view.snp.remakeConstraints { (make) in
                make.center.equalTo(self.centerAction)
                make.width.height.equalTo(self.snp.width)
            }
            self.layoutIfNeeded()
        }) { (_) in
            view.removeFromSuperview()
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard self.isEnabled && !(self.scrollView?.isZooming ?? true) else {
            return
        }
        guard let scrollView = self.scrollView, scrollView.contentOffset.y <= 0 else {
            if self.alpha != 0 {
                self.alpha = 0
                self.delegate?.refreshControllAlphaDidChange(alpha: self.alpha)
            }
            return
        }
        guard self.isTrackingStarted || scrollView.isTracking else {
            return
        }
        self.isTrackingStarted = true
        if self.pullToRefreshAllowed {
            if scrollView.contentOffset.y >= 0.0 {
                self.pullToRefreshAllowed = scrollView.isTracking || scrollView.contentOffset.y == 0.0
            }
            self.handlePullToRefresh(scrollView: scrollView)
        } else {
            if scrollView.isDecelerating {
                self.pullToRefreshAllowed = scrollView.contentOffset.y == 0.0
            } else {
                self.pullToRefreshAllowed = !scrollView.isDragging && scrollView.contentOffset.y == 0.0
            }
        }
    }

    private func handlePullToRefresh(scrollView: UIScrollView) {
        self.alpha = scrollView.contentOffset.y < 0.0 ? min((abs(scrollView.contentOffset.y) / 20), 1.0) : 0.0
        self.delegate?.refreshControllAlphaDidChange(alpha: self.alpha)
        let headerHeight = self.delegate?.refreshControllMinimumHeight() ?? 0
        let offset = scrollView.contentOffset.y < 0 ? abs(scrollView.contentOffset.y) : 0
        self.snp.updateConstraints({ (make) in
            make.height.equalTo(max(headerHeight, headerHeight + offset))
        })
        let getMaxValue = self.centerAction.frame.height >= CliqzRefreshControlUI.maximumActionHeight
        self.titleLabel.isHidden = !getMaxValue
        if !scrollView.isDragging && getMaxValue && !(self.delegate?.isRefreshing() ?? false) {
            self.animateBubble()
            self.delegate?.refreshControllDidRefresh()
        }
    }

}
