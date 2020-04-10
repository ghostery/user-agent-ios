/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SnapKit

private struct URLBarViewUX {
    static let TextFieldBorderColor = UIColor.Grey40
    static let TextFieldActiveBorderColor = UIColor.Blue40

    static let LocationLeftPadding: CGFloat = 10
    static let Padding: CGFloat = 10
    static let ButtonHeight: CGFloat = 36

    static let TextFieldCornerRadius: CGFloat = 18
    static let TextFieldBorderWidth: CGFloat = 0
    static let TextFieldBorderWidthSelected: CGFloat = 0
    static let ProgressBarHeight: CGFloat = 4

    static let TabsButtonRotationOffset: CGFloat = 1.5
    static let TabsButtonHeight: CGFloat = 18.0
    static let ToolbarButtonInsets = UIEdgeInsets(equalInset: Padding)

    static let LocationContainerShadowColor: CGColor = UIColor.CloudySky.cgColor
    static let LocationContainerShadowOpacity: Double  = 0.1
    static let LocationContainerShadowOffset: CGSize = CGSize(width: 0, height: 2)
    static let LocationContainerShadowRadius: CGFloat = 1
}

protocol URLBarDelegate: AnyObject {
    func urlBarDidPressTabs(_ urlBar: URLBarView)
    func urlBarDidPressStop(_ urlBar: URLBarView)
    func urlBarDidPressReload(_ urlBar: URLBarView)
    func urlBarDidEnterOverlayMode(_ urlBar: URLBarView)
    func urlBarDidLeaveOverlayMode(_ urlBar: URLBarView)
    func urlBarDidLongPressLocation(_ urlBar: URLBarView)
    func urlBarDidPressPageOptions(_ urlBar: URLBarView, from button: UIButton)
    func urlBarDidTapShield(_ urlBar: URLBarView)
    func urlBarLocationAccessibilityActions(_ urlBar: URLBarView) -> [UIAccessibilityCustomAction]?
    func urlBarDidPressScrollToTop(_ urlBar: URLBarView)
    func urlBar(_ urlBar: URLBarView, didRestoreText text: String)
    func urlBar(_ urlBar: URLBarView, didEnterText text: String)
    func urlBar(_ urlBar: URLBarView, didSubmitText text: String, completion: String?)
    // Returns either (search query, true) or (url, false).
    func urlBarDisplayTextForURL(_ url: URL?) -> (String?, Bool)
    func urlBarDidLongPressPageOptions(_ urlBar: URLBarView, from button: UIButton)
    func urlBarDidBeginDragInteraction(_ urlBar: URLBarView)
}

class URLBarView: UIView {
    // Additional UIAppearance-configurable properties
    @objc dynamic var locationBorderColor: UIColor = URLBarViewUX.TextFieldBorderColor {
        didSet {
            if !inOverlayMode {
                locationContainer.layer.borderColor = locationBorderColor.cgColor
            }
        }
    }
    @objc dynamic var locationActiveBorderColor: UIColor = URLBarViewUX.TextFieldActiveBorderColor {
        didSet {
            if inOverlayMode {
                locationContainer.layer.borderColor = locationActiveBorderColor.cgColor
            }
        }
    }

    weak var delegate: URLBarDelegate?
    weak var tabToolbarDelegate: TabToolbarDelegate?
    var helper: TabToolbarHelper?
    var isTransitioning: Bool = false {
        didSet {
            if isTransitioning {
                // Cancel any pending/in-progress animations related to the progress bar
                self.progressBar.setProgress(1, animated: false)
                self.progressBar.alpha = 0.0
            }
        }
    }

    var toolbarIsShowing = false
    var topTabsIsShowing = false

    fileprivate var locationTextField: ToolbarTextField?

    /// Overlay mode is the state where the lock/reader icons are hidden, the home panels are shown,
    /// and the Cancel button is visible (allowing the user to leave overlay mode). Overlay mode
    /// is *not* tied to the location text field's editing state; for instance, when selecting
    /// a panel, the first responder will be resigned, yet the overlay mode UI is still active.
    var inOverlayMode = false

    lazy var searchButton: ToolbarButton = {
        return ToolbarButton()
    }()

