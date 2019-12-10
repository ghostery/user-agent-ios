//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

class PrivacyStatementViewController: UIViewController {

    private let dataModel: PrivacyStatementData
    private var headerView: UILabel!
    private var authorView: PrivacyStatementProfileView!
    private var settingsConversationView: UIView!
    private var settingsView: UIView!
    private var privacyPolicyView: PrivacyStatementPolicyView!
    private var privacyConversationView: UIView!
    private var footerView: UIView!
    private var footerConversationView: UIView!
    private var stackView: UIStackView!
    private var scrollView: UIScrollView!

    init(dataModel: PrivacyStatementData) {
        self.dataModel = dataModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white // TODO: apply theme
        self.setupViews()
        self.setupNavigationItems()
        self.setupConstraints()
        // Do any additional setup after loading the view.
    }

    private func setupNavigationItems() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        self.navigationItem.rightBarButtonItem = doneButton
    }

    private func setupViews() {
        self.setupHeaderView()
        self.setupProfile()
        self.setupSettingsConversationView()
        self.setupSettingsView()
        self.setupPrivacyConversationView()
        self.setupPrivacyPolicyView()
        self.setupFooterConversationView()
        self.setupFooterView()
        self.setupStackView()
    }

    private func setupStackView() {
        self.scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        self.scrollView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }

        self.stackView = UIStackView(arrangedSubviews: [self.headerView, self.authorView, self.settingsConversationView, self.settingsView, self.privacyConversationView, self.privacyPolicyView, self.footerConversationView, self.footerView])
        self.stackView.axis = .vertical
        self.stackView.alignment = .fill
        self.stackView.distribution = .fill
        self.stackView.spacing = 5

        self.scrollView.addSubview(self.stackView)

        self.stackView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
        }

    }

    private func setupConstraints() {
        self.headerView.snp.makeConstraints { (make) in
            make.topMargin.equalTo(self.view).offset(20)
            make.left.right.equalTo(self.view).offset(20)
            make.height.equalTo(40)
        }
        self.authorView.snp.makeConstraints { (make) in
            make.top.equalTo(self.headerView.snp.bottom).offset(5)
            make.height.equalTo(100)
            make.left.right.equalTo(40)
        }
        self.settingsConversationView.snp.makeConstraints { (make) in
            make.top.equalTo(self.authorView.snp.bottom).offset(5)
            make.left.right.equalTo(self.view)
            make.height.equalTo(160)
        }
        self.settingsView.snp.makeConstraints { (make) in
            make.top.equalTo(self.settingsConversationView.snp.bottom).offset(5)
            make.left.right.equalTo(self.view)
            make.height.equalTo(self.dataModel.sortedSettings.count * 44)
        }
        self.privacyConversationView.snp.makeConstraints { (make) in
            make.top.equalTo(self.settingsView.snp.bottom).offset(5)
            make.left.right.equalTo(self.view)
            make.height.equalTo(80)
        }

        self.privacyPolicyView.snp.makeConstraints { (make) in
            make.top.equalTo(self.privacyConversationView.snp.bottom).offset(5)
            make.left.right.equalTo(self.view)
            make.height.equalTo(44)
        }

        self.footerConversationView.snp.makeConstraints { (make) in
            make.top.equalTo(self.privacyPolicyView.snp.bottom).offset(5)
            make.left.right.equalTo(self.view)
            make.height.equalTo(80)
        }

        self.footerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.footerConversationView.snp.bottom).offset(5)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }

    private func setupHeaderView() {
        self.headerView = UILabel()
        self.headerView.backgroundColor = .red
        self.headerView.font = UIFont.boldSystemFont(ofSize: 24)
        self.headerView.text = self.dataModel.title
    }

    private func setupProfile() {
        self.authorView = PrivacyStatementProfileView(profile: self.dataModel.author)
        self.authorView.backgroundColor = .yellow
    }

    private func setupSettingsView() {
        self.settingsView = UIView()
        self.settingsView.backgroundColor = .blue
    }

    private func setupSettingsConversationView() {
        self.settingsConversationView = UIView()
        self.settingsConversationView.backgroundColor = .orange
        self.createConversationDialog(inView: self.settingsConversationView, conversation: self.dataModel.settingsConversations)
    }

    private func setupPrivacyConversationView() {
        self.privacyConversationView = UIView()
        self.privacyConversationView.backgroundColor = .green
        self.createConversationDialog(inView: self.privacyConversationView, conversation: self.dataModel.privacyConversations)
    }

    private func setupPrivacyPolicyView() {
        self.privacyPolicyView = PrivacyStatementPolicyView()
        self.privacyPolicyView.backgroundColor = .gray
    }

    private func setupFooterView() {
        self.footerView = UIView()
        self.footerView.backgroundColor = .purple
    }

    private func setupFooterConversationView() {
        self.footerConversationView = UIView()
        self.footerConversationView.backgroundColor = .lightGray
        self.createConversationDialog(inView: self.footerConversationView, conversation: self.dataModel.footerConversations)
    }

    private func createConversationDialog(inView view: UIView, conversation: [String]) {
        var topMargin = view.snp.top
        for text in conversation {
            let bubbleView = ChatBubbleView(text: text)
            let calculatedSize = bubbleView.calculatedSize(width: 0.66 * self.view.frame.width)
            view.addSubview(bubbleView)
            bubbleView.snp.makeConstraints { (make) in
                make.top.equalTo(topMargin).offset(10)
                make.left.equalTo(view).offset(20)
                make.width.equalTo(calculatedSize.width)
                make.height.equalTo(60)
            }
            topMargin = bubbleView.snp.bottom
        }
    }
}
