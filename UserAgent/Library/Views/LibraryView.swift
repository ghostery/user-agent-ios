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

struct LibraryPanelUX {
    static let EmptyTabContentOffset = -180
    static let EmptyScreenItemWidth = 170
}

enum LibrarySection: Int, CaseIterable {
    case today
    case yesterday
    case lastWeek
    case lastMonth

    var title: String {
        switch self {
        case .today:
            return Strings.TableDateSection.TitleToday
        case .yesterday:
            return Strings.TableDateSection.TitleYesterday
        case .lastWeek:
            return Strings.TableDateSection.TitleLastWeek
        case .lastMonth:
            return Strings.TableDateSection.TitleLastMonth
        }
    }
}

protocol LibraryViewDelegate: AnyObject {
    func libraryDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool)
    func library(didSelectURL url: URL, visitType: VisitType)
    func library(wantsToPresent viewController: UIViewController)
    func library(wantsToEdit bookmark: BookmarkNode)
}

extension LibraryViewDelegate {
    func library(wantsToEdit bookmark: BookmarkNode) {}
}

class LibraryView: UIView, Themeable {
    // MARK: - Properties
    weak var delegate: LibraryViewDelegate?
    private (set) var profile: Profile

    private let cellIdentifier = "cellIdentifier"
    private let headerIdentifier = "headerIdentifier"

    private var emptyStateLabel: UILabel?

    private (set) var tableView = UITableView()
    private (set) lazy var emptyStateOverlayView: UIView = self.createEmptyStateOverlayView()

    lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGestureRecognized))
    }()

    // MARK: - Initialization
    init(profile: Profile) {
        self.profile = profile
        super.init(frame: .zero)
        self.setup()
    }

    override init(frame: CGRect) {
        fatalError("Use init(profile:) to initialize")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(profile:) to initialize")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.reloadData()
    }

    func setup() {
        self.configureTableView()
        self.applyTheme()
        self.registerNotification()
    }

    func applyTheme() {
        self.tableView.backgroundColor = Theme.browser.homeBackground
        self.tableView.separatorColor = Theme.tableView.separator
        self.emptyStateLabel?.textColor = Theme.homePanel.welcomeScreenText
        self.tableView.reloadData()
    }

    func siteForIndexPath(_ indexPath: IndexPath) -> Site? {
        return nil
    }

    func emptyMessage() -> String? {
        return nil
    }

    var deleteActionTitle: String {
        fatalError("Subclass must overide this method")
    }

    func removeSiteForURLAtIndexPath(_ indexPath: IndexPath) {
        fatalError("Subclass must overide this method")
    }

    func pinToTopSites(_ site: Site) {
        fatalError("Subclass must overide this method")
    }

    func reloadData() {
        fatalError("Subclass must overide this method")
    }

    func additionalContextMenuActions(indexPath: IndexPath) -> [PhotonActionSheetItem] {
        return []
    }

}

// MARK: - Private methods
extension LibraryView {

    private func configureTableView() {
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(self)
            return
        }

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(SiteTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.register(SiteTableViewHeader.self, forHeaderFooterViewReuseIdentifier: self.headerIdentifier)
        self.tableView.layoutMargins = .zero
        self.tableView.keyboardDismissMode = .onDrag

        self.tableView.cellLayoutMarginsFollowReadableWidth = false

        // Set an empty footer to prevent empty cells from appearing in the list.
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    private func createEmptyStateOverlayView() -> UIView {
        let overlayView = UIView()
        let emptyLabel = UILabel()
        overlayView.addSubview(emptyLabel)
        emptyLabel.text = self.emptyMessage()
        emptyLabel.textAlignment = .center
        emptyLabel.font = DynamicFontHelper.defaultHelper.DeviceFontLight
        emptyLabel.textColor = Theme.homePanel.welcomeScreenText
        emptyLabel.numberOfLines = 0
        emptyLabel.adjustsFontSizeToFitWidth = true

        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalTo(overlayView)
            // Sets proper top constraint for iPhone 6 in portait and for iPad.
            make.centerY.equalTo(overlayView).offset(LibraryPanelUX.EmptyTabContentOffset).priority(100)
            // Sets proper top constraint for iPhone 4, 5 in portrait.
            make.top.greaterThanOrEqualTo(overlayView).offset(50)
            make.width.equalTo(LibraryPanelUX.EmptyScreenItemWidth)
        }
        self.emptyStateLabel = emptyLabel
        return overlayView
    }

    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(dynamicFontChangedNotificationReceived), name: Notification.Name.DynamicFontChanged, object: nil)
    }

}

// MARK: - Actions
extension LibraryView {

    @objc private func onLongPressGestureRecognized(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard longPressGestureRecognizer.state == .began else { return }
        let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: touchPoint) else { return }
        self.presentContextMenu(for: indexPath)
    }

    @objc private func dynamicFontChangedNotificationReceived(_ notification: Notification) {
        DispatchQueue.main.async {
            switch notification.name {
            case .DynamicFontChanged:
                self.reloadData()
                self.emptyStateLabel?.font = DynamicFontHelper.defaultHelper.DeviceFontLight
            default:
                print("Error: Received unexpected notification \(notification.name)")
            }
        }
    }

}

extension LibraryView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        cell.textLabel?.textColor = Theme.tableView.rowText
        return cell
    }

}

extension LibraryView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerIdentifier)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SiteTableViewControllerUX.HeaderHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SiteTableViewControllerUX.RowHeight
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = Theme.tableView.headerTextDark
            if #available(iOS 13.0, *) {
                header.contentView.backgroundColor = UIColor.systemGray5
            } else {
                header.contentView.backgroundColor = UIColor.Grey20
            }
        }
    }

}

extension LibraryView: LibraryContextMenu {

    func presentContextMenu(for site: Site, with indexPath: IndexPath, completionHandler: @escaping () -> PhotonActionSheet?) {
        guard let contextMenu = completionHandler() else { return }
        self.delegate?.library(wantsToPresent: contextMenu)
    }

    func getSiteDetails(for indexPath: IndexPath) -> Site? {
        return self.siteForIndexPath(indexPath)
    }

    func getContextMenuActions(for site: Site, with indexPath: IndexPath) -> [PhotonActionSheetItem]? {
        guard var actions = self.getDefaultContextMenuActions(for: site, libraryViewDelegate: self.delegate) else { return nil }

        let removeAction = PhotonActionSheetItem(title: self.deleteActionTitle, iconString: "action_delete", handler: { action in
            self.removeSiteForURLAtIndexPath(indexPath)
        })

        let pinTopSite = PhotonActionSheetItem(title: Strings.ActivityStream.ContextMenu.PinTopsite, iconString: "action_pin", handler: { action in
            self.pinToTopSites(site)
        })
        actions.append(pinTopSite)
        actions.append(removeAction)
        actions.append(contentsOf: self.additionalContextMenuActions(indexPath: indexPath))
        return actions
    }

}
