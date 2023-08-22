/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Storage

struct SiteTableViewControllerUX {
    static let HeaderHeight = CGFloat(32)
    static let RowHeight = CGFloat(44)
    static let HeaderFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
    static let HeaderTextMargin = CGFloat(16)
}

class SiteTableViewHeader: UITableViewHeaderFooterView, Themeable {
    // I can't get drawRect to play nicely with the glass background. As a fallback
    // we just use views for the top and bottom borders.
    let topBorder = UIView()
    let bottomBorder = UIView()
    let titleLabel = UILabel()

    override var textLabel: UILabel? {
        return titleLabel
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        titleLabel.font = DynamicFontHelper.defaultHelper.DeviceFontMediumBold

        addSubview(topBorder)
        addSubview(bottomBorder)
        contentView.addSubview(titleLabel)

        topBorder.snp.makeConstraints { make in
            make.left.right.equalTo(self)
            make.top.equalTo(self).offset(-0.5)
            make.height.equalTo(0.5)
        }

        bottomBorder.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(0.5)
        }

        // A table view will initialize the header with CGSizeZero before applying the actual size. Hence, the label's constraints
        // must not impose a minimum width on the content view.
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(SiteTableViewControllerUX.HeaderTextMargin).priority(1000)
            make.right.equalTo(contentView).offset(-SiteTableViewControllerUX.HeaderTextMargin).priority(1000)
            make.left.greaterThanOrEqualTo(contentView) // Fallback for when the left space constraint breaks
            make.right.lessThanOrEqualTo(contentView) // Fallback for when the right space constraint breaks
            make.centerY.equalTo(contentView)
        }

        applyTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        applyTheme()
    }

    func applyTheme() {
        titleLabel.textColor = Theme.tableView.headerTextDark
        topBorder.backgroundColor = Theme.homePanel.siteTableHeaderBorder
        bottomBorder.backgroundColor = Theme.homePanel.siteTableHeaderBorder
        contentView.backgroundColor = Theme.tableView.headerBackground
    }
}

/**
 * Provides base shared functionality for site rows and headers.
 */
@objcMembers
class SiteTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Themeable {
    fileprivate let CellIdentifier = "CellIdentifier"
    fileprivate let HeaderIdentifier = "HeaderIdentifier"
    let profile: Profile

    var data: Cursor<Site> = Cursor<Site>(status: .success, msg: "No data set")
    var tableView = UITableView()

    private override init(nibName: String?, bundle: Bundle?) {
        fatalError("init(coder:) has not been implemented")
    }

    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        applyTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
            return
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SiteTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.register(SiteTableViewHeader.self, forHeaderFooterViewReuseIdentifier: HeaderIdentifier)
        tableView.layoutMargins = .zero
        tableView.keyboardDismissMode = .onDrag

        tableView.accessibilityIdentifier = "SiteTable"
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.estimatedRowHeight = SiteTableViewControllerUX.RowHeight

        // Set an empty footer to prevent empty cells from appearing in the list.
        tableView.tableFooterView = UIView()

        if let _ = self as? HomePanelContextMenu {
            tableView.dragDelegate = self
        }
    }

    deinit {
        // The view might outlive this view controller thanks to animations;
        // explicitly nil out its references to us to avoid crashes. Bug 1218826.
        tableView.dataSource = nil
        tableView.delegate = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.setEditing(false, animated: false)
        coordinator.animate(alongsideTransition: { context in
            // The AS context menu does not behave correctly. Dismiss it when rotating.
            if let _ = self.presentedViewController as? PhotonActionSheet {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
        }, completion: nil)
    }

    func reloadData() {
        if data.status != .success {
            print("Err: \(data.statusMessage)", terminator: "\n")
        } else {
            self.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        if self.tableView(tableView, hasFullWidthSeparatorForRowAtIndexPath: indexPath) {
            cell.separatorInset = .zero
        }
        cell.textLabel?.textColor = Theme.tableView.rowText
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderIdentifier)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = Theme.tableView.headerTextDark
            header.contentView.backgroundColor = Theme.tableView.headerBackground
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SiteTableViewControllerUX.HeaderHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, hasFullWidthSeparatorForRowAtIndexPath indexPath: IndexPath) -> Bool {
        return false
    }

    func applyTheme() {
        navigationController?.navigationBar.barTintColor = Theme.tableView.headerBackground
        navigationController?.navigationBar.tintColor = Theme.general.controlTint
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.tableView.headerTextDark]
        setNeedsStatusBarAppearanceUpdate()

        tableView.backgroundColor = Theme.tableView.rowBackground
        tableView.separatorColor = Theme.tableView.separator
        if let rows = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: rows, with: .none)
            tableView.reloadSections(IndexSet(rows.map { $0.section }), with: .none)
        }
    }
}

@available(iOS 11.0, *)
extension SiteTableViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let homePanelVC = self as? HomePanelContextMenu, let site = homePanelVC.getSiteDetails(for: indexPath), let url = URL(string: site.url), let itemProvider = NSItemProvider(contentsOf: url) else {
            return []
        }

        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = site
        return [dragItem]
    }

    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        presentedViewController?.dismiss(animated: true)
    }
}