    lazy var locationView: TabLocationView = {
        let locationView = TabLocationView()
        locationView.layer.cornerRadius = URLBarViewUX.TextFieldCornerRadius
        locationView.translatesAutoresizingMaskIntoConstraints = false
        locationView.delegate = self
        return locationView
    }()

    lazy var locationContainer: UIView = {
        let locationContainer = TabLocationContainerView()
        locationContainer.layer.cornerRadius = URLBarViewUX.TextFieldCornerRadius
        locationContainer.translatesAutoresizingMaskIntoConstraints = false
        return locationContainer
    }()

    let line = UIView()

    lazy var tabsButton: TabsButton = {
        let tabsButton = TabsButton.tabTrayButton()
        tabsButton.accessibilityIdentifier = "URLBarView.tabsButton"
        tabsButton.inTopTabs = false
        return tabsButton
    }()

    private lazy var querySuggestionsInputAccessoryView: QuerySuggestionsInputAccessoryView = {
        let inputAccessoryView = QuerySuggestionsInputAccessoryView()
        inputAccessoryView.delegate = self
        return inputAccessoryView
    }()

    fileprivate lazy var progressBar: GradientProgressBar = {
        let progressBar = GradientProgressBar()
        progressBar.clipsToBounds = false
        return progressBar
    }()

    fileprivate lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.accessibilityIdentifier = "urlBar-cancel"
        cancelButton.accessibilityLabel = Strings.Hotkeys.BackTitle
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(Theme.general.controlTint, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelButton.addTarget(self, action: #selector(didClickCancel), for: .touchUpInside)
        cancelButton.alpha = 0
        cancelButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: URLBarViewUX.Padding, bottom: 0, right: URLBarViewUX.Padding)
        return cancelButton
    }()

