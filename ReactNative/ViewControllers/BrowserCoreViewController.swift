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
        super.init(nibName: nil, bundle: nil)
        let view = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: componentName,
            initialProperties: args
        )
        self.view.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
