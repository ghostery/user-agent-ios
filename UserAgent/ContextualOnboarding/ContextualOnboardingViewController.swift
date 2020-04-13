//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared
import SnapKit

class ContextualOnboardingDitail {
    let backgroundGradientColors: [UIColor]
    let title: String
    let icon: UIImage?
    let description: String?
    let bullets: [String]?

    init(backgroundGradientColors: [UIColor], title: String, icon: UIImage? = nil, description: String? = nil, bullets: [String]? = nil) {
        self.backgroundGradientColors = backgroundGradientColors
        self.title = title
        self.icon = icon
        self.description = description
        self.bullets = bullets
    }
}

struct ContextualOnboardingUI {
    static let horizontalOffset: CGFloat = 30.0
    static let verticalOffset: CGFloat = 30.0
    static let spacing: CGFloat = 10.0
    static let minimumHeight: CGFloat = 40.0
    static let preferredContentWidth: CGFloat = 200.0
    static let swipeViewWidth: CGFloat = 30.0
    static let swipeViewHeight: CGFloat = 5.0
    static let backgroundAlpha: CGFloat = 0.3
}

class ContextualOnboardingViewController: UIViewController {

    private let detail: ContextualOnboardingDitail?
    private let profile: Profile?
    private let prefKey: String?

    private let backgroundView = GradientView()
    private let stackView = UIStackView()

    private var initialTouchPoint: CGPoint = .zero
    private var backgroundViewBottomConstrint: Constraint!

    private var isHorizontalSizeClassRegular: Bool {
        return UIScreen.main.traitCollection.horizontalSizeClass == .regular
    }