    fileprivate lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = Theme.textField.separator
        return separator
    }()

    fileprivate lazy var scrollToTopButton: UIButton = {
        let button = UIButton()
        // This button interferes with accessibility of the URL bar as it partially overlays it, and keeps getting the VoiceOver focus
        // instead of the URL bar.
        // TO DO: figure out if there is an iOS standard way to do this that works with accessibility.
        button.isAccessibilityElement = false
        button.addTarget(self, action: #selector(tappedScrollToTopArea), for: .touchUpInside)
        return button
    }()

    var menuButton = ToolbarButton()
    var bookmarkButton = ToolbarButton()
    var forwardButton = ToolbarButton()
    var stopReloadButton = ToolbarButton()

    var backButton: ToolbarButton = {
        let backButton = ToolbarButton()
        backButton.accessibilityIdentifier = "URLBarView.backButton"
        return backButton
    }()

    lazy var actionButtons: [Themeable & UIButton] = [self.tabsButton, self.searchButton, self.menuButton, self.forwardButton,
                                                      self.backButton, self.stopReloadButton, ]

    var currentURL: URL? {
        get {
            return locationView.url as URL?
        }

        set(newURL) {
            locationView.url = newURL
            if let url = newURL {
                line.isHidden = inOverlayMode || InternalURL(url)?.isAboutHomeURL ?? false
            } else {
                line.isHidden = true
            }
        }
    }

    fileprivate let privateModeBadge = BadgeWithBackdrop(imageName: "privateModeBadge", backdropCircleColor: UIColor.ForgetMode)
    fileprivate let whatsNeweBadge = BadgeWithBackdrop(imageName: "menuBadge")

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        locationContainer.addSubview(locationView)
        locationContainer.addSubview(cancelButton)
        cancelButton.addSubview(separator)

        [scrollToTopButton, line, tabsButton, progressBar, self.searchButton,
         menuButton, forwardButton, backButton, stopReloadButton, locationContainer, ].forEach {
            addSubview($0)
        }

        privateModeBadge.add(toParent: self)
        self.whatsNeweBadge.add(toParent: self)
        self.whatsNeweBadge.show(false)

        helper = TabToolbarHelper(toolbar: self)
        setupConstraints()

        // Make sure we hide any views that shouldn't be showing in non-overlay mode.
        updateViewsForOverlayModeAndToolbarChanges()

        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: HideKeyboardSearchNotification, object: nil)
    }

    @objc fileprivate func hideKeyboard() {
        locationTextField?.resignFirstResponder()
    }

    fileprivate func setupConstraints() {

        line.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(self)
            make.height.equalTo(1)
        }

        scrollToTopButton.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.left.right.equalTo(self.locationContainer)
        }

        progressBar.snp.makeConstraints { make in
            make.top.equalTo(self.snp.bottom).inset(URLBarViewUX.ProgressBarHeight / 2)
            make.height.equalTo(URLBarViewUX.ProgressBarHeight)
            make.left.right.equalTo(self)
        }

        locationView.snp.makeConstraints { make in
            make.edges.equalTo(self.locationContainer)
        }

        cancelButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.safeArea.trailing)
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        separator.snp.makeConstraints { make in
            make.height.equalTo(cancelButton.snp.height).offset(-URLBarViewUX.Padding * 2)
            make.centerY.equalTo(cancelButton.snp.centerY)
            make.width.equalTo(1)
            make.leading.equalTo(cancelButton.snp.leading)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalTo(self.safeArea.leading).offset(URLBarViewUX.Padding)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        forwardButton.snp.makeConstraints { make in
            make.leading.equalTo(self.backButton.snp.trailing)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        stopReloadButton.snp.makeConstraints { make in
            make.leading.equalTo(self.forwardButton.snp.trailing)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        menuButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.safeArea.trailing).offset(-URLBarViewUX.Padding)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        self.searchButton.snp.makeConstraints { (make) in
            if UIDevice.current.isPhone {
                make.trailing.equalTo(self.tabsButton.snp.leading)
            } else {
                make.trailing.equalTo(self.menuButton.snp.leading)
            }
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        tabsButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.menuButton.snp.leading)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        privateModeBadge.layout(onButton: tabsButton)
        self.whatsNeweBadge.layout(onButton: self.menuButton)
    }

    override func updateConstraints() {
        super.updateConstraints()
        self.locationContainer.snp.remakeConstraints { make in
            if self.toolbarIsShowing {
                make.leading.equalTo(self.stopReloadButton.snp.trailing).offset(URLBarViewUX.Padding)
                make.trailing.equalTo(self.searchButton.snp.leading).offset(-URLBarViewUX.Padding)
            } else {
                // Otherwise, left align the location view
                make.leading.trailing.equalTo(self).inset(UIEdgeInsets(top: 0, left: URLBarViewUX.LocationLeftPadding, bottom: 0, right: URLBarViewUX.Padding))
            }

            make.centerY.equalTo(self)
            make.height.equalTo(UIConstants.URLBarViewHeight)
        }
        if inOverlayMode {
            self.cancelButton.snp.remakeConstraints { make in
                make.centerY.equalTo(self.locationContainer)
                make.height.equalTo(locationContainer.snp.height)
                make.trailing.equalTo(locationContainer.snp.trailing)
            }
            self.locationView.snp.remakeConstraints { make in
                make.edges.equalTo(self.locationContainer).inset(UIEdgeInsets(equalInset: URLBarViewUX.TextFieldBorderWidthSelected))
            }
            self.locationTextField?.snp.remakeConstraints { make in
                make.leading.equalTo(self.locationView.snp.leading).offset(15)
                make.trailing.equalTo(self.cancelButton.snp.leading).offset(-URLBarViewUX.Padding)
                make.top.equalTo(self.locationView.snp.top).offset(2)
                make.bottom.equalTo(self.locationView.snp.bottom)
            }
        } else {
            self.locationView.snp.remakeConstraints { make in
                make.edges.equalTo(self.locationContainer).inset(UIEdgeInsets(equalInset: URLBarViewUX.TextFieldBorderWidth))
            }
        }
        updateShadow()
    }

    private func updateShadow() {
        let opacity: Double = inOverlayMode ? URLBarViewUX.LocationContainerShadowOpacity : 0.0
        let offset: CGSize = inOverlayMode ? URLBarViewUX.LocationContainerShadowOffset : .zero
        let duration: TimeInterval = inOverlayMode ? 0.3 : 0.1
        animate(locationContainer.layer, to: opacity, and: offset, with: duration)
    }

    private func animate(_ layer: CALayer, to opacity: Double, and offset: CGSize, with duration: Double) {
        CATransaction.begin()
        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.toValue = opacity
        opacityAnimation.duration = duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.fillMode = .both
        opacityAnimation.isRemovedOnCompletion = false

        let offsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
        offsetAnimation.toValue = offset
        offsetAnimation.duration = duration
        offsetAnimation.timingFunction = opacityAnimation.timingFunction
        offsetAnimation.fillMode = opacityAnimation.fillMode
        offsetAnimation.isRemovedOnCompletion = false

        layer.add(offsetAnimation, forKey: offsetAnimation.keyPath!)
        layer.add(opacityAnimation, forKey: opacityAnimation.keyPath!)
        CATransaction.commit()
    }

    private func createLocationTextField() {
        guard locationTextField == nil else { return }

        locationTextField = ToolbarTextField()

        guard let locationTextField = locationTextField else { return }

        locationTextField.clipsToBounds = true
        locationTextField.translatesAutoresizingMaskIntoConstraints = false
        locationTextField.autocompleteDelegate = self
        locationTextField.keyboardType = .webSearch
        locationTextField.autocorrectionType = .no
        locationTextField.autocapitalizationType = .none
        locationTextField.returnKeyType = .go
        locationTextField.clearButtonMode = .whileEditing
        locationTextField.textAlignment = .left
        locationTextField.font = UIConstants.DefaultChromeFont
        locationTextField.accessibilityIdentifier = "address"
        locationTextField.accessibilityLabel = NSLocalizedString("Address and Search",
            comment: "Accessibility label for address and search field, both words (Address, Search) are therefore nouns.")
        locationTextField.attributedPlaceholder = self.locationView.placeholder
        locationContainer.addSubview(locationTextField)
        locationTextField.snp.remakeConstraints { make in
            make.leading.equalTo(self.locationView.snp.leading)
            make.trailing.equalTo(self.cancelButton.snp.trailing)
            make.top.equalTo(self.locationView.snp.top).offset(2)
            make.bottom.equalTo(self.locationView.snp.bottom)
        }
        // Disable dragging urls on iPhones because it conflicts with editing the text
        if UIDevice.current.userInterfaceIdiom != .pad {
            locationTextField.textDragInteraction?.isEnabled = false
        }

        locationTextField.applyTheme()
        locationTextField.backgroundColor = .clear
        locationTextField.inputAccessoryView = querySuggestionsInputAccessoryView
    }

    override func becomeFirstResponder() -> Bool {
        return self.locationTextField?.becomeFirstResponder() ?? false
    }

    private func removeLocationTextField() {
        locationTextField?.removeFromSuperview()
        locationTextField = nil
    }

    // Ideally we'd split this implementation in two, one URLBarView with a toolbar and one without
    // However, switching views dynamically at runtime is a difficult. For now, we just use one view
    // that can show in either mode.
    func setShowToolbar(_ shouldShow: Bool) {
        toolbarIsShowing = shouldShow
        setNeedsUpdateConstraints()
        // when we transition from portrait to landscape, calling this here causes
        // the constraints to be calculated too early and there are constraint errors
        if !toolbarIsShowing {
            updateConstraintsIfNeeded()
        }
        updateViewsForOverlayModeAndToolbarChanges()
    }

    func cancel() {
        self.didClickCancel()
    }

    func updateAlphaForSubviews(_ alpha: CGFloat) {
        locationContainer.alpha = alpha
        self.alpha = alpha
    }

    func updateProgressBar(_ progress: Float) {
        progressBar.alpha = 1
        progressBar.isHidden = self.inOverlayMode
        progressBar.setProgress(progress, animated: !isTransitioning)
    }

    func hideProgressBar() {
        progressBar.isHidden = true
        progressBar.setProgress(0, animated: false)
    }

    func setAutocompleteSuggestion(_ suggestion: String?) {
        locationTextField?.setAutocompleteSuggestion(suggestion)
    }

    func setLocation(_ location: String?, search: Bool) {
        guard let text = location, !text.isEmpty else {
            locationTextField?.text = location
            return
        }
        if search {
            locationTextField?.text = text
            // Not notifying when empty agrees with AutocompleteTextField.textDidChange.
            delegate?.urlBar(self, didRestoreText: text)
        } else {
            locationTextField?.setTextWithoutSearching(text)
        }
    }

    func enterOverlayMode(_ locationText: String?, pasted: Bool, search: Bool) {
        createLocationTextField()

        // Show the overlay mode UI, which includes hiding the locationView and replacing it
        // with the editable locationTextField.
        animateToOverlayState(overlayMode: true)

        delegate?.urlBarDidEnterOverlayMode(self)

        applyTheme()

        // Bug 1193755 Workaround - Calling becomeFirstResponder before the animation happens
        // won't take the initial frame of the label into consideration, which makes the label
        // look squished at the start of the animation and expand to be correct. As a workaround,
        // we becomeFirstResponder as the next event on UI thread, so the animation starts before we
        // set a first responder.
        if pasted {
            // Clear any existing text, focus the field, then set the actual pasted text.
            // This avoids highlighting all of the text.
            self.locationTextField?.text = ""
            DispatchQueue.main.async {
                self.locationTextField?.becomeFirstResponder()
                self.setLocation(locationText, search: search)
            }
        } else {
            self.locationTextField?.text = locationText
            DispatchQueue.main.async {
                guard let textField = self.locationTextField else {
                    return
                }
                textField.becomeFirstResponder()
                // Moveing text field cursor position to front.
                textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.beginningOfDocument)
                // Need to set location again so text could be immediately selected.
                self.setLocation(locationText, search: search)
                textField.selectAll(nil)
            }
        }

    }

    func leaveOverlayMode(didCancel cancel: Bool = false) {
        locationTextField?.resignFirstResponder()
        animateToOverlayState(overlayMode: false, didCancel: cancel)
        delegate?.urlBarDidLeaveOverlayMode(self)
        applyTheme()
    }

    func prepareOverlayAnimation() {
        // Make sure everything is showing during the transition (we'll hide it afterwards).
        bringSubviewToFront(self.locationContainer)
        cancelButton.isHidden = false
        progressBar.isHidden = false
        menuButton.isHidden = !toolbarIsShowing
        self.searchButton.isHidden = !toolbarIsShowing
        forwardButton.isHidden = !toolbarIsShowing
        backButton.isHidden = !toolbarIsShowing
        tabsButton.isHidden = !toolbarIsShowing || topTabsIsShowing
        stopReloadButton.isHidden = !toolbarIsShowing
    }

    func transitionToOverlay(_ didCancel: Bool = false) {
        locationView.contentView.alpha = inOverlayMode ? 0 : 1
        cancelButton.alpha = inOverlayMode ? 1 : 0
        progressBar.alpha = inOverlayMode || didCancel ? 0 : 1
        tabsButton.alpha = inOverlayMode ? 0 : 1
        menuButton.alpha = inOverlayMode ? 0 : 1
        self.searchButton.alpha = inOverlayMode ? 0 : 1
        forwardButton.alpha = inOverlayMode ? 0 : 1
        backButton.alpha = inOverlayMode ? 0 : 1
        stopReloadButton.alpha = inOverlayMode ? 0 : 1

        let borderColor = inOverlayMode ? locationActiveBorderColor : locationBorderColor
        locationContainer.layer.borderColor = borderColor.cgColor

        if inOverlayMode {
            line.isHidden = inOverlayMode
            // Make the editable text field span the entire URL bar, covering the lock and reader icons.
            locationTextField?.snp.remakeConstraints { make in
                make.leading.equalTo(self.locationView.snp.leading)
                make.trailing.equalTo(self.cancelButton.snp.trailing)
                make.top.equalTo(self.locationView.snp.top).offset(2)
                make.bottom.equalTo(self.locationView.snp.bottom)
            }
        } else {
            // Shrink the editable text field back to the size of the location view before hiding it.
            locationTextField?.snp.remakeConstraints { make in
                make.left.bottom.right.equalTo(self.locationView.urlTextLabel)
                make.top.equalTo(self.locationView.urlTextLabel).offset(2)
            }
            cancelButton.snp.remakeConstraints { make in
                make.centerY.equalTo(self.locationContainer)
                make.height.equalTo(locationContainer.snp.height)
                make.leading.equalTo(locationView.snp.trailing)
            }
        }
    }

    func updateViewsForOverlayModeAndToolbarChanges() {
        // This ensures these can't be selected as an accessibility element when in the overlay mode.
        locationView.overrideAccessibility(enabled: !inOverlayMode)

        cancelButton.isHidden = !inOverlayMode
        progressBar.isHidden = inOverlayMode
        menuButton.isHidden = !toolbarIsShowing || inOverlayMode
        self.searchButton.isHidden = !toolbarIsShowing || inOverlayMode
        forwardButton.isHidden = !toolbarIsShowing || inOverlayMode
        backButton.isHidden = !toolbarIsShowing || inOverlayMode
        tabsButton.isHidden = !toolbarIsShowing || inOverlayMode || topTabsIsShowing
        stopReloadButton.isHidden = !toolbarIsShowing || inOverlayMode

        // badge isHidden is tied to private mode on/off, use alpha to hide in this case
        [privateModeBadge, whatsNeweBadge].forEach {
            $0.badge.alpha = (!toolbarIsShowing || inOverlayMode) ? 0 : 1
            $0.backdrop.alpha = (!toolbarIsShowing || inOverlayMode) ? 0 : BadgeWithBackdrop.backdropAlpha
        }

    }

    func animateToOverlayState(overlayMode overlay: Bool, didCancel cancel: Bool = false) {
        prepareOverlayAnimation()
        layoutIfNeeded()

        inOverlayMode = overlay

        if !overlay {
            removeLocationTextField()
        }

        self.transitionToOverlay(cancel)
        self.setNeedsUpdateConstraints()
        self.layoutIfNeeded()
        self.updateViewsForOverlayModeAndToolbarChanges()
    }

    func didClickAddTab() {
        delegate?.urlBarDidPressTabs(self)
    }

    @objc func didClickCancel() {
        leaveOverlayMode(didCancel: true)
    }

    @objc func tappedScrollToTopArea() {
        delegate?.urlBarDidPressScrollToTop(self)
    }

    func closeKeyboard() {
        self.locationTextField?.resignFirstResponder()
    }
}

