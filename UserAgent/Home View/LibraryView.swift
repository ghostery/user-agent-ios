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

enum LibrarySection: Int, CaseIterable {
    case today
    case yesterday
    case lastWeek
    case lastMonth

    var title: String {
        switch self {
        case .today:
            return Strings.TableDateSectionTitleToday
        case .yesterday:
            return Strings.TableDateSectionTitleYesterday
        case .lastWeek:
            return Strings.TableDateSectionTitleLastWeek
        case .lastMonth:
            return Strings.TableDateSectionTitleLastMonth
        }
    }

}

protocol LibraryViewDelegate: AnyObject {
    func libraryDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool)
    func library(didSelectURL url: URL, visitType: VisitType)
    func library(wantsToPresent viewController: UIViewController)
}

class LibraryView: UIView, Themeable {
    // MARK: - Properties
    weak var delegate: LibraryViewDelegate?
    private (set) var profile: Profile

    private let cellIdentifier = "cellIdentifier"
    private let headerIdentifier = "headerIdentifier"

    private (set) var tableView = UITableView()

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

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.reloadData()
    }

    func setup() {
        self.configureTableView()
        self.applyTheme()
    }

    func applyTheme() {
        self.tableView.backgroundColor = UIColor.theme.tableView.rowBackground
        self.tableView.separatorColor = UIColor.theme.tableView.separator
    }

    func siteForIndexPath(_ indexPath: IndexPath) -> Site? {
        return nil
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
        self.tableView.tableFooterView = UIView()
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
        cell.textLabel?.textColor = UIColor.theme.tableView.rowText
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
            header.textLabel?.textColor = UIColor.theme.tableView.headerTextDark
            header.contentView.backgroundColor = UIColor.theme.tableView.headerBackground
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

        let removeAction = PhotonActionSheetItem(title: Strings.DeleteFromHistoryContextMenuTitle, iconString: "action_delete", handler: { action in
            self.removeSiteForURLAtIndexPath(indexPath)
        })

        let pinTopSite = PhotonActionSheetItem(title: Strings.PinTopsiteActionTitle, iconString: "action_pin", handler: { action in
            self.pinToTopSites(site)
        })
        actions.append(pinTopSite)
        actions.append(removeAction)
        return actions
    }

}
