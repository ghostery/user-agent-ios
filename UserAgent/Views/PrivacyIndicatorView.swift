//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

private class BadgeView: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = ""
        label.font = label.font.withSize(10)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func update(_ count: Int) {
        label.text = String(count)
    }

    private func setupView() {
        layer.cornerRadius = 3
        backgroundColor = .Grey60
        addSubview(label)
        setupLayout()
    }

    private func setupLayout() {
        label.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.topMargin.bottomMargin.equalTo(0)
            make.leftMargin.rightMargin.equalTo(2)
        }
    }
}

class PrivacyIndicatorView: UIView {
    public var onButtonTap: (() -> Void)?

    private lazy var enabledIcon = { UIImage.templateImageNamed("tracking-protection") }()
    private lazy var disabledIcon = { UIImage.templateImageNamed("tracking-protection-off") }()

    private lazy var badge = { BadgeView() }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.templateImageNamed("tracking-protection"), for: .normal)
        button.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        button.tintColor = UIColor.Grey50
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    @objc
    private func didPressButton(_ button: UIButton) {
        onButtonTap?()
    }

    func updateBadge(_ count: Int) {
        badge.update(count)
    }

    func showStatusDisabled() {
        guard button.currentImage != disabledIcon else { return }
        badge.isHidden = true
        button.setImage(disabledIcon, for: .normal)
    }

    func showStatusEnabled() {
        guard button.currentImage != enabledIcon else { return }
        badge.isHidden = false
        button.setImage(enabledIcon, for: .normal)
    }

    private func setupView() {
        isHidden = true
        addSubview(button)
        addSubview(badge)
        setupLayout()
    }

    private func setupLayout() {
        button.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalTo(self)
        }

        badge.snp.makeConstraints { make in
            make.right.equalTo(self)
            make.top.equalTo(6)
        }
    }
}