extension URLBarView: TabToolbarProtocol {

    func privateModeBadge(visible: Bool) {
        if !UIDevice.current.isPad {
            privateModeBadge.show(visible)
        }
    }

    func whatsNeweBadge(visible: Bool) {
        if UIDevice.current.isPad {
            self.whatsNeweBadge.show(visible)
        }
    }

    func searchBadge(visible: Bool) {
        let image = visible ? UIImage.templateImageNamed("AddSearch") : UIImage.templateImageNamed("search")
        self.searchButton.setImage(image, for: .normal)
    }

    func updateBackStatus(_ canGoBack: Bool) {
        backButton.isEnabled = canGoBack
    }

    func updateForwardStatus(_ canGoForward: Bool) {
        forwardButton.isEnabled = canGoForward
    }

    func updateTabCount(_ count: Int, animated: Bool = true) {
        tabsButton.updateTabCount(count, animated: animated)
    }

    func updateReloadStatus(_ isLoading: Bool) {
        helper?.updateReloadStatus(isLoading)
        if isLoading {
            stopReloadButton.setImage(helper?.ImageStop, for: .normal)
        } else {
            stopReloadButton.setImage(helper?.ImageReload, for: .normal)
        }
    }

    func updatePageStatus(_ isWebPage: Bool) {
        stopReloadButton.isEnabled = isWebPage
    }

