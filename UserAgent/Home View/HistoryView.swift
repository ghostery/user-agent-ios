//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared
import Storage

private struct HistoryViewUX {
    static let EmptyScreenItemWidth = 170
    static let IconSize = 23
    static let IconBorderColor = UIColor.Grey30
    static let IconBorderWidth: CGFloat = 0.5
    static let actionIconColor = UIColor.Grey40
}

private class FetchInProgressError: MaybeErrorType {
    internal var description: String {
        return "Fetch is already in-progress"
    }
}

class HistoryView: LibraryView {

    // MARK: - Properties

    private let QueryLimitPerFetch = 100

    private var groupedSites = DateGroupedTableData<Site>()

    private var currentFetchOffset = 0
    private var isFetchInProgress = false

    private lazy var emptyStateOverlayView: UIView = createEmptyStateOverlayView()

    override func setup() {
        super.setup()
        self.tableView.prefetchDataSource = self
        self.tableView.accessibilityIdentifier = "History List"
        self.tableView.addGestureRecognizer(self.longPressRecognizer)
        self.registerNotification()
    }

    override func applyTheme() {
       super.applyTheme()
       self.emptyStateOverlayView.removeFromSuperview()
       self.emptyStateOverlayView = self.createEmptyStateOverlayView()
       self.updateEmptyPanelState()
   }

    override func siteForIndexPath(_ indexPath: IndexPath) -> Site? {
        let sitesInSection = self.groupedSites.itemsForSection(indexPath.section)
        return sitesInSection[safe: indexPath.row]
    }

    override func pinToTopSites(_ site: Site) {
        _ = self.profile.history.addPinnedTopSite(site).value
    }

    override func removeSiteForURLAtIndexPath(_ indexPath: IndexPath) {
        self.removeHistoryForURLAtIndexPath(indexPath: indexPath)
    }

    override func reloadData() {
        guard !self.isFetchInProgress else { return }
        self.groupedSites = DateGroupedTableData<Site>()

        self.currentFetchOffset = 0
        self.fetchData().uponQueue(.main) { result in
            if let sites = result.successValue {
                for site in sites {
                    if let site = site, let latestVisit = site.latestVisit {
                        self.groupedSites.add(site, timestamp: TimeInterval.fromMicrosecondTimestamp(latestVisit.date))
                    }
                }
                self.tableView.reloadData()
                self.updateEmptyPanelState()
            }
        }
    }

}

// MARK: - Private Implementation
private extension HistoryView {

    private func registerNotification() {
        [Notification.Name.PrivateDataClearedHistory, Notification.Name.DynamicFontChanged, Notification.Name.DatabaseWasReopened].forEach {
            NotificationCenter.default.addObserver(self, selector: #selector(onNotificationReceived), name: $0, object: nil)
        }
    }

    @objc private func onNotificationReceived(_ notification: Notification) {
        switch notification.name {
        case .PrivateDataClearedHistory:
            self.reloadData()
        case .DynamicFontChanged:
            self.reloadData()
            if self.emptyStateOverlayView.superview != nil {
                self.emptyStateOverlayView.removeFromSuperview()
            }
            self.emptyStateOverlayView = self.createEmptyStateOverlayView()
        case .DatabaseWasReopened:
            if let dbName = notification.object as? String, dbName == "browser.db" {
                self.reloadData()
            }
        default:
            // no need to do anything at all
            print("Error: Received unexpected notification \(notification.name)")
        }
    }

    private func createEmptyStateOverlayView() -> UIView {
        let overlayView = UIView()
        let emptyLabel = UILabel()
        overlayView.addSubview(emptyLabel)
        emptyLabel.text = Strings.HistoryPanelEmptyStateTitle
        emptyLabel.textAlignment = .center
        emptyLabel.font = DynamicFontHelper.defaultHelper.DeviceFontLight
        emptyLabel.textColor = UIColor.theme.homePanel.welcomeScreenText
        emptyLabel.numberOfLines = 0
        emptyLabel.adjustsFontSizeToFitWidth = true

        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalTo(overlayView)
            // Sets proper top constraint for iPhone 6 in portait and for iPad.
            make.centerY.equalTo(overlayView).offset(LibraryPanelUX.EmptyTabContentOffset).priority(100)
            // Sets proper top constraint for iPhone 4, 5 in portrait.
            make.top.greaterThanOrEqualTo(overlayView).offset(50)
            make.width.equalTo(HistoryViewUX.EmptyScreenItemWidth)
        }
        return overlayView
    }

