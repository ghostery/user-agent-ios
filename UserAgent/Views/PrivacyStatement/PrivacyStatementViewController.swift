//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared
import MessageUI

struct PrivacyStatementViewControllerUI {
    static let footerHeight: CGFloat = 100.0
    static let actionCellHeight: CGFloat = 70.0
    static let separatorLeftOffset: CGFloat = 40.0
}

class PrivacyStatementNavigationController: UINavigationController {

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    init(dataModel: PrivacyStatementData, prefs: Prefs) {
        let privacyStatementViewController = PrivacyStatementViewController(dataModel: dataModel, prefs: prefs)
        super.init(rootViewController: privacyStatementViewController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        let footerView = PrivacyStatementFooterView(frame: CGRect(origin: .zero, size: CGSize(width: self.tableView.frame.width, height: PrivacyStatementViewControllerUI.footerHeight)))
        footerView.delegate = self
        self.tableView.tableFooterView = footerView
    }

    private func presentWebViewWithPath(path: String, title: String) {
        guard let url = URL(string: path) else {
            return
        }
        let viewController = SettingsContentViewController()
        viewController.url = url
        viewController.title = title
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.DownloadsPanel.DoneTitle, style: .done, closure: { (_) in
            navigationController.dismiss(animated: true)
        })
        if UIDevice.current.isPad {
            navigationController.preferredContentSize = CGSize(width: IntroUX.Width, height: IntroUX.Height)
            navigationController.modalPresentationStyle = .formSheet
        }
        self.present(navigationController, animated: true)
    }

    private func presentMailComposer() {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["support@cliqz.com"])
        self.present(composer, animated: true)
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
        switch privacyStatementSection {
        case .settingsConversation:
            return self.dataModel.settingsConversations.count
        case .repositoryConversation:
            return self.dataModel.repositoryConversations.count
        case .privacyConversation:
            return self.dataModel.privacyConversations.count
        default:
            return privacyStatementSection.numberOfRows
        }
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
            let cell = PrivacyStatementSettingCell(style: .subtitle, reuseIdentifier: nil)
            if indexPath.row == 0 {
                cell.delegate = self
                self.humanWebSetting.onConfigureCell(cell)
                cell.hasBottomSeparator = true
                cell.hasTopSeparator = true
                cell.bottomSeparatorOffsets = (PrivacyStatementViewControllerUI.separatorLeftOffset, 0.0)
                cell.infoButtonImage = UIImage(named: "humanWebInfoIcon")
                cell.infoButton?.setImage(UIImage(named: "humanWebInfoIconHighlighted"), for: .highlighted)
            } else {
                self.telemetrySettings.onConfigureCell(cell)
                cell.hasBottomSeparator = true
            }
            return cell
        case .repositoryConversation:
            let message = self.dataModel.repositoryConversations[indexPath.row]
            return ChatBubbleViewCell(message: message)
        case .repository:
            let cell = PrivacyStatementDisclosureCell(style: .subtitle, reuseIdentifier: nil)
            cell.hasTopSeparator = true
            cell.hasBottomSeparator = true
            cell.title = Strings.PrivacyStatement.RepositoryTitle
            cell.detailTitle = Strings.PrivacyStatement.RepositorySubtitle
            return cell
        case .privacyConversation:
            let message = self.dataModel.privacyConversations[indexPath.row]
            return ChatBubbleViewCell(message: message)
        case .privacy:
            let cell = PrivacyStatementDisclosureCell(style: .subtitle, reuseIdentifier: nil)
            cell.hasTopSeparator = true
            cell.hasBottomSeparator = true
            cell.title = Strings.PrivacyStatement.PrivacyTitle
            cell.detailTitle = Strings.PrivacyStatement.PrivacySubtitle
            return cell
        case .message:
            let cell = PrivacyStatementMessageCell()
            cell.delegate = self
            cell.title = Strings.PrivacyStatement.MessageCellTitle
            cell.icon = UIImage(named: "privacyStatementMessage")
            return cell
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
            return PrivacyStatementViewControllerUI.actionCellHeight
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = PrivacyStatementSection(rawValue: indexPath.section) else {
            return
        }
        switch section {
        case .repository:
            self.presentWebViewWithPath(path: Strings.RepositoryWebsite, title: Strings.PrivacyStatement.RepositoryTitle)
        case .privacy:
            self.presentWebViewWithPath(path: Strings.PrivacyPolicyWebsite, title: Strings.PrivacyStatement.PrivacyTitle)
        default: break
        }
    }

}

extension PrivacyStatementViewController: PrivacyStatementSettingCellDelegate {

    func onClickInfoButton() {
        self.presentWebViewWithPath(path: Strings.HumanWebInfoWebsite, title: Strings.Settings.HumanWebTitle)
    }

}

extension PrivacyStatementViewController: PrivacyStatementMessageCellDelegate {

    func onClickMessageButton() {
        if MFMailComposeViewController.canSendMail() {
            self.presentMailComposer()
        } else {
            self.presentWebViewWithPath(path: Strings.FeedbackWebsite, title: Strings.Settings.FAQAndSupport)
        }
    }

}

extension PrivacyStatementViewController: PrivacyStatementFooterViewDelegate {

    func onClickOkButton() {
        self.dismiss(animated: true)
    }

}

extension PrivacyStatementViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        controller.dismiss(animated: true)
    }

}