    var access: [Any]? {
        get {
            if inOverlayMode {
                guard let locationTextField = locationTextField else { return nil }
                return [locationTextField, cancelButton]
            } else {
                if toolbarIsShowing {
                    return [backButton, forwardButton, stopReloadButton, locationView, tabsButton, self.searchButton, menuButton, progressBar]
                } else {
                    return [locationView, progressBar]
                }
            }
        }
        set {
            super.accessibilityElements = newValue
        }
    }
}

extension URLBarView: TabLocationViewDelegate {

    func tabLocationViewDidTapLocation(_ tabLocationView: TabLocationView) {
        guard let (locationText, isSearchQuery) = delegate?.urlBarDisplayTextForURL(locationView.url as URL?) else { return }
        enterOverlayMode(locationText, pasted: false, search: isSearchQuery)
    }

    func tabLocationViewDidLongPressLocation(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidLongPressLocation(self)
    }

    func tabLocationViewDidTapReload(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidPressReload(self)
    }

    func tabLocationViewDidTapStop(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidPressStop(self)
    }

    func tabLocationViewDidTapPageOptions(_ tabLocationView: TabLocationView, from button: UIButton) {
        delegate?.urlBarDidPressPageOptions(self, from: tabLocationView.pageOptionsButton)
    }

    func tabLocationViewDidLongPressPageOptions(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidLongPressPageOptions(self, from: tabLocationView.pageOptionsButton)
    }