    init(contentDetail: ContextualOnboardingDitail, profile: Profile, prefKey: String) {
        self.detail = contentDetail
        self.profile = profile
        self.prefKey = prefKey
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = .clear
        if !self.isHorizontalSizeClassRegular {
            UIView.animate(withDuration: 0.1) {
                self.view.backgroundColor = UIColor.CliqzBlack.withAlphaComponent(ContextualOnboardingUI.backgroundAlpha)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !self.isHorizontalSizeClassRegular {
            self.view.backgroundColor = .clear
        }
    }

    // MARK: - Actions

    @objc func dontShowAgainButtonAction() {
        if let key = self.prefKey {
            self.profile?.prefs.setBool(true, forKey: key)
        }
        self.dismiss(animated: true)
    }

    @objc func okButtonAction() {
        self.dismiss(animated: true)
    }

    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)

        switch sender.state {
        case .began:
            self.initialTouchPoint = sender.location(in: self.view)
        case .changed:
            let point = sender.location(in: self.view)
            let offset: CGFloat = point.y - self.initialTouchPoint.y
            self.backgroundViewBottomConstrint.update(offset: max(0, offset))
            let alpha = ContextualOnboardingUI.backgroundAlpha - ContextualOnboardingUI.backgroundAlpha * progress
            self.view.backgroundColor = UIColor.CliqzBlack.withAlphaComponent(alpha)
        case .cancelled, .ended, .failed:
            let point = sender.location(in: self.view)
            let backgroundViewY = self.view.frame.height - self.backgroundView.frame.height
            if point.y - backgroundViewY > self.backgroundView.frame.height * 0.3 {
                self.dismiss(animated: true)
            } else {
                self.backgroundViewBottomConstrint.update(offset: 0)
                UIView.animate(withDuration: 0.1) {
                    self.view.backgroundColor = UIColor.CliqzBlack.withAlphaComponent(ContextualOnboardingUI.backgroundAlpha)
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }

    // MARK: - Private methods

    private func configureView() {
        self.configureBackgroundView()
        self.configureSwipeView()
        self.configureStackView()
        self.configureTitle()
        self.configureIcon()
        self.configureDescription()
        self.appendEmptyView(height: ContextualOnboardingUI.verticalOffset / 2)
        self.configureBullets()
        self.configureButtons()
    }

    private func configureBackgroundView() {
        var maskedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        if self.isHorizontalSizeClassRegular {
            maskedCorners.update(with: .layerMaxXMinYCorner)
            maskedCorners.update(with: .layerMaxXMaxYCorner)
        }
        self.backgroundView.clipsToBounds = true
        self.backgroundView.layer.maskedCorners = maskedCorners
        self.backgroundView.layer.cornerRadius = 15
        self.backgroundView.backgroundColor = .BrightBlue
        self.backgroundView.drawOptions = .centerTopCenterBottom
        self.backgroundView.colors = self.detail?.backgroundGradientColors ?? [.COLightBlue, .CODarkBlue]
        self.view.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            self.backgroundViewBottomConstrint = make.bottom.equalToSuperview().constraint
            if self.isHorizontalSizeClassRegular {
                make.top.equalToSuperview()
            } else {
                make.top.greaterThanOrEqualToSuperview().offset(self.view.bounds.height * 0.05)
            }
        }
        if !self.isHorizontalSizeClassRegular {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
            self.backgroundView.addGestureRecognizer(panGesture)
        }
    }

    private func configureSwipeView() {
        let view = UIView()
        view.backgroundColor = UIColor.LightSky.with(alpha: UIColor.AlphaLevel.fiftyPercent)
        view.layer.cornerRadius = ContextualOnboardingUI.swipeViewHeight / 2
        self.backgroundView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(ContextualOnboardingUI.verticalOffset / 3)
            make.width.equalTo(ContextualOnboardingUI.swipeViewWidth)
            make.height.equalTo(ContextualOnboardingUI.swipeViewHeight)
            make.centerX.equalToSuperview()
        }
    }

    private func configureStackView() {
        self.stackView.axis = .vertical
        self.stackView.spacing = ContextualOnboardingUI.spacing
        self.backgroundView.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.backgroundView).offset(-(ContextualOnboardingUI.verticalOffset + 2 * self.view.safeAreaInsets.bottom))
            make.top.equalToSuperview().offset(ContextualOnboardingUI.verticalOffset)
        }
    }

    private func configureTitle() {
        let view = UIView()
        view.backgroundColor = .clear
        let label = self.createLabel()
        label.text = self.detail?.title
        label.textColor = .White
        label.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(ContextualOnboardingUI.horizontalOffset)
            make.right.equalToSuperview().offset(-ContextualOnboardingUI.horizontalOffset)
            make.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(ContextualOnboardingUI.minimumHeight)
        }
        self.stackView.addArrangedSubview(view)
    }

    private func configureIcon() {
        guard let icon = self.detail?.icon?.withRenderingMode(.alwaysTemplate) else {
            return
        }
        let view = UIView()
        view.backgroundColor = .clear
        let imageView = UIImageView(image: icon)
        imageView.tintColor = .White
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-ContextualOnboardingUI.spacing)
            make.height.equalTo(3 * ContextualOnboardingUI.minimumHeight / 2)
        }
        self.stackView.addArrangedSubview(view)
    }

    private func configureDescription() {
        guard let description = self.detail?.description else {
            return
        }
        let view = UIView()
        view.backgroundColor = .clear
        let label = self.createLabel()
        label.text = description
        label.textColor = .LightSky
        label.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(ContextualOnboardingUI.horizontalOffset)
            make.right.equalToSuperview().offset(-ContextualOnboardingUI.horizontalOffset)
            make.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(ContextualOnboardingUI.minimumHeight)
        }
        self.stackView.addArrangedSubview(view)
    }

    private func configureBullets() {
        guard let bullets = self.detail?.bullets else {
            return
        }
        for bullet in bullets {
            let view = UIView()
            view.backgroundColor = .clear
            let label = self.createLabel()
            label.numberOfLines = 1
            label.textAlignment = .left
            label.text = "\u{2022} " + bullet
            label.textColor = .LightSky
            label.font = UIFont.systemFont(ofSize: 15)
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(2 * ContextualOnboardingUI.horizontalOffset)
                make.right.equalToSuperview().offset(-(2 * ContextualOnboardingUI.horizontalOffset))
                make.top.bottom.equalToSuperview()
                make.height.greaterThanOrEqualTo(ContextualOnboardingUI.minimumHeight / 4)
            }
            self.stackView.addArrangedSubview(view)
        }
        self.appendEmptyView(height: ContextualOnboardingUI.verticalOffset / 2)
    }

    private func configureButtons() {
        self.appendSeparator()
        self.configureDontShowAgainButton()
        self.appendSeparator()
        self.configureOkButton()
    }

    private func configureDontShowAgainButton() {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(dontShowAgainButtonAction), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitle(Strings.ContextualOnboarding.DontShowAgain, for: .normal)
        button.setTitleColor(.White, for: .normal)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(ContextualOnboardingUI.minimumHeight)
        }
        self.stackView.addArrangedSubview(button)
    }

    private func configureOkButton() {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(okButtonAction), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle(Strings.General.OKString.uppercased(), for: .normal)
        button.setTitleColor(.White, for: .normal)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(ContextualOnboardingUI.minimumHeight)
        }
        self.stackView.addArrangedSubview(button)
    }

    private func createLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private func appendSeparator() {
        self.appendEmptyView(height: 0.5, color: .DarkGrey)
    }

    private func appendEmptyView(height: CGFloat, color: UIColor = .clear) {
        let view = UIView()
        view.backgroundColor = color
        view.snp.makeConstraints { (make) in
            make.height.equalTo(height)
        }
        self.stackView.addArrangedSubview(view)
    }

}