    private func fetchData() -> Deferred<Maybe<Cursor<Site>>> {
        guard !self.isFetchInProgress else {
            return deferMaybe(FetchInProgressError())
        }
        self.isFetchInProgress = true
        return self.profile.history.getSitesByLastVisit(limit: QueryLimitPerFetch, offset: currentFetchOffset) >>== { result in
            // Force 100ms delay between resolution of the last batch of results
            // and the next time `fetchData()` can be called.
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.currentFetchOffset += self.QueryLimitPerFetch
                self.isFetchInProgress = false
            }
            return deferMaybe(result)
        }
    }

    private func updateEmptyPanelState() {
        if self.groupedSites.isEmpty {
            if self.emptyStateOverlayView.superview == nil {
                self.tableView.tableFooterView = self.emptyStateOverlayView
            }
        } else {
            self.tableView.alwaysBounceVertical = true
            self.tableView.tableFooterView = UIView()
        }
    }

    private func configureSite(_ cell: UITableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        if let site = self.siteForIndexPath(indexPath), let cell = cell as? TwoLineTableViewCell {
            cell.setLines(site.title, detailText: site.url)
            cell.imageView?.layer.borderColor = HistoryViewUX.IconBorderColor.cgColor
            cell.imageView?.layer.borderWidth = HistoryViewUX.IconBorderWidth
            cell.imageView?.setIcon(site.icon, forURL: site.tileURL, completed: { (color, url) in
                if site.tileURL == url {
                    cell.imageView?.image = cell.imageView?.image?.createScaled(CGSize(width: HistoryViewUX.IconSize, height: HistoryViewUX.IconSize))
                    cell.imageView?.backgroundColor = color
                    cell.imageView?.contentMode = .center
                }
            })
        }
        return cell
    }

    private func removeHistoryForURLAtIndexPath(indexPath: IndexPath) {
        guard let site = self.siteForIndexPath(indexPath) else {
            return
        }
        self.profile.history.removeHistoryForURL(site.url).uponQueue(.main) { result in
            guard site == self.siteForIndexPath(indexPath) else {
                self.reloadData()
                return
            }
            self.tableView.beginUpdates()
            self.groupedSites.remove(site)
            self.tableView.deleteRows(at: [indexPath], with: .right)
            self.tableView.endUpdates()
            self.updateEmptyPanelState()
        }
    }

}

// MARK: - Table view dataSource
extension HistoryView {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return LibrarySection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupedSites.numberOfItemsForSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = .none
        return self.configureSite(cell, for: indexPath)

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard self.groupedSites.numberOfItemsForSection(section) > 0 else {
            return nil
        }
        return LibrarySection(rawValue: section)?.title
    }

}

// MARK: - Table view delegate
extension HistoryView {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if let site = self.siteForIndexPath(indexPath), let url = URL(string: site.url) {
            self.delegate?.library(didSelectURL: url, visitType: .typed)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard self.groupedSites.numberOfItemsForSection(section) > 0 else {
            return nil
        }
        return super.tableView(tableView, viewForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.groupedSites.numberOfItemsForSection(section) > 0 else {
            return 0
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title = NSLocalizedString("Delete", tableName: "HistoryPanel", comment: "Action button for deleting history entries in the history panel.")
        let delete = UITableViewRowAction(style: .default, title: title, handler: { (action, indexPath) in
            self.removeHistoryForURLAtIndexPath(indexPath: indexPath)
        })
        return [delete]
    }

}

extension HistoryView: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard !self.isFetchInProgress, indexPaths.contains(where: self.shouldLoadRow) else {
            return
        }
        self.fetchData().uponQueue(.main) { result in
            if let sites = result.successValue {
                let indexPaths: [IndexPath] = sites.compactMap({ site in
                    guard let site = site, let latestVisit = site.latestVisit else {
                        return nil
                    }
                    let indexPath = self.groupedSites.add(site, timestamp: TimeInterval.fromMicrosecondTimestamp(latestVisit.date))
                    return indexPath
                })
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }

    func shouldLoadRow(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= self.groupedSites.numberOfItemsForSection(indexPath.section) - 1
    }

}