    func tabLocationViewLocationAccessibilityActions(_ tabLocationView: TabLocationView) -> [UIAccessibilityCustomAction]? {
        return delegate?.urlBarLocationAccessibilityActions(self)
    }

    func tabLocationViewDidBeginDragInteraction(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidBeginDragInteraction(self)
    }

    func tabLocationViewDidTapShield(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidTapShield(self)
    }
}

extension URLBarView: AutocompleteTextFieldDelegate {
    func autocompleteTextFieldShouldReturn(_ autocompleteTextField: AutocompleteTextField, completion: String?) -> Bool {
        guard let text = locationTextField?.text else { return true }
        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
            delegate?.urlBar(self, didSubmitText: text, completion: completion)
            return true
        } else {
            return false
        }
    }

    func autocompleteTextField(_ autocompleteTextField: AutocompleteTextField, didEnterText text: String) {
        delegate?.urlBar(self, didEnterText: text)
    }

    func autocompleteTextFieldShouldClear(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        delegate?.urlBar(self, didEnterText: "")
        return true
    }

    func autocompleteTextFieldDidCancel(_ autocompleteTextField: AutocompleteTextField) {
        leaveOverlayMode(didCancel: true)
    }

    func autocompletePasteAndGo(_ autocompleteTextField: AutocompleteTextField) {
        if let pasteboardContents = UIPasteboard.general.string {
            self.delegate?.urlBar(self, didSubmitText: pasteboardContents, completion: nil)
        }
    }

    func autocompleteDidEndEditing(_ autocompleteTextField: AutocompleteTextField) {
        self.locationView.animateToResignFirstResponder()
    }

}

