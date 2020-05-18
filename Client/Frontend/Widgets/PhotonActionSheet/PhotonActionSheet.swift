/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Storage
import SnapKit
import Shared

// This file is main table view used for the action sheet

class PhotonActionSheet: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, Themeable {
    fileprivate(set) var actions: [[PhotonActionSheetItem]]

    private var site: Site?
    private let style: PresentationStyle
    private var tintColor = Theme.actionMenu.foreground
    private var heightConstraint: Constraint?
    var tableView = UITableView(frame: .zero, style: .grouped)

    lazy var tapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(dismiss))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        return tapRecognizer
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.General.CloseString, for: .normal)
        button.setTitleColor(Theme.actionMenu.closeButtonTitleColor, for: .normal)
        button.layer.cornerRadius = PhotonActionSheetUX.CornerRadius
        button.titleLabel?.font = DynamicFontHelper.defaultHelper.DeviceFontExtraLargeBold
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        button.accessibilityIdentifier = "PhotonMenu.close"
        return button
    }()

    var photonTransitionDelegate: UIViewControllerTransitioningDelegate? {
        didSet {
            self.transitioningDelegate = photonTransitionDelegate
        }
    }

    init(site: Site, actions: [PhotonActionSheetItem], closeButtonTitle: String = Strings.General.CloseString) {
        self.site = site
        self.actions = [actions]
        self.style = .centered
        super.init(nibName: nil, bundle: nil)
        self.closeButton.setTitle(closeButtonTitle, for: .normal)
    }

    init(title: String? = nil, actions: [[PhotonActionSheetItem]], closeButtonTitle: String = Strings.General.CloseString, style presentationStyle: UIModalPresentationStyle? = nil) {
        self.actions = actions
        if let presentationStyle = presentationStyle {
            self.style = presentationStyle == .popover ? .popover : .bottom
        } else {
            self.style = .centered
        }
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.closeButton.setTitle(closeButtonTitle, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if style == .centered {
            applyBackgroundBlur()
            self.tintColor = UIConstants.SystemBlueColor
        }

        view.addGestureRecognizer(tapRecognizer)
        view.addSubview(tableView)
        view.accessibilityIdentifier = "Action Sheet"

        tableView.backgroundColor = .clear

        // In a popover the popover provides the blur background
        // Not using a background color allows the view to style correctly with the popover arrow
        if self.popoverPresentationController == nil {
            let blurEffect = UIBlurEffect(style: Theme.actionMenu.iPhoneBackgroundBlurStyle)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            tableView.backgroundView = blurEffectView
        }

        let width = min(self.view.frame.size.width, PhotonActionSheetUX.MaxWidth) - (PhotonActionSheetUX.Padding * 2)

        if style == .bottom {
            self.view.addSubview(closeButton)
            closeButton.snp.makeConstraints { make in
                make.centerX.equalTo(self.view.snp.centerX)
                make.width.equalTo(width)
                make.height.equalTo(PhotonActionSheetUX.CloseButtonHeight)
                make.bottom.equalTo(self.view.safeArea.bottom).inset(PhotonActionSheetUX.Padding)
            }
        }

        if style == .popover {
            tableView.snp.makeConstraints { make in
                make.top.bottom.equalTo(self.view)
                make.width.equalTo(400)
            }
        } else {
            tableView.snp.makeConstraints { make in
                make.centerX.equalTo(self.view.snp.centerX)
                switch style {
                case .bottom, .popover:
                    make.bottom.equalTo(closeButton.snp.top).offset(-PhotonActionSheetUX.Padding)
                case .centered:
                    make.centerY.equalTo(self.view.snp.centerY)
                }
                make.width.equalTo(width)
            }
        }
    }

    func applyTheme() {

        if self.popoverPresentationController == nil {
            let blurEffect = UIBlurEffect(style: Theme.actionMenu.iPhoneBackgroundBlurStyle)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            self.tableView.backgroundView = blurEffectView
        }

        if style == .popover {
            view.backgroundColor = Theme.browser.background.withAlphaComponent(0.7)
        } else {
            tableView.backgroundView?.backgroundColor = Theme.actionMenu.iPhoneBackground
        }

        tintColor = Theme.actionMenu.foreground
        closeButton.backgroundColor = Theme.actionMenu.closeButtonBackground

        tableView.reloadData()
    }

    @objc func stopRotateSyncIcon() {
        ensureMainThread {
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(PhotonActionSheetCollectionCell.self, forCellReuseIdentifier: PhotonActionSheetUX.CollectionCellName)
        tableView.register(PhotonActionSheetCell.self, forCellReuseIdentifier: PhotonActionSheetUX.CellName)
        tableView.register(PhotonCustomViewCell.self, forCellReuseIdentifier: String(describing: PhotonCustomViewCell.self))
        tableView.register(PhotonActionSheetSiteHeaderView.self, forHeaderFooterViewReuseIdentifier: PhotonActionSheetUX.SiteHeaderName)
        tableView.register(PhotonActionSheetTitleHeaderView.self, forHeaderFooterViewReuseIdentifier: PhotonActionSheetUX.TitleHeaderName)
        tableView.register(PhotonActionSheetSeparator.self, forHeaderFooterViewReuseIdentifier: "SeparatorSectionHeader")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "EmptyHeader")
        tableView.estimatedRowHeight = PhotonActionSheetUX.RowHeight
        tableView.estimatedSectionFooterHeight = PhotonActionSheetUX.HeaderFooterHeight
        // When the menu style is centered the header is much bigger than default. Set a larger estimated height to make sure autolayout
        // sizes the view correctly
        tableView.estimatedSectionHeaderHeight = (style == .centered) ? PhotonActionSheetUX.RowHeight : PhotonActionSheetUX.HeaderFooterHeight
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.layer.cornerRadius = PhotonActionSheetUX.CornerRadius
        tableView.separatorStyle = .none
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.accessibilityIdentifier = "Context Menu"
        let footer = UIView(frame: CGRect(width: tableView.frame.width, height: PhotonActionSheetUX.Padding))
        tableView.tableHeaderView = footer
        tableView.tableFooterView = footer.clone()

        applyTheme()

        DispatchQueue.main.async {
            // Pick up the correct/final tableview.contentsize in order to set the height.
            // Without async dispatch, the contentsize is wrong.
            self.view.setNeedsLayout()
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if style == .popover {
            self.preferredContentSize = self.tableView.contentSize
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frameHeight: CGFloat
        frameHeight = view.safeAreaLayoutGuide.layoutFrame.size.height
        let maxHeight = frameHeight - (style == .bottom ? PhotonActionSheetUX.CloseButtonHeight : 0)
        tableView.snp.makeConstraints { make in
            heightConstraint?.deactivate()
            // The height of the menu should be no more than 85 percent of the screen
            heightConstraint = make.height.equalTo(min(self.tableView.contentSize.height, maxHeight * 0.90)).constraint
        }
    }

    private func applyBackgroundBlur() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let screenshot = appDelegate.window?.screenshot() {
            let blurredImage = screenshot.applyBlur(withRadius: 5,
                                                    blurType: BOXFILTER,
                                                    tintColor: UIColor.black.withAlphaComponent(0.2),
                                                    saturationDeltaFactor: 1.8,
                                                    maskImage: nil)
            let imageView = UIImageView(image: blurredImage)
            view.addSubview(imageView)
        }
    }

    @objc func dismiss(_ gestureRecognizer: UIGestureRecognizer?) {
        self.dismiss(animated: true, completion: nil)
    }

    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass
            || self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            updateViewConstraints()
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if tableView.frame.contains(touch.location(in: self.view)) {
            return false
        }
        return true
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return actions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions[section].count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var action = actions[indexPath.section][indexPath.row]
        guard let handler = action.handler else {
            self.dismiss(nil)
            return
        }

        // Switches can be toggled on/off without dismissing the menu
        if action.accessory == .Switch {
            HapticFeedback.vibrate(style: .medium)
            action.isEnabled.toggle()
            actions[indexPath.section][indexPath.row] = action
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadData()
        } else {
            self.dismiss(nil)
        }

        return handler(action)
    }

    func tableView(_ tableView: UITableView, hasFullWidthSeparatorForRowAtIndexPath indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let action = actions[indexPath.section][indexPath.row]

        if action.customView != nil {
            return photonCustomViewCell(for: action, tableView, indexPath)
        } else if !(action.collectionItems?.isEmpty ?? true) {
            return photonActionSheetCollectionCell(for: action, tableView, indexPath)
        } else {
            return photonActionSheetCell(for: action, tableView, indexPath)
        }
    }

    private func configureRemoveActionIfNeeded(for cell: PhotonActionSheetCell, action: PhotonActionSheetItem) {
        if action.accessory == .Remove {
            cell.didRemove = { [weak self] cell in
                if let indexPath = self?.tableView.indexPath(for: cell), let action = self?.actions[indexPath.section][indexPath.row] {
                    self?.actions[indexPath.section].remove(at: indexPath.row)
                    CATransaction.begin()
                    self?.tableView.beginUpdates()
                    CATransaction.setCompletionBlock {
                        self?.view.setNeedsLayout()
                    }
                    self?.tableView.deleteRows(at: [indexPath], with: .left)
                    self?.tableView.endUpdates()
                    CATransaction.commit()
                    action.didRemoveHandler?(action)
                }
            }
        }
    }

    private func photonActionSheetCell(for action: PhotonActionSheetItem,
                                       _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotonActionSheetUX.CellName, for: indexPath) as! PhotonActionSheetCell
        cell.tintColor = self.tintColor
        cell.configure(with: action)
        self.configureRemoveActionIfNeeded(for: cell, action: action)
        return cell
    }

    private func photonActionSheetCollectionCell(for action: PhotonActionSheetItem,
                                                 _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotonActionSheetUX.CollectionCellName, for: indexPath) as! PhotonActionSheetCollectionCell
        cell.delegate = self
        cell.tintColor = self.tintColor
        cell.configure(with: action)
        return cell
    }

    private func photonCustomViewCell(for action: PhotonActionSheetItem,
                                      _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PhotonCustomViewCell.self), for: indexPath) as! PhotonCustomViewCell
        cell.tintColor = self.tintColor
        cell.customView = action.customView
        cell.onSizeChange = { [weak self] in
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self?.view.setNeedsLayout()
            }
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
            CATransaction.commit()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if site != nil {
                return PhotonActionSheetUX.TitleHeaderSectionHeightWithSite
            } else if title != nil {
                return PhotonActionSheetUX.TitleHeaderSectionHeight
            }
            return 6
        }

        return PhotonActionSheetUX.SeparatorRowHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // If we have multiple sections show a separator for each one except the first.
        if section > 0 {
            let separator = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SeparatorSectionHeader") as? PhotonActionSheetSeparator
            separator?.applyTheme()
            return separator
        }

        if let site = site {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PhotonActionSheetUX.SiteHeaderName) as! PhotonActionSheetSiteHeaderView
            header.tintColor = self.tintColor
            header.configure(with: site)
            return header
        } else if let title = title {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PhotonActionSheetUX.TitleHeaderName) as! PhotonActionSheetTitleHeaderView
            header.tintColor = self.tintColor
            header.configure(with: title)
            header.applyTheme()
            return header
        }

        // A header height of at least 1 is required to make sure the default header size isnt used when laying out with AutoLayout
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EmptyHeader")
        view?.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return view
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = actions[safe: indexPath.section], let action = section[safe: indexPath.row] else {
            return PhotonActionSheetUX.RowHeight
        }
        if let custom = action.customHeight {
            return custom(action)
        }
        if action.customView != nil || action.collectionItems != nil {
            return UITableView.automaticDimension
        } else {
            return PhotonActionSheetUX.RowHeight
        }
    }

    // A footer height of at least 1 is required to make sure the default footer size isnt used when laying out with AutoLayout
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EmptyHeader")
        view?.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return view
    }
}

extension PhotonActionSheet: PhotonActionSheetCollectionCellDelegate {

    func collectionCellDidSelectItem(item: PhotonActionSheetItem) {
        self.dismiss(nil)
        guard let handler = item.handler else {
            return
        }
        handler(item)
    }

}
