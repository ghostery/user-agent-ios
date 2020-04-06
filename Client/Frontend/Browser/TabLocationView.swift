/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared
import SnapKit
import XCGLogger
import Widgets

private let log = Logger.browserLogger

protocol TabLocationViewDelegate {
    func tabLocationViewDidTapLocation(_ tabLocationView: TabLocationView)
    func tabLocationViewDidLongPressLocation(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapShield(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapPageOptions(_ tabLocationView: TabLocationView, from button: UIButton)
    func tabLocationViewDidLongPressPageOptions(_ tabLocationVIew: TabLocationView)
    func tabLocationViewDidBeginDragInteraction(_ tabLocationView: TabLocationView)

    func tabLocationViewLocationAccessibilityActions(_ tabLocationView: TabLocationView) -> [UIAccessibilityCustomAction]?
}

private struct TabLocationViewUX {
    static let HostFontColor = UIColor.black
    static let BaseURLFontColor = UIColor.Grey50
    static let Spacing: CGFloat = 8
    static let PlaceholderLefPadding: CGFloat = 12
    static let StatusIconSize: CGFloat = 18
    static let TPIconSize: CGFloat = 24
    static let ButtonSize: CGFloat = 44
    static let URLBarPadding = 4
    static let PISeparator: CGFloat = 3
}

class TabLocationView: UIView {
    var delegate: TabLocationViewDelegate?
    var longPressRecognizer: UILongPressGestureRecognizer!
    var tapRecognizer: UITapGestureRecognizer!
    var contentView: UIStackView!

    fileprivate let menuBadge = BadgeWithBackdrop(imageName: "menuBadge", backdropCircleSize: 32)

    @objc dynamic var baseURLFontColor: UIColor = TabLocationViewUX.BaseURLFontColor {
        didSet { updateTextWithURL(text: self.urlbarText) }
    }

    var url: URL? {
        didSet {
            self.updateLockImageView()
            if self.url == nil {
                self.urlTextLabelAlignLeft(duration: 0.0)
            } else {
                self.urlTextLabelAlignCenter(duration: 0.0)
            }
            self.updateTextWithURL(text: self.urlbarText)
            self.updateStackViewSpacing()
            self.pageOptionsButton.isHidden = (self.url == nil)
            self.privacyIndicator.isHidden = self.url == nil
            setNeedsUpdateConstraints()
        }
    }

    lazy var placeholder: NSAttributedString = {
        return NSAttributedString(
            string: Strings.UrlBar.Placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: Theme.textField.placeholder])
    }()

    lazy var urlTextLabel: UILabel = {
        let label = DisplayTextLabel()
        label.accessibilityIdentifier = "url"
        label.accessibilityActionsSource = self
        label.font = UIConstants.DefaultChromeFont
        label.backgroundColor = .clear
        label.accessibilityLabel = "Address Bar"
        label.textAlignment = .left
        label.textColor = Theme.textField.placeholder
        return label
    }()

    fileprivate lazy var lockImageView: UIImageView = {
        let lockImageView = UIImageView(image: UIImage.templateImageNamed("lock_not_verified"))
        lockImageView.tintColor = Theme.textField.textAndTint
        lockImageView.isAccessibilityElement = true
        lockImageView.contentMode = .center
        lockImageView.accessibilityLabel = NSLocalizedString("Secure connection", comment: "Accessibility label for the lock icon, which is only present if the connection is secure")
        return lockImageView
    }()

    fileprivate func updateLockImageView() {
        let wasHidden = lockImageView.isHidden
        lockImageView.isHidden = (url == nil)
        if wasHidden != lockImageView.isHidden {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
        }

        if self.url?.scheme == SearchURL.scheme {
            self.lockImageView.image = nil
        } else if self.url?.scheme != "https" {
            self.lockImageView.image = UIImage.templateImageNamed("lock_not_verified")
        } else {
            self.lockImageView.image = UIImage.templateImageNamed("lock_verified")
        }
    }

    lazy var privacyIndicator: PrivacyIndicator.Widget = {
        let indicator = PrivacyIndicator.Widget()
        indicator.onTapBlock = { () -> Void in self.delegate?.tabLocationViewDidTapShield(self) }
        return indicator
    }()

    lazy var pageOptionsButton: ToolbarButton = {
        let pageOptionsButton = ToolbarButton(frame: .zero)
        pageOptionsButton.setImage(UIImage.templateImageNamed("menu-More-Options"), for: .normal)
        pageOptionsButton.addTarget(self, action: #selector(didPressPageOptionsButton), for: .touchUpInside)
        pageOptionsButton.isAccessibilityElement = true
        pageOptionsButton.isHidden = true
        pageOptionsButton.imageView?.contentMode = .left
        pageOptionsButton.accessibilityLabel = NSLocalizedString("Page Options Menu", comment: "Accessibility label for the Page Options menu button")
        pageOptionsButton.accessibilityIdentifier = "TabLocationView.pageOptionsButton"
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressPageOptionsButton))
        pageOptionsButton.addGestureRecognizer(longPressGesture)
        return pageOptionsButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        register(self, forTabEvents: .didGainFocus, .didToggleDesktopMode, .didToggleReaderMode, .didChangeContentBlocking)

        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressLocation))
        longPressRecognizer.delegate = self

        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLocation))
        tapRecognizer.delegate = self

        addGestureRecognizer(longPressRecognizer)
        addGestureRecognizer(tapRecognizer)

        let frontSpaceView = UIView()
        frontSpaceView.snp.makeConstraints { make in
            make.width.equalTo(TabLocationViewUX.Spacing)
        }

        let privacyIndicatorSeparator = UIView()
        privacyIndicatorSeparator.snp.makeConstraints { make in
            make.width.equalTo(TabLocationViewUX.PISeparator)
        }

        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        view.addSubview(urlTextLabel)
        self.urlTextLabel.snp.makeConstraints { (make) in
            let imageSize = self.lockImageView.image?.size.width ?? TabLocationViewUX.StatusIconSize
            let diff = TabLocationViewUX.ButtonSize - TabLocationViewUX.TPIconSize - TabLocationViewUX.Spacing - TabLocationViewUX.PISeparator
            make.centerX.equalToSuperview().offset((imageSize + diff) / 2)
            make.top.bottom.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        view.addSubview(lockImageView)
        self.lockImageView.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualToSuperview()
            make.right.equalTo(self.urlTextLabel.snp.left)
            make.top.bottom.equalToSuperview()
            make.width.equalTo((self.url == nil ? 0 : TabLocationViewUX.StatusIconSize))
            make.height.equalTo(TabLocationViewUX.ButtonSize)
        }
        let subviews = [frontSpaceView, privacyIndicator, privacyIndicatorSeparator, view, pageOptionsButton]
        contentView = UIStackView(arrangedSubviews: subviews)
        contentView.distribution = .fill
        contentView.alignment = .center
        addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(-2)
            make.left.bottom.right.equalTo(self)
        }

        privacyIndicator.snp.makeConstraints { make in
            make.width.equalTo(TabLocationViewUX.TPIconSize)
            make.height.equalTo(TabLocationViewUX.ButtonSize)
        }

        pageOptionsButton.snp.makeConstraints { make in
            make.size.equalTo(TabLocationViewUX.ButtonSize)
        }

        // Setup UIDragInteraction to handle dragging the location
        // bar for dropping its URL into other apps.
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.allowsSimultaneousRecognitionDuringLift = true
        self.addInteraction(dragInteraction)

        menuBadge.add(toParent: contentView)
        menuBadge.layout(onButton: pageOptionsButton)
        menuBadge.show(false)

        // Make Privacy Indicator the frontmost to capture a large tap area
        self.bringSubviewToFront(privacyIndicator)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var accessibilityElements: [Any]? {
        get {
            return [lockImageView, urlTextLabel, pageOptionsButton].filter { !$0.isHidden }
        }
        set {
            super.accessibilityElements = newValue
        }
    }

    func overrideAccessibility(enabled: Bool) {
        [lockImageView, urlTextLabel, pageOptionsButton].forEach {
            $0.isAccessibilityElement = enabled
        }
    }

    @objc func didPressPageOptionsButton(_ button: UIButton) {
        delegate?.tabLocationViewDidTapPageOptions(self, from: button)
    }

    @objc func didLongPressPageOptionsButton(_ recognizer: UILongPressGestureRecognizer) {
        delegate?.tabLocationViewDidLongPressPageOptions(self)
    }

    @objc func longPressLocation(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .began {
            delegate?.tabLocationViewDidLongPressLocation(self)
        }
    }

    @objc func tapLocation(_ recognizer: UITapGestureRecognizer) {
        self.animateToBecomeFirstResponder {
            self.delegate?.tabLocationViewDidTapLocation(self)
        }
    }

    func animateToBecomeFirstResponder(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        self.backgroundColor = Theme.textField.backgroundInOverlay
        self.urlTextLabelAlignLeft(duration: duration, completion: completion)
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = .fade
        animation.subtype = .fromTop
        animation.duration = duration
        self.urlTextLabel.layer.add(animation, forKey: "kCATransitionFade")
        self.updateTextWithURL(text: self.url?.absoluteString)
    }

    func animateToResignFirstResponder(duration: TimeInterval = 0.2) {
        guard let url = self.url else {
            return
        }
        self.urlTextLabelAlignCenter(duration: duration)
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = .fade
        animation.subtype = .fromTop
        animation.duration = duration
        self.urlTextLabel.layer.add(animation, forKey: "kCATransitionFade")
        self.updateTextWithURL(text: self.urlbarText)
    }

    private var urlbarText: String {
        guard let url = self.url else { return "" }
        if let searchUrl = SearchURL(url) {
            return searchUrl.query
        }
        return url.publicSuffix(additionalPartCount: 1) ?? ""
    }

    private func urlTextLabelAlignCenter(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        self.contentView.insertArrangedSubview(self.privacyIndicator, at: 1)
        self.urlTextLabel.snp.remakeConstraints { (make) in
            let imageSize = self.lockImageView.image?.size.width ?? TabLocationViewUX.StatusIconSize
            let diff = TabLocationViewUX.ButtonSize - TabLocationViewUX.TPIconSize - TabLocationViewUX.Spacing - TabLocationViewUX.PISeparator
            make.centerX.equalToSuperview().offset((imageSize + diff) / 2)
            make.top.bottom.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        self.lockImageView.snp.remakeConstraints { (make) in
            make.left.greaterThanOrEqualToSuperview()
            make.right.equalTo(self.urlTextLabel.snp.left)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(self.url == nil ? 0 : TabLocationViewUX.StatusIconSize)
            make.height.equalTo(TabLocationViewUX.ButtonSize)
        }
        UIView.animate(withDuration: duration, animations: {
            self.lockImageView.isHidden = false
            self.contentView.layoutIfNeeded()
        }) { (_) in
            completion?()
        }
    }

    private func urlTextLabelAlignLeft(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        self.privacyIndicator.removeFromSuperview()
        self.urlTextLabel.snp.remakeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        self.lockImageView.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(self.urlTextLabel.snp.left).offset(self.url == nil ? 0 : -4)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(0)
            make.height.equalTo(TabLocationViewUX.ButtonSize)
        }
        if duration != 0.0 {
            UIView.animate(withDuration: duration, animations: {
                self.lockImageView.isHidden = true
                self.contentView.layoutIfNeeded()
            }) { (_) in
                completion?()
            }
        } else {
            completion?()
        }
    }

    fileprivate func updateTextWithURL(text: String?) {
        if let text = text {
            self.urlTextLabel.text = text
            self.urlTextLabel.textColor = Theme.textField.textAndTint
        } else {
            self.urlTextLabel.attributedText = self.placeholder
            self.urlTextLabel.textColor = Theme.textField.placeholder
        }
    }

    fileprivate func updateStackViewSpacing() {
        let leftPadding = self.url == nil ? TabLocationViewUX.PlaceholderLefPadding : TabLocationViewUX.Spacing
        let frontView = self.contentView.arrangedSubviews.first
        if frontView?.frame.size.width != leftPadding {
            frontView?.snp.remakeConstraints({ (make) in
                make.width.equalTo(leftPadding)
            })
        }
    }
}

