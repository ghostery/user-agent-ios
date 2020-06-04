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
    static let messageCellHeight: CGFloat = 40.0
    static let separatorLeftOffset: CGFloat = 40.0
}

protocol PrivacyStatementViewControllerDelegate: class {
    func privacyStatementViewControllerDidClose()
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

    weak var delegate: DataAndPrivacyViewControllerDelegate?

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
            self.delegate?.dataAndPrivacyViewControllerDidClose()
        }
        doneButton.accessibilityLabel = "PrivacyStatementDone"
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
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.General.DoneString, style: .done, closure: { (_) in
            navigationController.dismiss(animated: true)
        })
        if #available(iOS 13.0, *) {
            navigationController.modalPresentationStyle = UIDevice.current.isPhone ? .automatic : .formSheet
        } else {
            navigationController.modalPresentationStyle = UIDevice.current.isPhone ? .fullScreen : .formSheet
        }
        self.present(navigationController, animated: true)
    }

    private func presentMailComposer() {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["support@cliqz.com"])
        if #available(iOS 13.0, *) {
            composer.modalPresentationStyle = UIDevice.current.isPhone ? .automatic : .formSheet
        } else {
            composer.modalPresentationStyle = UIDevice.current.isPhone ? .fullScreen : .formSheet
        }
        self.present(composer, animated: true)
    }

    private func settingsConversationCellOffsets(indexPath: IndexPath) -> (CGFloat, CGFloat) {
        if indexPath.row == 0 {
            return (2 * ChatBubbleViewCellUI.offset / 3, ChatBubbleViewCellUI.offset / 3)
        } else if indexPath.row == self.dataModel.settingsConversations.count - 1 {
            return (ChatBubbleViewCellUI.offset / 3, 2 * ChatBubbleViewCellUI.offset / 3)
        } else {
            return (ChatBubbleViewCellUI.offset / 3, ChatBubbleViewCellUI.offset / 3)
        }
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
        case .messageConversation:
            return self.dataModel.messageConversations.count
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
            let cell = ChatBubbleViewCell(message: message)
            cell.labelOffsets = self.settingsConversationCellOffsets(indexPath: indexPath)
            return cell
        case .settings:
            let cell = PrivacyStatementSettingCell(style: .subtitle, reuseIdentifier: nil)
            if indexPath.row == 0 {
                cell.delegate = self
                self.humanWebSetting.onConfigureCell(cell)
                cell.hasBottomSeparator = true
                cell.hasTopSeparator = true
                cell.bottomSeparatorOffsets = (section.numberOfRows == 1 ? 0.0 : PrivacyStatementViewControllerUI.separatorLeftOffset, 0.0)
                cell.infoButtonImage = UIImage(named: "humanWebInfoIcon")
                cell.infoButton?.setImage(UIImage(named: "humanWebInfoIconHighlighted"), for: .highlighted)
            } else {
                self.telemetrySettings.onConfigureCell(cell)
                cell.titleLabel.text = Strings.PrivacyStatement.StatisticTitle
                cell.hasBottomSeparator = true
            }
            return cell
        case .repositoryConversation:
            let message = self.dataModel.repositoryConversations[indexPath.row]
            return ChatBubbleViewCell(message: message)
        case .repository:
            let cell = PrivacyStatementDisclosureCell(style: .default, reuseIdentifier: nil)
            cell.hasTopSeparator = true
            cell.hasBottomSeparator = true
            cell.title = Strings.PrivacyStatement.RepositoryTitle
            return cell
        case .privacyConversation:
            let message = self.dataModel.privacyConversations[indexPath.row]
            return ChatBubbleViewCell(message: message)
        case .privacy:
            let cell = PrivacyStatementDisclosureCell(style: .default, reuseIdentifier: nil)
            cell.hasTopSeparator = true
            cell.hasBottomSeparator = true
            cell.title = Strings.PrivacyStatement.PrivacyTitle
            return cell
        case .messageConversation:
            let message = self.dataModel.messageConversations[indexPath.row]
            return ChatBubbleViewCell(message: message)
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
        case .settingsConversation, .repositoryConversation, .privacyConversation, .messageConversation:
            return UITableView.automaticDimension
        case .settings, .repository, .privacy:
            return PrivacyStatementViewControllerUI.actionCellHeight
        case .message:
            return PrivacyStatementViewControllerUI.messageCellHeight
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
        self.presentWebViewWithPath(path: Strings.HumanWebInfoWebsite, title: Strings.Settings.Support.HumanWebTitle)
    }

}

extension PrivacyStatementViewController: PrivacyStatementMessageCellDelegate {

    func onClickMessageButton() {
        if MFMailComposeViewController.canSendMail() {
            self.presentMailComposer()
        } else {
            self.presentWebViewWithPath(path: Strings.FeedbackWebsite, title: Strings.Settings.Support.FAQAndSupport)
        }
    }

}

extension PrivacyStatementViewController: PrivacyStatementFooterViewDelegate {

    func onClickOkButton() {
        self.dismiss(animated: true)
        self.delegate?.dataAndPrivacyViewControllerDidClose()
    }

}

extension PrivacyStatementViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
