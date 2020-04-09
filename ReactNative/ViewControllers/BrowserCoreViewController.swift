//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import React

class BrowserCoreViewController: UIViewController {
    init(_ componentName: String, withArgs args: [String: Any]) {
        let initialProperties = args

        super.init(nibName: nil, bundle: nil)
        let view = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: componentName,
            initialProperties: initialProperties
        )
        self.view.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "goBack"),
            style: .plain,
            target: self,
            action: #selector(backToMain))
        leftBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        leftBarButtonItem.tintColor = Theme.toolbarButton.selectedTint
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @objc func backToMain() {
        self.navigationController?.popViewController(animated: true)
    }
}
