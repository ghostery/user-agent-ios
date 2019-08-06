/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SnapKit
import UIKit
import WebKit
import SwiftyJSON

protocol FxAContentViewControllerDelegate: AnyObject {
    func contentViewControllerDidSignIn(_ viewController: FxAContentViewController, withFlags: FxALoginFlags)
    func contentViewControllerDidCancel(_ viewController: FxAContentViewController)
}

// TODO: Check if this Class can be removed entirely, seeing as we don't
/**
 * A controller that manages a single web view connected to the Firefox
 * Accounts (Desktop) Sync postMessage interface.
 *
 * The postMessage interface is not really documented, but it is simple
 * enough.  I reverse engineered it from the Desktop Firefox code and the
 * fxa-content-server git repository.
 */
class FxAContentViewController: SettingsContentViewController, WKScriptMessageHandler {
    fileprivate enum RemoteCommand: String {
        case canLinkAccount = "can_link_account"
        case loaded = "loaded"
        case login = "login"
        case changePassword = "change_password"
        case sessionStatus = "session_status"
        case signOut = "sign_out"
        case deleteAccount = "delete_account"
    }

    weak var delegate: FxAContentViewControllerDelegate?

    let profile: Profile

    init(profile: Profile, fxaOptions: FxALaunchParams? = nil) {
        self.profile = profile

        super.init(backgroundColor: UIColor.Photon.Grey20, title: NSAttributedString(string: "Firefox Accounts"))

        self.url = URL(string: "http://example.com")!

        NotificationCenter.default.addObserver(self, selector: #selector(userDidVerify), name: .FirefoxAccountVerified, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // If the FxAContentViewController was launched from a FxA deferred link
        // onboarding might not have been shown. Check to see if it needs to be
        // displayed and don't animate.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.browserViewController.presentIntroViewController(false, animated: false)
        }
    }

    override func makeWebView() -> WKWebView {
        // Handle messages from the content server (via our user script).
        let contentController = WKUserContentController()
        contentController.add(LeakAvoider(delegate: self), name: "accountsCommandHandler")

        // Inject our user script after the page loads.
        if let path = Bundle.main.path(forResource: "FxASignIn", ofType: "js") {
            if let source = try? String(contentsOfFile: path, encoding: .utf8) {
                let userScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                contentController.addUserScript(userScript)
            }
        }

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(
            frame: CGRect(width: 1, height: 1),
            configuration: config
        )
        webView.allowsLinkPreview = false
        webView.accessibilityLabel = NSLocalizedString("Web content", comment: "Accessibility label for the main web content view")

        // Don't allow overscrolling.
        webView.scrollView.bounces = false
        return webView
    }

    // The user has signed in to a Firefox Account.  We're done!
    fileprivate func onLogin(_ data: JSON) {


        let app = UIApplication.shared
        let helper = FxALoginHelper.sharedInstance
        helper.delegate = self
        helper.application(app, didReceiveAccountJSON: data)

        if profile.hasAccount() {
            LeanPlumClient.shared.set(attributes: [LPAttributeKey.signedInSync: true])
        }

        LeanPlumClient.shared.track(event: .signsInFxa)
    }

    @objc fileprivate func userDidVerify(_ notification: Notification) {
        // This method stub is a leftover from when we removed the Account and Sync modules
        return
    }

    // The content server page is ready to be shown.
    fileprivate func onLoaded() {
        self.timer?.invalidate()
        self.timer = nil
        self.isLoaded = true
    }

    // Dispatch webkit messages originating from our child webview.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // This method stub is a leftover from when we removed the Account and Sync modules
    }
}

extension FxAContentViewController: FxAPushLoginDelegate {
    func accountLoginDidSucceed(withFlags flags: FxALoginFlags) {
        DispatchQueue.main.async {
            self.delegate?.contentViewControllerDidSignIn(self, withFlags: flags)
        }
    }

    func accountLoginDidFail() {
        DispatchQueue.main.async {
            self.delegate?.contentViewControllerDidCancel(self)
        }
    }
}

/*
LeakAvoider prevents leaks with WKUserContentController
http://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak
*/

class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
