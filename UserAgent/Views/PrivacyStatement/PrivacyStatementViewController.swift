//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared

struct PrivacyStatementViewControllerUI {
    static let footerHeight: CGFloat = 100.0
    static let okButtonHeight: CGFloat = 40.0
}

class PrivacyStatementViewController: UITableViewController {

    private let dataModel: PrivacyStatementData
    private let prefs: Prefs

    private lazy var humanWebSetting: HumanWebSetting = {
        return HumanWebSetting(prefs: self.prefs, attributedStatusText: NSAttributedString(string: Strings.PrivacyStatement.HumanWebStatus, attributes: [NSAttributedString.Key.foregroundColor: UIColor.Grey80]))
    }()

    private lazy var telemetrySettings: TelemetrySetting = {
        return TelemetrySetting(prefs: self.prefs, attributedStatusText: NSAttributedString(string: Strings.PrivacyStatement.StatisticStatus, attributes: [NSAttributedString.Key.foregroundColor: UIColor.Grey80]))
    }()

    init(dataModel: PrivacyStatementData, prefs: Prefs) {
        self.dataModel = dataModel
        self.prefs = prefs
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.backgroundColor = UIColor.Grey20
        self.tableView.separatorStyle = .none
        self.setupViews()
        self.setupNavigationItems()
    }

    // MARK: - Actions

    @objc func okButtonAction() {
        self.dismiss(animated: true)
    }

    // MARK: - Private methods

    private func setupNavigationItems() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done) { (_) in
            self.dismiss(animated: true)
        }
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationController?.navigationBar.barTintColor = UIColor.Grey20
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    private func setupViews() {
        self.setupHeaderView()
        self.setupFooterView()
    }

    private func setupHeaderView() {
        let profile = PrivacyStatementProfile()
        let headerView = PrivacyStatementHeaderView(profile: profile)
        headerView.frame = CGRect(origin: .zero, size: CGSize(width: self.tableView.frame.width, height: PrivacyStatementHeaderViewUI.height))
        self.tableView.tableHeaderView = headerView
    }

    private func setupFooterView() {
        let footerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.tableView.frame.width, height: PrivacyStatementViewControllerUI.footerHeight)))
        footerView.backgroundColor = .white
        let okButton = UIButton(type: .system)
        okButton.addTarget(self, action: #selector(okButtonAction), for: .touchUpInside)
        okButton.clipsToBounds = true
        okButton.layer.cornerRadius = PrivacyStatementViewControllerUI.okButtonHeight / 2
        okButton.setTitle(Strings.General.OKString, for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.backgroundColor = Theme.tableView.rowActionAccessory
        footerView.addSubview(okButton)
        okButton.snp.makeConstraints { (make) in
            make.center.equalTo(footerView)
            make.height.equalTo(PrivacyStatementViewControllerUI.okButtonHeight)
            make.width.equalTo(footerView.snp.width).multipliedBy(0.5)
        }
        self.tableView.tableFooterView = footerView
    }

}

// UITableViewDataSource
extension PrivacyStatementViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return PrivacyStatementSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let privacyStatementSection = PrivacyStatementSection(rawValue: section) else {
            return 0
        }
        return privacyStatementSection.numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = PrivacyStatementSection(rawValue: indexPath.section) else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        switch section {
        case .settingsConversation:
            let message = self.dataModel.settingsConversations[indexPath.row]
            return ChatBubbleViewCell(message: message)
        case .settings:
            let cell = ThemedTableViewCell(style: .subtitle, reuseIdentifier: nil)
            if indexPath.row == 0 {
                self.humanWebSetting.onConfigureCell(cell)
            } else {
                self.telemetrySettings.onConfigureCell(cell)
            }
            return cell
        case .repositoryConversation:
            let message = self.dataModel.repositoryConversations[indexPath.row]
            return ChatBubbleViewCell(message: message)
        case .repository:
            return UITableViewCell()
        case .privacyConversation:
            let message = self.dataModel.privacyConversations[indexPath.row]
            return ChatBubbleViewCell(message: message)
        case .privacy:
            return UITableViewCell()
        case .message:
            return UITableViewCell()
        }
    }

}

// UITableViewDelegate
extension PrivacyStatementViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = PrivacyStatementSection(rawValue: indexPath.section) else {
            return 0.0
        }
        switch section {
        case .settingsConversation, .repositoryConversation, .privacyConversation:
            return UITableView.automaticDimension
        case .settings, .repository, .privacy, .message:
            return 70.0
        }
    }

}