extension TabLocationView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // When long pressing a button make sure the textfield's long press gesture is not triggered
        return !(otherGestureRecognizer.view is UIButton)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // If the longPressRecognizer is active, fail the tap recognizer to avoid conflicts.
        return gestureRecognizer == longPressRecognizer && otherGestureRecognizer == tapRecognizer
    }
}

@available(iOS 11.0, *)
extension TabLocationView: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        // Ensure we actually have a URL in the location bar and that the URL is not local.
        guard let url = self.url, !InternalURL.isValid(url: url), let itemProvider = NSItemProvider(contentsOf: url) else {
            return []
        }

        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }

    func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
        delegate?.tabLocationViewDidBeginDragInteraction(self)
    }
}

extension TabLocationView: AccessibilityActionsSource {
    func accessibilityCustomActionsForView(_ view: UIView) -> [UIAccessibilityCustomAction]? {
        if view === urlTextLabel {
            return delegate?.tabLocationViewLocationAccessibilityActions(self)
        }
        return nil
    }
}

extension TabLocationView: Themeable {
    func applyTheme() {
        backgroundColor = Theme.textField.background
        urlTextLabel.textColor = self.url == nil ? Theme.textField.placeholder : Theme.textField.textAndTint

        pageOptionsButton.selectedTintColor = Theme.urlbar.pageOptionsSelected
        pageOptionsButton.unselectedTintColor = Theme.urlbar.pageOptionsUnselected
        pageOptionsButton.tintColor = pageOptionsButton.unselectedTintColor
        menuBadge.badge.tintBackground(color: .clear)
    }
}