extension URLBarView: Themeable {
    func applyTheme() {
        locationView.applyTheme()
        locationTextField?.applyTheme()

        actionButtons.forEach { $0.applyTheme() }
        tabsButton.applyTheme()
        backgroundColor = .clear
        line.backgroundColor = Theme.browser.urlBarDivider

        locationBorderColor = Theme.urlbar.border

        if inOverlayMode {
            locationView.backgroundColor = Theme.textField.backgroundInOverlay
        } else {
            locationView.backgroundColor = Theme.urlbar.background
        }

        locationContainer.backgroundColor = .clear

        privateModeBadge.badge.tintBackground(color: Theme.browser.background)
        self.whatsNeweBadge.badge.tintBackground(color: .clear)
        cancelButton.setTitleColor(Theme.general.controlTint, for: .normal)
    }
}

extension URLBarView: PrivateModeUI {
    func applyUIMode(isPrivate: Bool) {
        if !UIDevice.current.isPad {
            privateModeBadge.show(isPrivate)
        }

        locationActiveBorderColor = Theme.urlbar.activeBorder(isPrivate)
        progressBar.setGradientColors(startColor: Theme.loadingBar.start(isPrivate),
                                      endColor: Theme.loadingBar.end(isPrivate))
        ToolbarTextField.applyUIMode(isPrivate: isPrivate)

        applyTheme()
    }
}

extension URLBarView: QuerySuggestionDelegate {
    func querySuggestionTapped(_ suggestion: String) {
        locationTextField?.text = suggestion
    }
}

// We need a subclass so we can setup the shadows correctly
// This subclass creates a strong shadow on the URLBar
class TabLocationContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let layer = self.layer
        layer.masksToBounds = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ToolbarTextField: AutocompleteTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - bounds.height / 2, y: 0, width: bounds.height / 2, height: bounds.height)
    }
}

extension ToolbarTextField: Themeable {
    func applyTheme() {
        textColor = Theme.textField.textAndTint
    }

    // ToolbarTextField is created on-demand, so the textSelectionColor is a static prop for use when created
    static func applyUIMode(isPrivate: Bool) {
       textSelectionColor = Theme.urlbar.textSelectionHighlight(isPrivate)
    }
}