extension TabLocationView: TabEventHandler {
    func tabDidChangeContentBlocking(_ tab: Tab) {
        updateBlockerStatus(forTab: tab)
    }

    private func updateBlockerStatus(forTab tab: Tab) {
        assertIsMainThread("UI changes must be on the main thread")
        guard let blocker = tab.contentBlocker else { return }
        let (arcs, strike) = PrivacyIndicatorTransformation
            .transform(status: blocker.status, stats: blocker.stats)
        self.privacyIndicator.update(arcs: arcs, strike: strike)
    }

    func tabDidGainFocus(_ tab: Tab) {
        updateBlockerStatus(forTab: tab)
        menuBadge.show(tab.changedUserAgent || tab.changedReaderMode)
    }

    func tabDidToggleDesktopMode(_ tab: Tab) {
        menuBadge.show(tab.changedUserAgent || tab.changedReaderMode)
    }

    func tabDidToggleReaderMode(_ tab: Tab) {
        menuBadge.show(tab.changedUserAgent || tab.changedReaderMode)
    }
}

private class DisplayTextLabel: UILabel {
    weak var accessibilityActionsSource: AccessibilityActionsSource?

    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            return accessibilityActionsSource?.accessibilityCustomActionsForView(self)
        }
        set {
            super.accessibilityCustomActions = newValue
        }
    }

}
