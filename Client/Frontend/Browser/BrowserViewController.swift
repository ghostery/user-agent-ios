/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Photos
import UIKit
import WebKit
import Shared
import Storage
import SnapKit
import XCGLogger
import MobileCoreServices
import SDWebImage
import SwiftyJSON
import Sentry

private let KVOs: [KVOConstants] = [
    .estimatedProgress,
    .loading,
    .canGoBack,
    .canGoForward,
    .URL,
    .title,
]

private let ActionSheetTitleMaxLength = 120

private struct BrowserViewControllerUX {
    fileprivate static let OnboardingWidth = 375
    fileprivate static let OnboardingHeight = 667
    fileprivate static let ShowHeaderTapAreaHeight: CGFloat = 32
    fileprivate static let BookmarkStarAnimationDuration: Double = 0.5
    fileprivate static let BookmarkStarAnimationOffset: CGFloat = 80
    fileprivate static let WipeContextualOnboardingContentSize: CGSize = CGSize(width: 350, height: 510)
    fileprivate static let AutomaticForgetModeOnboardingContentSize: CGSize = CGSize(width: 350, height: 470)
}

protocol HomeViewControllerProtocol: Themeable {
    var view: UIView! { get set }
    func applyTheme()
    func scrollToTop()
    func scrollToTop(animated: Bool)
    func willMove(toParent parent: UIViewController?)
    func removeFromParent()
    func switchView(segment: HomeViewController.Segment)
    func switchViewToDefaultSegment()
    func refreshTopSites()
    func refreshBookmarks()
    func refreshHistory()
}

class BrowserViewController: UIViewController {
    var homeViewController: HomeViewControllerProtocol?
    var webViewContainer: UIView!
    var urlBar: URLBarView!
    var useCases: UseCases!
    var clipboardBarDisplayHandler: ClipboardBarDisplayHandler?
    var readerModeBar: ReaderModeBarView?
    var readerModeCache: ReaderModeCache
    var readerModeState: ReaderModeState = .unavailable {
        didSet {
            self.tabManager.selectedTab?.changedReaderMode = self.readerModeState == .active
        }
    }
    fileprivate(set) var toolbar: TabToolbar?
    var searchController: SearchResultsViewController?
    var screenshotHelper: ScreenshotHelper!
    var notchAreaCover: UIVisualEffectView = {
        return UIVisualEffectView()
    }()

    private let overlayBackground: UIVisualEffectView = {
        let effectView = UIVisualEffectView()
        effectView.effect = UIBlurEffect(style: .light)
        return effectView
    }()
    private var blurLayer: UIView?

    private var isStatusBarOrientationLandscape: Bool {
        return UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight
    }

    let alertStackView = UIStackView() // All content that appears above the footer should be added to this view. (Find In Page/SnackBars)
    var findInPageBar: FindInPageBar?

    lazy var mailtoLinkHandler = MailtoLinkHandler()

    fileprivate var customSearchBarButton: UIBarButtonItem?

    // popover rotation handling
    var displayedPopoverController: UIViewController?
    var updateDisplayedPopoverProperties: (() -> Void)?

    var openInHelper: OpenInHelper?

    // location label actions
    fileprivate var pasteGoAction: AccessibleAction!
    fileprivate var pasteAction: AccessibleAction!
    fileprivate var copyAddressAction: AccessibleAction!

    fileprivate weak var tabTrayController: TabTrayControllerV1?
    let profile: Profile
    let tabManager: TabManager

    // These views wrap the urlbar and toolbar to provide background effects on them
    var header: UIView!
    var footer: UIView!
    fileprivate var topTouchArea: UIButton!
    let urlBarTopTabsContainer = UIView(frame: CGRect.zero)
    var topTabsVisible: Bool {
        return topTabsViewController != nil
    }
    // Backdrop used for displaying greyed background for private tabs
    var webViewContainerBackdrop: UIView!

    var scrollController = TabScrollingController()

    fileprivate var keyboardState: KeyboardState?

    var pendingToast: Toast? // A toast that might be waiting for BVC to appear before displaying
    var downloadToast: DownloadToast? // A toast that is showing the combined download progress

    // Tracking navigation items to record history types.
    // TO DO : weak references?
    var ignoredNavigation = Set<WKNavigation>()
    var typedNavigation = [WKNavigation: VisitType]()
    var navigationToolbar: TabToolbarProtocol {
        return toolbar ?? urlBar
    }

    var topTabsViewController: TopTabsViewController?
    let topTabsContainer = UIView()

    // Keep track of allowed `URLRequest`s from `webView(_:decidePolicyFor:decisionHandler:)` so
    // that we can obtain the originating `URLRequest` when a `URLResponse` is received. This will
    // allow us to re-trigger the `URLRequest` if the user requests a file to be downloaded.
    var pendingRequests = [String: URLRequest]()

    // This is set when the user taps "Download Link" from the context menu. We then force a
    // download of the next request through the `WKNavigationDelegate` that matches this web view.
    weak var pendingDownloadWebView: WKWebView?

    let downloadQueue = DownloadQueue()

    init(profile: Profile, tabManager: TabManager) {
        self.profile = profile
        self.tabManager = tabManager
        self.readerModeCache = DiskReaderModeCache.sharedInstance
        super.init(nibName: nil, bundle: nil)
        didInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.isPhone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        dismissVisibleMenus()

        coordinator.animate(alongsideTransition: { context in
            self.scrollController.updateMinimumZoom()
            self.topTabsViewController?.scrollToCurrentTab(false, centerCell: false)
            if let popover = self.displayedPopoverController {
                self.updateDisplayedPopoverProperties?()
                self.present(popover, animated: true, completion: nil)
            }
            self.updateViewConstraints()
        }, completion: { _ in
            self.scrollController.setMinimumZoom()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    fileprivate func didInit() {
        screenshotHelper = ScreenshotHelper(controller: self)
        tabManager.addDelegate(self)
        tabManager.addNavigationDelegate(self)
        downloadQueue.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(displayThemeChanged), name: .DisplayThemeChanged, object: nil)
  }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.statusBarStyle
    }

    @objc func displayThemeChanged(notification: Notification) {
        applyTheme()
    }

    func showDownloads() {
        self.presentedViewController?.dismiss(animated: true)

        let downloadsViewContrller = DownloadsViewController()
        downloadsViewContrller.delegate = self
        downloadsViewContrller.profile = self.profile
        let navigationController = UINavigationController(rootViewController: downloadsViewContrller)
        if #available(iOS 13.0, *) {
            navigationController.modalPresentationStyle = UIDevice.current.isPhone ? .automatic : .formSheet
            navigationController.presentationController?.delegate = self
        } else {
            navigationController.modalPresentationStyle = UIDevice.current.isPhone ? .fullScreen : .formSheet
        }
        self.present(navigationController, animated: true)
    }

    func shouldShowFooterForTraitCollection(_ previousTraitCollection: UITraitCollection) -> Bool {
        return previousTraitCollection.verticalSizeClass != .compact && previousTraitCollection.horizontalSizeClass != .regular
    }

    func shouldShowTopTabsForTraitCollection(_ newTraitCollection: UITraitCollection) -> Bool {
        return newTraitCollection.verticalSizeClass == .regular && newTraitCollection.horizontalSizeClass == .regular
    }

    func toggleSnackBarVisibility(show: Bool) {
        if show {
            UIView.animate(withDuration: 0.1, animations: { self.alertStackView.isHidden = false })
        } else {
            alertStackView.isHidden = true
        }
    }

    func presentWhatsNewViewController() {
        guard let url = URL(string: Strings.WhatsNewWebsite) else {
            return
        }
        self.updateWhatsNewBadge()
        let viewController = SettingsContentViewController()
        viewController.url = url
        viewController.title = Strings.Menu.WhatsNewTitleString
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.General.CloseString, style: .done, closure: { (_) in
            self.setPhoneWindowBackground(color: Theme.browser.background, animationDuration: 1.0)
            navigationController.dismiss(animated: true)
        })
        if #available(iOS 13.0, *) {
            navigationController.modalPresentationStyle = UIDevice.current.isPhone ? .automatic : .formSheet
            navigationController.presentationController?.delegate = self
        } else {
            navigationController.modalPresentationStyle = UIDevice.current.isPhone ? .fullScreen : .formSheet
        }
        self.present(navigationController, animated: true)
    }

    func presentReportPageScreenFor(url: URL) {
        let message = String(format: Strings.PrivacyDashboard.ReportPage.AlertMessage, url.absoluteString, AppInfo.displayName, AppInfo.displayName)
        let reportPage = UIAlertController(title: Strings.PrivacyDashboard.ReportPage.AlertTitle, message: message, preferredStyle: .alert)
        reportPage.addAction(UIAlertAction(title: Strings.General.CancelString, style: .cancel, handler: nil))
        reportPage.addAction(UIAlertAction(title: Strings.General.SendString, style: .default ) { _ in
            let encoder = JSONEncoder()
            let comment =  reportPage.textFields?.first?.text
            let shortComment = comment?.truncateToUTF8ByteCount(200)
            let payloadDict = [
                "url": url.host ?? "",
                "type": "INADEQUATE_CONTENT",
                "comment": shortComment,
                "channel": "ios",
            ]
            guard
                let payloadData = try? encoder.encode(payloadDict),
                let payload = String(data: payloadData, encoding: .utf8)
            else { return }

            ReactNativeBridge.sharedInstance.browserCore.callAction(module: "hpn-lite", action: "send", args: [
                [
                    "action": "report-url",
                    "method": "POST",
                    "payload": payload,
                    "path": "",
                ],
            ])
        })
        reportPage.addTextField(configurationHandler: nil)
        self.present(reportPage, animated: true, completion: nil)
    }

    func presentDataAndPrivacyViewController() {
        guard let dataAndPrivacyViewController = DataAndPrivacy.presentingViewController(prefs: self.profile.prefs, delegate: self) else { return }
        if #available(iOS 13.0, *) {
            dataAndPrivacyViewController.modalPresentationStyle = UIDevice.current.isPhone ? .automatic : .formSheet
            dataAndPrivacyViewController.presentationController?.delegate = self
        } else {
            dataAndPrivacyViewController.modalPresentationStyle = UIDevice.current.isPhone ? .fullScreen : .formSheet
        }
        self.present(dataAndPrivacyViewController, animated: true)
    }

    func presentWipeAllTracesContextualOnboarding() {
        let value = self.profile.prefs.boolForKey(PrefsKeys.WipeAllTraces)
        guard value == nil || !value! else {
            return
        }
        let icon = UIImage(named: "wipe-white")
        let title = Strings.ContextualOnboarding.WipeAllTraces.Title
        let description = Strings.ContextualOnboarding.WipeAllTraces.Description
        let detail = ContextualOnboardingDitail(backgroundGradientColors: [.COLightBlue, .CODarkBlue], title: title, icon: icon, description: description)
        self.presentContextualOnboardingViewController(detail: detail, prefKey: PrefsKeys.WipeAllTraces, contentSize: BrowserViewControllerUX.WipeContextualOnboardingContentSize)
    }

    func presentAutomaticForgetModeContextualOnboarding() {
        let value = self.profile.prefs.boolForKey(PrefsKeys.AutomaticForgetMode)
        guard value == nil || !value! else {
            return
        }
        let icon = UIImage(named: "forgetMode")
        let title = Strings.ForgetMode.AutomaticPrivateMode.Title
        let description = Strings.ForgetMode.AutomaticPrivateMode.Description
        let detail = ContextualOnboardingDitail(backgroundGradientColors: [.COLightBlue, .CODarkBlue], title: title, icon: icon, description: description)
        self.presentContextualOnboardingViewController(detail: detail, prefKey: PrefsKeys.WipeAllTraces, contentSize: BrowserViewControllerUX.AutomaticForgetModeOnboardingContentSize)
    }

    func presentContextualOnboardingViewController(detail: ContextualOnboardingDitail, prefKey: String, contentSize: CGSize) {
        let viewController = ContextualOnboardingViewController(contentDetail: detail, profile: self.profile, prefKey: prefKey)
        viewController.modalPresentationStyle = self.traitCollection.horizontalSizeClass == .regular ? .formSheet : .overCurrentContext
        viewController.preferredContentSize = contentSize
        self.present(viewController, animated: true)
    }

    func setPhoneWindowBackground(color: UIColor, animationDuration: TimeInterval? = nil) {
        if UIDevice.current.isPhone {
            if let duration = animationDuration {
                UIView.animate(withDuration: duration) {
                    self.view.window?.backgroundColor = color
                }
            } else {
                self.view.window?.backgroundColor = color
            }
        }
    }

    private func updateWhatsNewBadge() {
        let shouldShowWhatsNeweBadge = self.profile.prefs.boolForKey(PrefsKeys.WhatsNewBubble) == nil
        self.toolbar?.whatsNeweBadge(visible: shouldShowWhatsNeweBadge)
        self.urlBar.whatsNeweBadge(visible: shouldShowWhatsNeweBadge)
    }

    func didPressBurnMenuItem() {
        let actions = self.getBurnActions(presentableVC: self)
        // force a modal if the menu is being displayed in compact split screen
        let shouldSuppress = !topTabsVisible && UIDevice.current.isPad
        guard let button = UIDevice.current.isPad ? self.urlBar.menuButton : self.toolbar?.menuButton else {
            return
        }
        self.presentSheetWith(actions: actions, on: self, from: button, closeButtonTitle: Strings.General.CancelString, suppressPopover: shouldSuppress)
    }

    fileprivate func updateToolbarStateForTraitCollection(_ newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator? = nil) {
        let showToolbar = shouldShowFooterForTraitCollection(newCollection)
        let showTopTabs = shouldShowTopTabsForTraitCollection(newCollection)

        urlBar.topTabsIsShowing = showTopTabs
        urlBar.setShowToolbar(!showToolbar)
        toolbar?.removeFromSuperview()
        toolbar?.tabToolbarDelegate = nil
        toolbar = nil

        if showToolbar {
            toolbar = TabToolbar()
            footer.addSubview(toolbar!)
            toolbar?.tabToolbarDelegate = self
            toolbar?.applyUIMode(isPrivate: tabManager.selectedTab?.isPrivate ?? false)
            self.updateWhatsNewBadge()
            toolbar?.applyTheme()
            updateTabCountUsingTabManager(self.tabManager)
        }

        if showTopTabs {
            if topTabsViewController == nil {
                let topTabsViewController = TopTabsViewController(tabManager: tabManager)
                topTabsViewController.delegate = self
                addChild(topTabsViewController)
                topTabsViewController.view.frame = topTabsContainer.frame
                topTabsContainer.addSubview(topTabsViewController.view)
                topTabsViewController.view.snp.makeConstraints { make in
                    make.edges.equalTo(topTabsContainer)
                    make.height.equalTo(TopTabsUX.TopTabsViewHeight)
                }
                self.topTabsViewController = topTabsViewController
                topTabsViewController.applyTheme()
            }
            topTabsContainer.snp.updateConstraints { make in
                make.height.equalTo(TopTabsUX.TopTabsViewHeight)
            }
        } else {
            topTabsContainer.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            topTabsViewController?.view.removeFromSuperview()
            topTabsViewController?.removeFromParent()
            topTabsViewController = nil
        }

        view.setNeedsUpdateConstraints()
        homeViewController?.view.setNeedsUpdateConstraints()

        if let tab = tabManager.selectedTab,
               let webView = tab.webView {
            updateURLBarDisplayURL(tab)
            navigationToolbar.updateBackStatus(webView.canGoBack)
            navigationToolbar.updateForwardStatus(webView.canGoForward)
            navigationToolbar.updateReloadStatus(tab.loading)
        }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        // During split screen launching on iPad, this callback gets fired before viewDidLoad gets a chance to
        // set things up. Make sure to only update the toolbar state if the view is ready for it.
        if isViewLoaded {
            updateToolbarStateForTraitCollection(newCollection, withTransitionCoordinator: coordinator)
            self.updateViewConstraints()
        }

        displayedPopoverController?.dismiss(animated: true, completion: nil)
        coordinator.animate(alongsideTransition: { context in
            self.scrollController.showToolbars(animated: false)
            if self.isViewLoaded {
                self.setNeedsStatusBarAppearanceUpdate()
            }
            }, completion: nil)
    }

    func dismissVisibleMenus() {
        displayedPopoverController?.dismiss(animated: true)
        if let _ = self.presentedViewController as? PhotonActionSheet {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }

    @objc func appDidEnterBackgroundNotification() {
        displayedPopoverController?.dismiss(animated: false) {
            self.updateDisplayedPopoverProperties = nil
            self.displayedPopoverController = nil
        }
    }

    @objc func tappedTopArea() {
        scrollController.showToolbars(animated: true)
    }

   @objc  func appWillResignActiveNotification() {
        // Dismiss any popovers that might be visible
        displayedPopoverController?.dismiss(animated: false) {
            self.updateDisplayedPopoverProperties = nil
            self.displayedPopoverController = nil
        }

        // If we are displying a private tab, hide any elements in the tab that we wouldn't want shown
        // when the app is in the home switcher
        guard let privateTab = tabManager.selectedTab, privateTab.isPrivate else {
            return
        }

        view.bringSubviewToFront(webViewContainerBackdrop)
        webViewContainerBackdrop.alpha = 1
        webViewContainer.alpha = 0
        urlBar.locationContainer.alpha = 0
        topTabsViewController?.switchForegroundStatus(isInForeground: false)
        presentedViewController?.popoverPresentationController?.containerView?.alpha = 0
        presentedViewController?.view.alpha = 0
    }

    @objc func appDidBecomeActiveNotification() {
        // Re-show any components that might have been hidden because they were being displayed
        // as part of a private mode tab
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.webViewContainer.alpha = 1
            self.urlBar.locationContainer.alpha = 1
            self.topTabsViewController?.switchForegroundStatus(isInForeground: true)
            self.presentedViewController?.popoverPresentationController?.containerView?.alpha = 1
            self.presentedViewController?.view.alpha = 1
            self.view.backgroundColor = UIColor.clear
        }, completion: { _ in
            self.webViewContainerBackdrop.alpha = 0
            self.view.sendSubviewToBack(self.webViewContainerBackdrop)
        })

        // Re-show toolbar which might have been hidden during scrolling (prior to app moving into the background)
        scrollController.showToolbars(animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
        KeyboardHelper.defaultHelper.addDelegate(self)

        webViewContainerBackdrop = UIView()
        webViewContainerBackdrop.backgroundColor = UIColor.Grey50
        webViewContainerBackdrop.alpha = 0
        view.addSubview(webViewContainerBackdrop)

        webViewContainer = UIView()
        view.addSubview(webViewContainer)

        self.setupURLBarBlurEffect()
        view.addSubview(self.notchAreaCover)

        topTouchArea = UIButton()
        topTouchArea.isAccessibilityElement = false
        topTouchArea.addTarget(self, action: #selector(tappedTopArea), for: .touchUpInside)
        view.addSubview(topTouchArea)

        // Setup the URL bar, wrapped in a view to get transparency effect
        urlBar = URLBarView()
        urlBar.translatesAutoresizingMaskIntoConstraints = false
        urlBar.delegate = self
        urlBar.tabToolbarDelegate = self
        header = urlBarTopTabsContainer
        urlBarTopTabsContainer.addSubview(urlBar)
        urlBarTopTabsContainer.addSubview(topTabsContainer)
        notchAreaCover.contentView.addSubview(header)

        self.updateWhatsNewBadge()
        // UIAccessibilityCustomAction subclass holding an AccessibleAction instance does not work, thus unable to generate AccessibleActions and UIAccessibilityCustomActions "on-demand" and need to make them "persistent" e.g. by being stored in BVC
        pasteGoAction = AccessibleAction(name: Strings.Menu.PasteAndGoTitle, handler: { () -> Bool in
            if let pasteboardContents = UIPasteboard.general.string {
                self.urlBar(self.urlBar, didSubmitText: pasteboardContents, completion: nil)
                return true
            }
            return false
        })
        pasteAction = AccessibleAction(name: Strings.Menu.PasteTitle, handler: { () -> Bool in
            if let pasteboardContents = UIPasteboard.general.string {
                // Enter overlay mode and make the search controller appear.
                self.urlBar.enterOverlayMode(pasteboardContents, pasted: true, search: true)

                return true
            }
            return false
        })
        copyAddressAction = AccessibleAction(name: Strings.Menu.CopyAddressTitle, handler: { () -> Bool in
            if let url = self.tabManager.selectedTab?.canonicalURL?.displayURL ?? self.urlBar.currentURL {
                UIPasteboard.general.url = url
            }
            return true
        })

        view.addSubview(alertStackView)
        footer = UIView()
        view.addSubview(footer)
        alertStackView.axis = .vertical
        alertStackView.alignment = .center

        view.addSubview(self.overlayBackground)
        self.hideOverlayBackground()
        clipboardBarDisplayHandler = ClipboardBarDisplayHandler(prefs: profile.prefs, tabManager: tabManager)
        clipboardBarDisplayHandler?.delegate = self

        scrollController.urlBar = urlBar
        scrollController.readerModeBar = readerModeBar
        scrollController.header = header
        scrollController.footer = footer
        scrollController.snackBars = alertStackView

        self.updateToolbarStateForTraitCollection(self.traitCollection)

        setupConstraints()

        // Setup UIDropInteraction to handle dragging and dropping
        // links into the view from other apps.
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
    }

    fileprivate func setupConstraints() {
        topTabsContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.header)
            make.top.equalTo(urlBarTopTabsContainer)
        }

        urlBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(urlBarTopTabsContainer)
            make.height.equalTo(UIConstants.TopToolbarHeight)
            make.top.equalTo(topTabsContainer.snp.bottom)
        }

        header.snp.makeConstraints { make in
            scrollController.headerTopConstraint = make.top.equalTo(self.view.safeArea.top).constraint
            make.left.right.equalTo(self.view)
        }

        webViewContainerBackdrop.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        overlayBackground.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        notchAreaCover.snp.makeConstraints { (make) in
            make.topMargin.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.header.snp.bottom)
        }
    }

    func loadQueuedTabs(receivedURLs: [URL]? = nil) {
        // Chain off of a trivial deferred in order to run on the background queue.
        succeed().upon() { res in
            self.dequeueQueuedTabs(receivedURLs: receivedURLs ?? [])
        }
    }

    fileprivate func dequeueQueuedTabs(receivedURLs: [URL]) {
        assert(!Thread.current.isMainThread, "This must be called in the background.")
        self.profile.queue.getQueuedTabs() >>== { cursor in

            // This assumes that the DB returns rows in some kind of sane order.
            // It does in practice, so WFM.
            // swiftlint:disable:next empty_count
            if cursor.count > 0 {

                // Filter out any tabs received by a push notification to prevent dupes.
                let urls = cursor.compactMap { $0?.url.asURL }.filter { !receivedURLs.contains($0) }
                if !urls.isEmpty {
                    DispatchQueue.main.async {
                        self.tabManager.addTabsForURLs(urls, zombie: false)
                    }
                }

                // Clear *after* making an attempt to open. We're making a bet that
                // it's better to run the risk of perhaps opening twice on a crash,
                // rather than losing data.
                self.profile.queue.clearQueuedTabs()
            }

            // Then, open any received URLs from push notifications.
            if !receivedURLs.isEmpty {
                DispatchQueue.main.async {
                    self.tabManager.addTabsForURLs(receivedURLs, zombie: false)
                }
            }
        }
    }

    // Because crashedLastLaunch is sticky, it does not get reset, we need to remember its
    // value so that we do not keep asking the user to restore their tabs.
    var displayedRestoreTabsAlert = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // On iPhone, if we are about to show the On-Boarding, blank out the tab so that it does
        // not flash before we present. This change of alpha also participates in the animation when
        // the intro view is dismissed.
        if UIDevice.current.isPhone {
            self.view.alpha = (!Onboarding.isEnabled || profile.prefs.intForKey(PrefsKeys.IntroSeen) != nil) ? 1.0 : 0.0
        }

        if !displayedRestoreTabsAlert && !cleanlyBackgrounded() && crashedLastLaunch() {
            displayedRestoreTabsAlert = true
            showRestoreTabsAlert()
        } else {
            tabManager.restoreTabs()
        }

        updateTabCountUsingTabManager(tabManager, animated: false)
        clipboardBarDisplayHandler?.checkIfShouldDisplayBar()
    }

    fileprivate func crashedLastLaunch() -> Bool {
        return Sentry.crashedLastLaunch
    }

    fileprivate func cleanlyBackgrounded() -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        return appDelegate.applicationCleanlyBackgrounded
    }

    fileprivate func showRestoreTabsAlert() {
        guard tabManager.hasTabsToRestoreAtStartup() else {
            tabManager.selectTab(tabManager.addTab())
            return
        }
        let alert = UIAlertController.restoreTabsAlert(
            okayCallback: { _ in
                self.tabManager.restoreTabs()
            },
            noCallback: { _ in
                self.tabManager.selectTab(self.tabManager.addTab())
            }
        )
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        presentOnboarding()

        screenshotHelper.viewIsVisible = true
        screenshotHelper.takePendingScreenshots(tabManager.tabs)

        super.viewDidAppear(animated)

        if let toast = self.pendingToast {
            self.pendingToast = nil
            show(toast: toast, afterWaiting: ButtonToastUX.ToastDelay)
        }
        showQueuedAlertIfAvailable()
    }

    fileprivate func showQueuedAlertIfAvailable() {
        if let queuedAlertInfo = tabManager.selectedTab?.dequeueJavascriptAlertPrompt() {
            let alertController = queuedAlertInfo.alertController()
            alertController.delegate = self
            present(alertController, animated: true, completion: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        screenshotHelper.viewIsVisible = false
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func resetBrowserChrome() {
        // animate and reset transform for tab chrome
        urlBar.updateAlphaForSubviews(1)
        footer.alpha = 1

        [header, footer, readerModeBar].forEach { view in
            view?.transform = .identity
        }
        self.notchAreaCover.isHidden = false
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        topTouchArea.snp.remakeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.height.equalTo(BrowserViewControllerUX.ShowHeaderTapAreaHeight)
        }

        readerModeBar?.snp.remakeConstraints { make in
            make.top.equalTo(self.header.snp.bottom)
            make.height.equalTo(UIConstants.ToolbarHeight)
            make.leading.trailing.equalTo(self.view)
        }

        webViewContainer.snp.remakeConstraints { make in
            make.left.right.equalTo(self.view)

            if let readerModeBarBottom = readerModeBar?.snp.bottom {
                make.top.equalTo(readerModeBarBottom)
            } else {
                make.top.equalTo(self.header.snp.bottom)
            }

            let findInPageHeight = (findInPageBar == nil) ? 0 : UIConstants.ToolbarHeight
            if let toolbar = self.toolbar {
                make.bottom.equalTo(toolbar.snp.top).offset(-findInPageHeight)
            } else {
                make.bottom.equalTo(self.view).offset(-findInPageHeight)
            }
        }

        // Setup the bottom toolbar
        toolbar?.snp.remakeConstraints { make in
            make.edges.equalTo(self.footer)
            make.height.equalTo(UIConstants.BottomToolbarHeight)
        }

        footer.snp.remakeConstraints { make in
            scrollController.footerBottomConstraint = make.bottom.equalTo(self.view.snp.bottom).constraint
            make.leading.trailing.equalTo(self.view)
        }

        urlBar.setNeedsUpdateConstraints()

        // Remake constraints even if we're already showing the home controller.
        // The home controller may change sizes if we tap the URL bar while on about:home.
        homeViewController?.view.snp.remakeConstraints { make in
            if self.toolbar != nil {
                make.top.equalTo(self.view.safeArea.top)
            } else {
                make.top.equalTo(self.urlBar.snp.bottom)
            }

            make.left.right.equalTo(self.view)

            make.bottom.equalTo(self.view.snp.bottom)
        }

        if self.urlBar.inOverlayMode {
            self.view.sendSubviewToBack(self.footer)
        } else {
            self.view.bringSubviewToFront(self.footer)
        }

        alertStackView.snp.remakeConstraints { make in
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view.safeArea.width)
            if let keyboardHeight = keyboardState?.intersectionHeightForView(self.view), keyboardHeight > 0 {
                make.bottom.equalTo(self.view).offset(-keyboardHeight)
            } else if let toolbar = self.toolbar {
                make.bottom.lessThanOrEqualTo(toolbar.snp.top)
                make.bottom.lessThanOrEqualTo(self.view.safeArea.bottom)
            } else {
                make.bottom.equalTo(self.view.safeArea.bottom)
            }
        }
    }

    private func showBlur(animation: Bool = true) {
        guard self.blurLayer == nil else {
            return
        }
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        self.blurLayer = blurEffectView

        blurEffectView.snp.makeConstraints { make in
            make.top.equalTo(self.urlBar.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        view.bringSubviewToFront(notchAreaCover)
        self.blurLayer?.alpha = 0.0
        let duration = animation ? 0.3 : 0.0
        UIView.animate(withDuration: duration) {
            self.blurLayer?.alpha = 0.98
        }
    }

    private func hideBlur(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurLayer?.alpha = 0.0
        }) { (_) in
            self.blurLayer?.removeFromSuperview()
            self.blurLayer = nil
            completion?()
        }
    }

    fileprivate func showHome() {
        if self.homeViewController == nil {
            let homeViewController = HomeViewNavigationController(
                profile: profile,
                toolbarHeight: self.traitCollection.horizontalSizeClass == .compact ? UIConstants.BottomToolbarHeight : 0)
            homeViewController.homePanelDelegate = self
            homeViewController.view.alpha = 0.0
            self.homeViewController = homeViewController
            addChild(homeViewController)
            view.addSubview(homeViewController.view)
            homeViewController.didMove(toParent: self)
        }

        homeViewController?.applyTheme()

        // We have to run this animation, even if the view is already showing
        // because there may be a hide animation running and we want to be sure
        // to override its results.
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.homeViewController?.view.alpha = 1.0
        }, completion: { finished in
            if finished {
                self.webViewContainer.accessibilityElementsHidden = true
                UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: nil)
            }
        })
        view.setNeedsUpdateConstraints()
    }

    fileprivate func hideHome() {
        guard let browserHomeViewController = self.homeViewController else {
            return
        }

        self.homeViewController = nil
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: { () -> Void in
            browserHomeViewController.view.alpha = 0
        }, completion: { _ in
            browserHomeViewController.willMove(toParent: nil)
            browserHomeViewController.view.removeFromSuperview()
            browserHomeViewController.removeFromParent()
            self.webViewContainer.accessibilityElementsHidden = false
            UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: nil)

            // Refresh the reading view toolbar since the article record may have changed
            if let readerMode = self.tabManager.selectedTab?.getContentScript(name: ReaderMode.name()) as? ReaderMode, readerMode.state == .active {
                self.showReaderModeBar(animated: false)
            }
        })
    }

    fileprivate func updateInContentHomePanel(_ url: URL?) {
        let isAboutHomeURL = url.flatMap { InternalURL($0)?.isAboutHomeURL } ?? false
        if !urlBar.inOverlayMode {
            guard let url = url else {
                hideHome()
                return
            }
            if isAboutHomeURL {
                showHome()
            } else if !url.absoluteString.hasPrefix("\(InternalURL.baseUrl)/\(SessionRestoreHandler.path)") {
                hideHome()
            }
        }
    }

    fileprivate func createSearchControllerIfNeeded() {
        guard self.searchController == nil else {
            return
        }

        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        let searchController = SearchResultsViewController(profile: profile, isPrivate: isPrivate)

        self.searchController = searchController
    }

    fileprivate func showSearchController() {
        createSearchControllerIfNeeded()
        self.hideBlur()

        guard let searchController = self.searchController else {
            return
        }
        self.view.bringSubviewToFront(self.overlayBackground)

        addChild(searchController)
        view.addSubview(searchController.view)
        searchController.view.snp.makeConstraints { make in
            make.top.equalTo(urlBar.snp.bottom)
            make.left.bottom.right.equalTo(self.view)
        }

        searchController.searchView.snp.makeConstraints { make in
            make.top.equalTo(urlBar.snp.bottom).offset(-self.urlBar.frame.size.height / 2)
            make.left.equalTo(urlBar.locationContainer.snp.left)
            make.right.equalTo(urlBar.locationContainer.snp.right)
            make.bottom.equalToSuperview()
        }

        view.bringSubviewToFront(notchAreaCover)

        searchController.didMove(toParent: self)
        self.showOverlayBackground()
    }

    fileprivate func hideSearchController() {
        self.hideOverlayBackground()
        if let searchController = self.searchController {
            searchController.willMove(toParent: nil)
            searchController.view.removeFromSuperview()
            searchController.removeFromParent()
        }
    }

    fileprivate func hideOverlayBackground() {
        self.overlayBackground.isHidden = true
        self.topTabsViewController?.view.isHidden = false
        self.setupURLBarBlurEffect()
    }

    fileprivate func showOverlayBackground() {
        self.topTabsViewController?.view.isHidden = true
        self.overlayBackground.isHidden = false
        self.notchAreaCover.effect = nil
    }

    fileprivate func setupURLBarBlurEffect() {
        if #available(iOS 13.0, *) {
            self.notchAreaCover.effect = UIBlurEffect(style: .systemMaterial)
        } else {
            self.notchAreaCover.effect = UIBlurEffect(style: .light)
        }
    }

    fileprivate func destroySearchController() {
        hideSearchController()
        searchController = nil
    }

    func openURL(url: URL, visitType: VisitType) {
        guard let tab = tabManager.selectedTab else { return }
        finishEditingAndSubmit(url, visitType: visitType, forTab: tab)
    }

    func openURLInNewTab(url: URL, isPrivate: Bool) {
        let tab = self.tabManager.addTab(PrivilegedRequest(url: url) as URLRequest, afterTab: self.tabManager.selectedTab, isPrivate: isPrivate)
        if self.urlBar.inOverlayMode {
            self.urlBar.cancel()
        }

        self.tabManager.selectTabOrOpenInBackground(tab)
    }

    func openAndShowURLInNewTab(url: URL, isPrivate: Bool) {
        let tab = self.tabManager.addTab(PrivilegedRequest(url: url) as URLRequest, afterTab: self.tabManager.selectedTab, isPrivate: isPrivate)
        self.tabManager.selectTab(tab)
    }

    func finishEditingAndSubmit(_ url: URL, visitType: VisitType, forTab tab: Tab) {
        urlBar.currentURL = url
        urlBar.leaveOverlayMode()

        if let nav = tab.loadRequest(PrivilegedRequest(url: url) as URLRequest) {
            self.recordNavigationInTab(tab, navigation: nav, visitType: visitType)
        }
        if self.profile.prefs.boolForKey(PrefsKeys.ShowAppReview) == nil {
            self.profile.prefs.setBool(true, forKey: PrefsKeys.ShowAppReview)
        }
    }

    func addBookmark(url: String, title: String? = nil, favicon: Favicon? = nil) {
        var title = (title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty {
            title = url
        }

        let shareItem = ShareItem(url: url, title: title, favicon: favicon)
        self.profile.bookmarks.shareItem(shareItem).uponQueue(.main) { success in
            print(success)
        }
    }

    override func accessibilityPerformEscape() -> Bool {
        if urlBar.inOverlayMode {
            urlBar.didClickCancel()
            return true
        } else if let selectedTab = tabManager.selectedTab, selectedTab.canGoBack {
            selectedTab.goBack()
            return true
        }
        return false
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let webView = object as? WKWebView, let tab = tabManager[webView] else {
            assert(false)
            return
        }
        guard let kp = keyPath, let path = KVOConstants(rawValue: kp) else {
            assertionFailure("Unhandled KVO key: \(keyPath ?? "nil")")
            return
        }

        if let helper = tab.getContentScript(name: ContextMenuHelper.name()) as? ContextMenuHelper {
            // This is zero-cost if already installed. It needs to be checked frequently (hence every event here triggers this function), as when a new tab is created it requires multiple attempts to setup the handler correctly.
             helper.replaceGestureHandlerIfNeeded()
        }

        switch path {
        case .estimatedProgress:
            guard tab === tabManager.selectedTab else { break }
            if let url = webView.url, !InternalURL.isValid(url: url) {
                urlBar.updateProgressBar(Float(webView.estimatedProgress))
            } else {
                urlBar.hideProgressBar()
            }
        case .loading:
            guard let loading = change?[.newKey] as? Bool else { break }

            if tab === tabManager.selectedTab {
                navigationToolbar.updateReloadStatus(loading)
            }
        case .URL:
            // To prevent spoofing, only change the URL immediately if the new URL is on
            // the same origin as the current URL. Otherwise, do nothing and wait for
            // didCommitNavigation to confirm the page load.
            if tab.url?.origin == webView.url?.origin {
                tab.url = webView.url

                if tab === tabManager.selectedTab && !tab.restoring {
                    updateUIForReaderHomeStateForTab(tab)
                }

                // Catch history pushState navigation, but ONLY for same origin navigation,
                // for reasons above about URL spoofing risk.
                navigateInTab(tab: tab, webViewStatus: .url)
            }
        case .title:
            // Ensure that the tab title *actually* changed to prevent repeated calls
            // to navigateInTab(tab:).
            guard let title = tab.title else { break }
            if !title.isEmpty && title != tab.lastTitle {
                tab.lastTitle = title
                navigateInTab(tab: tab, webViewStatus: .title)
            }
        case .canGoBack:
            guard tab === tabManager.selectedTab, let canGoBack = change?[.newKey] as? Bool else {
                break
            }
            navigationToolbar.updateBackStatus(canGoBack)
        case .canGoForward:
            guard tab === tabManager.selectedTab, let canGoForward = change?[.newKey] as? Bool else {
                break
            }
            navigationToolbar.updateForwardStatus(canGoForward)
        default:
            assertionFailure("Unhandled KVO key: \(keyPath ?? "nil")")
        }
    }

    func updateUIForReaderHomeStateForTab(_ tab: Tab) {
        updateURLBarDisplayURL(tab)
        scrollController.showToolbars(animated: false)

        if let url = tab.url {
            if url.isReaderModeURL {
                showReaderModeBar(animated: false)
                NotificationCenter.default.addObserver(self, selector: #selector(dynamicFontChanged), name: .DynamicFontChanged, object: nil)
            } else {
                hideReaderModeBar(animated: false)
                NotificationCenter.default.removeObserver(self, name: .DynamicFontChanged, object: nil)
            }

            updateInContentHomePanel(url as URL)
        }
    }

    /// Updates the URL bar text and button states.
    /// Call this whenever the page URL changes.
    fileprivate func updateURLBarDisplayURL(_ tab: Tab) {
        urlBar.currentURL = tab.url?.displayURL
        urlBar.locationView.showLockIcon(forSecureContent: tab.webView?.hasOnlySecureContent ?? false)
        let isPage = tab.url?.displayURL?.isWebPage() ?? false
        navigationToolbar.updatePageStatus(isPage)
    }

    // MARK: Opening New Tabs
    func switchToPrivacyMode(isPrivate: Bool) {
         if let tabTrayController = self.tabTrayController, tabTrayController.tabDisplayManager.isPrivate != isPrivate {
            tabTrayController.changePrivacyMode(isPrivate)
        }
        topTabsViewController?.applyUIMode(isPrivate: isPrivate)
    }

    func switchToTabForURLOrOpen(_ url: URL, isPrivate: Bool = false, isPrivileged: Bool) {
        popToBVC()
        if let tab = tabManager.getTabFor(url) {
            tabManager.selectTab(tab)
        } else {
            openURLInNewTab(url, isPrivate: isPrivate, isPrivileged: isPrivileged)
        }
    }

    func openURLInNewTab(_ url: URL?, isPrivate: Bool = false, isPrivileged: Bool, forceInNewTab: Bool = true) {
        popToBVC()
        if let selectedTab = tabManager.selectedTab {
            screenshotHelper.takeScreenshot(selectedTab)
        }
        let request: URLRequest?
        if let url = url {
            request = isPrivileged ? PrivilegedRequest(url: url) as URLRequest : URLRequest(url: url)
        } else {
            request = nil
        }

        switchToPrivacyMode(isPrivate: isPrivate)
        if forceInNewTab {
            tabManager.selectTab(tabManager.addTab(request, isPrivate: isPrivate))
        } else {
            tabManager.selectTabOrOpenInBackground(tabManager.addTab(request, isPrivate: isPrivate))
        }
    }

    func focusLocationTextField(forTab tab: Tab?, setSearchText searchText: String? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            // Without a delay, the text field fails to become first responder
            // Check that the newly created tab is still selected.
            // This let's the user spam the Cmd+T button without lots of responder changes.
            guard tab == self.tabManager.selectedTab else { return }
            self.urlBar.enterOverlayMode(searchText, pasted: true, search: true)
        }
    }

    func openBlankNewTab(focusLocationField: Bool, isPrivate: Bool = false, searchFor searchText: String? = nil) {
        popToBVC()
        openURLInNewTab(nil, isPrivate: isPrivate, isPrivileged: true)
        let freshTab = tabManager.selectedTab
        if focusLocationField {
            focusLocationTextField(forTab: freshTab, setSearchText: searchText)
        }
    }

    func openSearchNewTab(isPrivate: Bool = false, _ text: String) {
        popToBVC()
        let engine = profile.searchEngines.defaultEngine
        if let searchURL = engine.searchURLForQuery(text) {
            openURLInNewTab(searchURL, isPrivate: isPrivate, isPrivileged: true)
        } else {
            // We still don't have a valid URL, so something is broken. Give up.
            print("Error handling URL entry: \"\(text)\".")
            assertionFailure("Couldn't generate search URL: \(text)")
        }
    }

    func showSearchInNewTab(query: String?) {
        popToBVC()
        var isPrivate = false
        if let selectedTab = self.tabManager.selectedTab {
            self.screenshotHelper.takeScreenshot(selectedTab)
            isPrivate = selectedTab.isPrivate
        }
        self.tabManager.selectTab(self.tabManager.addTab(isPrivate: isPrivate))
        self.urlBar.enterOverlayMode(query, pasted: true, search: true)
    }

    fileprivate func popToBVC() {
        guard let currentViewController = navigationController?.topViewController else {
                return
        }
        self.setPhoneWindowBackground(color: Theme.browser.background, animationDuration: 1.0)
        currentViewController.dismiss(animated: true, completion: nil)
        if currentViewController != self {
            _ = self.navigationController?.popViewController(animated: true)
        } else if urlBar.inOverlayMode {
            urlBar.didClickCancel()
        }
    }

    public func presentActivityViewController(_ url: URL, tab: Tab? = nil, sourceView: UIView?, sourceRect: CGRect, arrowDirection: UIPopoverArrowDirection) {
        let helper = ShareExtensionHelper(url: url, tab: tab)

        let controller = helper.createActivityViewController({ [unowned self] completed, _ in
            // After dismissing, check to see if there were any prompts we queued up
            self.showQueuedAlertIfAvailable()

            // Usually the popover delegate would handle nil'ing out the references we have to it
            // on the BVC when displaying as a popover but the delegate method doesn't seem to be
            // invoked on iOS 10. See Bug 1297768 for additional details.
            self.displayedPopoverController = nil
            self.updateDisplayedPopoverProperties = nil
        })

        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceRect
            popoverPresentationController.permittedArrowDirections = arrowDirection
            popoverPresentationController.delegate = self
        }

        present(controller, animated: true, completion: nil)
    }

    @discardableResult
    func presentSettingsViewController() -> UINavigationController {
        let viewController = AppSettingsTableViewController()
        if #available(iOS 13.0, *) {
            viewController.isModalInPresentation = AppConstants.IsRunningTest
        }
        viewController.profile = self.profile
        viewController.tabManager = self.tabManager
        viewController.settingsDelegate = self
        let navigationController = ThemedNavigationController(rootViewController: viewController)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.General.DoneString, style: .done, closure: { (_) in
            self.setPhoneWindowBackground(color: Theme.browser.background, animationDuration: 1.0)
            navigationController.dismiss(animated: true)
        })
        if #available(iOS 13.0, *) {
            navigationController.modalPresentationStyle = UIDevice.current.isPhone ? .automatic : .formSheet
            navigationController.presentationController?.delegate = self
        } else {
            navigationController.modalPresentationStyle = UIDevice.current.isPhone ? .fullScreen : .formSheet
        }
        self.present(navigationController, animated: true)
        return navigationController
    }

    fileprivate func postLocationChangeNotificationForTab(_ tab: Tab, navigation: WKNavigation?) {
        let notificationCenter = NotificationCenter.default
        var info = [AnyHashable: Any]()
        info["url"] = tab.url?.displayURL
        info["title"] = tab.title
        if let visitType = self.getVisitTypeForTab(tab, navigation: navigation)?.rawValue {
            info["visitType"] = visitType
        }
        info["isPrivate"] = tab.isPrivate
        notificationCenter.post(name: .OnLocationChange, object: self, userInfo: info)
    }

    /// Enum to represent the WebView observation or delegate that triggered calling `navigateInTab`
    enum WebViewUpdateStatus {
        case title
        case url
        case finishedNavigation
    }
    
    func navigateInTab(tab: Tab, to navigation: WKNavigation? = nil, webViewStatus: WebViewUpdateStatus) {
        tabManager.expireSnackbars()

        guard let webView = tab.webView else {
            print("Cannot navigate in tab without a webView")
            return
        }

        if let url = webView.url {
            if tab === tabManager.selectedTab {
                urlBar.locationView.showLockIcon(forSecureContent: webView.hasOnlySecureContent)
            }

            if (!InternalURL.isValid(url: url) || url.isReaderModeURL), !url.isFileURL {
                postLocationChangeNotificationForTab(tab, navigation: navigation)

                webView.evaluateJavascriptInDefaultContentWorld("\(ReaderModeNamespace).checkReadability()")
            }

            TabEvent.post(.didChangeURL(url), for: tab)
        }
        
        // Represents WebView observation or delegate update that called this function
        switch webViewStatus {
        case .title, .url, .finishedNavigation:
            if tab !== tabManager.selectedTab, let webView = tab.webView {
                // To Screenshot a tab that is hidden we must add the webView,
                // then wait enough time for the webview to render.
                view.insertSubview(webView, at: 0)
                // This is kind of a hacky fix for Bug 1476637 to prevent webpages from focusing the
                // touch-screen keyboard from the background even though they shouldn't be able to.
                webView.resignFirstResponder()
                
                // We need a better way of identifying when webviews are finished rendering
                // There are cases in which the page will still show a loading animation or nothing when the screenshot is being taken,
                // depending on internet connection
                // Issue created: https://github.com/mozilla-mobile/firefox-ios/issues/7003
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                    self.screenshotHelper.takeScreenshot(tab)
                    if webView.superview == self.view {
                        webView.removeFromSuperview()
                    }
                }
            }
        }
    }
}

extension BrowserViewController: ClipboardBarDisplayHandlerDelegate {
    func shouldDisplay(clipboardBar bar: ButtonToast) {
        show(toast: bar, duration: ClipboardBarToastUX.ToastDelay)
    }
}

extension BrowserViewController: SettingsDelegate {
    func settingsOpenURLInNewTab(_ url: URL) {
        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        self.openURLInNewTab(url, isPrivate: isPrivate, isPrivileged: false)
    }
}

extension BrowserViewController: PresentingModalViewControllerDelegate {
    func dismissPresentedModalViewController(_ modalViewController: UIViewController, animated: Bool) {
        self.dismiss(animated: animated, completion: nil)
    }
}

/**
 * History visit management.
 * TO DO: this should be expanded to track various visit types; see Bug 1166084.
 */
extension BrowserViewController {
    func ignoreNavigationInTab(_ tab: Tab, navigation: WKNavigation) {
        self.ignoredNavigation.insert(navigation)
    }

    func recordNavigationInTab(_ tab: Tab, navigation: WKNavigation, visitType: VisitType) {
        self.typedNavigation[navigation] = visitType
    }

    /**
     * Untrack and do the right thing.
     */
    func getVisitTypeForTab(_ tab: Tab, navigation: WKNavigation?) -> VisitType? {
        guard let navigation = navigation else {
            // See https://github.com/WebKit/webkit/blob/master/Source/WebKit2/UIProcess/Cocoa/NavigationState.mm#L390
            return VisitType.link
        }

        if let _ = self.ignoredNavigation.remove(navigation) {
            return nil
        }

        return self.typedNavigation.removeValue(forKey: navigation) ?? VisitType.link
    }
}

extension BrowserViewController: URLBarDelegate {
    func showTabTray() {
        Sentry.shared.clearBreadcrumbs()

        updateFindInPageVisibility(visible: false)

        let tabTrayController = TabTrayControllerV1(tabManager: tabManager, profile: profile, tabTrayDelegate: self)

        if let tab = tabManager.selectedTab {
            screenshotHelper.takeScreenshot(tab)
        }

        navigationController?.pushViewController(tabTrayController, animated: true)
        self.tabTrayController = tabTrayController
    }

    func urlBarDidPressReload(_ urlBar: URLBarView) {
        tabManager.selectedTab?.reload()
    }

    func urlBarDidPressPageOptions(_ urlBar: URLBarView, from button: UIButton) {
        guard let tab = tabManager.selectedTab, let urlString = tab.url?.absoluteString, !urlBar.inOverlayMode else { return }

        let actionMenuPresenter: (URL, Tab, UIView, UIPopoverArrowDirection) -> Void  = { (url, tab, view, _) in
            self.presentActivityViewController(url, tab: tab, sourceView: view, sourceRect: view.bounds, arrowDirection: .up)
        }

        let findInPageAction = {
            self.updateFindInPageVisibility(visible: true)
        }

        let successCallback: (String) -> Void = { (successMessage) in
            SimpleToast().showAlertWithText(successMessage, bottomContainer: self.webViewContainer)
        }

        let readerModeChanged: (Bool) -> Void = { (enabled) in
            self.readerModeChanged(enabled)
        }

        let deferredBookmarkStatus: Deferred<Maybe<Bool>> = fetchBookmarkStatus(for: urlString)
        let deferredPinnedTopSiteStatus: Deferred<Maybe<Bool>> = fetchPinnedTopSiteStatus(for: urlString)

        // Wait for both the bookmark status and the pinned status
        deferredBookmarkStatus.both(deferredPinnedTopSiteStatus).uponQueue(.main) {
            let isBookmarked = $0.successValue ?? false
            let isPinned = $1.successValue ?? false
            let isReaderModeEnabled = self.readerModeState == .unavailable ? nil : self.readerModeState == .active
            let pageActions = self.getTabActions(tab: tab, buttonView: button, presentShareMenu: actionMenuPresenter,
                                                 findInPage: findInPageAction, presentableVC: self, isBookmarked: isBookmarked,
                                                 isPinned: isPinned,
                                                 isReaderModeEnabled: isReaderModeEnabled, readerModeChanged: readerModeChanged,
                                                 success: successCallback)
            self.presentSheetWith(title: Strings.Menu.PageActionMenuTitle, actions: pageActions, on: self, from: button)
        }
    }

    func urlBarDidLongPressPageOptions(_ urlBar: URLBarView, from button: UIButton) {
        guard let tab = tabManager.selectedTab else { return }
        guard let url = tab.canonicalURL?.displayURL, self.presentedViewController == nil else {
            return
        }

        HapticFeedback.vibrate()
        presentActivityViewController(url, tab: tab, sourceView: button, sourceRect: button.bounds, arrowDirection: .up)
    }

    func urlBarDidTapShield(_ urlBar: URLBarView) {
        if let tab = self.tabManager.selectedTab {
            let trackingProtectionMenu = self.getTrackingSubMenu(for: tab, vcDelegate: self)
            guard !trackingProtectionMenu.isEmpty else { return }
            self.presentSheetWith(actions: trackingProtectionMenu, on: self, from: urlBar)
        }
    }

    func urlBarDidPressStop(_ urlBar: URLBarView) {
        tabManager.selectedTab?.stop()
    }

    func urlBarDidPressTabs(_ urlBar: URLBarView) {
        showTabTray()
    }

    func readerModeChanged(_ enabled: Bool) {
        if enabled {
            self.enableReaderMode()
        } else {
            self.disableReaderMode()
        }
    }

    func locationActionsForURLBar(_ urlBar: URLBarView) -> [AccessibleAction] {
        if UIPasteboard.general.string != nil {
            if UIPasteboard.general.isCopiedStringValidURL {
                return [pasteGoAction, pasteAction, copyAddressAction]
            }
            return [pasteAction, copyAddressAction]
        } else {
            return [copyAddressAction]
        }
    }

    func urlBarDisplayTextForURL(_ url: URL?) -> (String?, Bool) {
        // use the initial value for the URL so we can do proper pattern matching with search URLs
        var searchURL = self.tabManager.selectedTab?.url
        if let url = searchURL, InternalURL.isValid(url: url) {
            searchURL = url
        }
        if let query = profile.searchEngines.queryForSearchURL(searchURL as URL?) {
            return (query, true)
        } else {
            return (url?.absoluteString, false)
        }
    }

    func urlBarDidLongPressLocation(_ urlBar: URLBarView) {
        let urlActions = self.getLongPressLocationBarActions(with: urlBar)
        HapticFeedback.vibrate()
        self.presentSheetWith(actions: [urlActions], on: self, from: urlBar)
    }

    func urlBarDidPressScrollToTop(_ urlBar: URLBarView) {
        if let selectedTab = tabManager.selectedTab, homeViewController == nil {
            // Only scroll to top if we are not showing the home view controller
            selectedTab.webView?.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }

    func urlBarLocationAccessibilityActions(_ urlBar: URLBarView) -> [UIAccessibilityCustomAction]? {
        return locationActionsForURLBar(urlBar).map { $0.accessibilityCustomAction }
    }

    func urlBar(_ urlBar: URLBarView, didRestoreText text: String) {
        if text.isEmpty {
            self.showBlur(animation: false)
            hideSearchController()
        } else {
            showSearchController()
        }

        searchController?.searchQuery = text
    }

    func urlBar(_ urlBar: URLBarView, didEnterText text: String) {
        if text.isEmpty {
            self.showBlur(animation: false)
            hideSearchController()
        } else {
            showSearchController()
        }

        searchController?.searchQuery = text
    }

    func urlBar(_ urlBar: URLBarView, didSubmitText text: String, completion: String?) {
        guard let currentTab = tabManager.selectedTab else { return }

        if let fixupURL = URIFixup.getURL(text) {
            self.searchController?.reportSelection(
                query: text,
                url: fixupURL,
                completion: completion,
                isForgetMode: currentTab.isPrivate)
            // The user entered a URL, so use it.
            var query = text
            if let completion = completion {
                query = text.replaceFirstOccurrence(of: completion, with: "")
            }
            self.useCases.openLink.openLink(url: fixupURL, visitType: .typed, query: query)
            return
        }

        switch Features.Search.keyboardReturnKeyBehavior {
        case .dismiss: self.urlBar.closeKeyboard()
        case .search:
            if let url = self.profile.searchEngines.defaultEngine.searchURLForQuery(text) {
                self.finishEditingAndSubmit(url, visitType: .typed, forTab: currentTab)
            }
        }
    }

    fileprivate func submitSearchText(_ text: String, forTab tab: Tab) {
        let engine = profile.searchEngines.defaultEngine

        if let searchURL = engine.searchURLForQuery(text) {
            // We couldn't find a matching search keyword, so do a search query.
            finishEditingAndSubmit(searchURL, visitType: VisitType.typed, forTab: tab)
        } else {
            // We still don't have a valid URL, so something is broken. Give up.
            print("Error handling URL entry: \"\(text)\".")
            assertionFailure("Couldn't generate search URL: \(text)")
        }
    }

    func urlBarDidEnterOverlayMode(_ urlBar: URLBarView) {
        if let toast = clipboardBarDisplayHandler?.clipboardToast {
            toast.removeFromSuperview()
        }
        self.showBlur()
    }

    func urlBarDidLeaveOverlayMode(_ urlBar: URLBarView) {
        destroySearchController()
        updateInContentHomePanel(tabManager.selectedTab?.url as URL?)
        self.updateViewConstraints()
        self.hideBlur {
            if let home = self.homeViewController?.view {
                self.view.bringSubviewToFront(home)
                self.updateViewConstraints()
            }
        }
    }

    func urlBarDidBeginDragInteraction(_ urlBar: URLBarView) {
        dismissVisibleMenus()
    }
}

extension BrowserViewController: TabDelegate {

    func tab(_ tab: Tab, didCreateWebView webView: WKWebView) {
        webView.frame = webViewContainer.frame
        // Observers that live as long as the tab. Make sure these are all cleared in willDeleteWebView below!
        KVOs.forEach { webView.addObserver(self, forKeyPath: $0.rawValue, options: .new, context: nil) }
        webView.scrollView.addObserver(self.scrollController, forKeyPath: KVOConstants.contentSize.rawValue, options: .new, context: nil)
        webView.uiDelegate = self

        let formPostHelper = FormPostHelper(tab: tab)
        tab.addContentScript(formPostHelper, name: FormPostHelper.name())

        let readerMode = ReaderMode(tab: tab)
        readerMode.delegate = self
        tab.addContentScript(readerMode, name: ReaderMode.name())

        let contextMenuHelper = ContextMenuHelper(tab: tab)
        contextMenuHelper.delegate = self
        tab.addContentScript(contextMenuHelper, name: ContextMenuHelper.name())

        let errorHelper = ErrorPageHelper(certStore: profile.certStore)
        tab.addContentScript(errorHelper, name: ErrorPageHelper.name())

        let sessionRestoreHelper = SessionRestoreHelper(tab: tab)
        sessionRestoreHelper.delegate = self
        tab.addContentScript(sessionRestoreHelper, name: SessionRestoreHelper.name())

        let findInPageHelper = FindInPageHelper(tab: tab)
        findInPageHelper.delegate = self
        tab.addContentScript(findInPageHelper, name: FindInPageHelper.name())

        let downloadContentScript = DownloadContentScript(tab: tab)
        tab.addContentScript(downloadContentScript, name: DownloadContentScript.name())

        let printHelper = PrintHelper(tab: tab)
        tab.addContentScript(printHelper, name: PrintHelper.name())

        // XXX: Bug 1390200 - Disable NSUserActivity/CoreSpotlight temporarily
        // let spotlightHelper = SpotlightHelper(tab: tab)
        // tab.addHelper(spotlightHelper, name: SpotlightHelper.name())

        tab.addContentScript(LocalRequestHelper(), name: LocalRequestHelper.name())

        let trampoline = TrampolineTabContentScript(tab: tab)
        trampoline.delegate = self
        tab.addContentScript(trampoline, name: TrampolineTabContentScript.name())

        let blocker = FirefoxTabContentBlocker(tab: tab, prefs: profile.prefs)
        tab.contentBlocker = blocker
        tab.addContentScript(blocker, name: FirefoxTabContentBlocker.name())

        tab.addContentScript(FocusHelper(tab: tab), name: FocusHelper.name())
    }

    func tab(_ tab: Tab, willDeleteWebView webView: WKWebView) {
        tab.cancelQueuedAlerts()
        KVOs.forEach { webView.removeObserver(self, forKeyPath: $0.rawValue) }
        webView.scrollView.removeObserver(self.scrollController, forKeyPath: KVOConstants.contentSize.rawValue)
        webView.uiDelegate = nil
        webView.scrollView.delegate = nil
        webView.removeFromSuperview()
        tab.refreshControl?.removeFromSuperview()
    }

    fileprivate func findSnackbar(_ barToFind: SnackBar) -> Int? {
        let bars = alertStackView.arrangedSubviews
        for (index, bar) in bars.enumerated() where bar === barToFind {
            return index
        }
        return nil
    }

    func showBar(_ bar: SnackBar, animated: Bool) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.alertStackView.insertArrangedSubview(bar, at: 0)
            self.view.layoutIfNeeded()
        })
    }

    func removeBar(_ bar: SnackBar, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            bar.removeFromSuperview()
        })
    }

    func removeAllBars() {
        alertStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func tab(_ tab: Tab, didAddSnackbar bar: SnackBar) {
        // If the Tab that had a SnackBar added to it is not currently
        // the selected Tab, do nothing right now. If/when the Tab gets
        // selected later, we will show the SnackBar at that time.
        guard tab == tabManager.selectedTab else {
            return
        }

        showBar(bar, animated: true)
    }

    func tab(_ tab: Tab, didRemoveSnackbar bar: SnackBar) {
        removeBar(bar, animated: true)
    }

    func tab(_ tab: Tab, didSelectFindInPageForSelection selection: String) {
        updateFindInPageVisibility(visible: true)
        findInPageBar?.text = selection
    }

    func tab(_ tab: Tab, didSelectSearchWithFirefoxForSelection selection: String) {
        self.openBlankNewTab(focusLocationField: true, isPrivate: tab.isPrivate, searchFor: selection)
    }
}

extension BrowserViewController: HomePanelDelegate {
    func homePanel(didSelectURL url: URL, visitType: VisitType) {
        self.openURL(url: url, visitType: visitType)
    }

    func homePanelDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool) {
        self.openURLInNewTab(url: url, isPrivate: isPrivate)
    }

    func homePanel(wantsToEdit bookmark: BookmarkNode) {
        let viewController = BookmarkDetailViewController(profile: self.profile, bookmarkNode: bookmark)
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        if #available(iOS 13.0, *) {
            navigationController.modalPresentationStyle = UIDevice.current.isPhone ? .automatic : .formSheet
            navigationController.presentationController?.delegate = self
        } else {
            navigationController.modalPresentationStyle = UIDevice.current.isPhone ? .fullScreen : .formSheet
        }
        self.present(navigationController, animated: true)
    }
}

extension BrowserViewController: BookmarkDetailViewControllerDelegate {

    func bookmardDetailViewDidCancel() {
        self.setPhoneWindowBackground(color: Theme.browser.background, animationDuration: 1.0)
    }

    func bookmardDetailViewDidSave() {
        self.setPhoneWindowBackground(color: Theme.browser.background, animationDuration: 1.0)
        self.homeViewController?.refreshBookmarks()
    }

}

extension BrowserViewController: TabManagerDelegate {
    func tabManager(_ tabManager: TabManager, didSelectedTabChange selected: Tab?, previous: Tab?, isRestoring: Bool) {
        // Reset the scroll position for the ActivityStreamPanel so that it
        // is always presented scrolled to the top when switching tabs.
        if !isRestoring, selected != previous,
            let activityStreamPanel = homeViewController {
            activityStreamPanel.scrollToTop()
        }
        previous?.refreshControl?.removeFromSuperview()

        // Remove the old accessibilityLabel. Since this webview shouldn't be visible, it doesn't need it
        // and having multiple views with the same label confuses tests.
        if let wv = previous?.webView {
            wv.endEditing(true)
            wv.accessibilityLabel = nil
            wv.accessibilityElementsHidden = true
            wv.accessibilityIdentifier = nil
            wv.removeFromSuperview()
        }

        if let tab = selected, let webView = tab.webView {
            updateURLBarDisplayURL(tab)

            if previous == nil || tab.isPrivate != previous?.isPrivate {
                applyTheme()

                let ui: [PrivateModeUI?] = [toolbar, topTabsViewController, urlBar]
                ui.forEach { $0?.applyUIMode(isPrivate: tab.isPrivate) }
            }

            readerModeCache = tab.isPrivate ? MemoryReaderModeCache.sharedInstance : DiskReaderModeCache.sharedInstance
            if let privateModeButton = topTabsViewController?.privateModeButton, previous != nil && previous?.isPrivate != tab.isPrivate {
                privateModeButton.setSelected(tab.isPrivate, animated: true)
            }
            ReaderModeHandlers.readerModeCache = readerModeCache

            scrollController.tab = tab
            webViewContainer.addSubview(webView)
            webView.snp.makeConstraints { make in
                make.left.right.top.bottom.equalTo(self.webViewContainer)
            }

            if let refreshControl = selected?.refreshControl {
                self.view.addSubview(refreshControl)
                refreshControl.snp.removeConstraints()
                refreshControl.snp.makeConstraints({ (make) in
                    make.topMargin.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(self.notchAreaCover.frame.size.height)
                })
            }

            // This is a terrible workaround for a bad iOS 12 bug where PDF
            // content disappears any time the view controller changes (i.e.
            // the user taps on the tabs tray). It seems the only way to get
            // the PDF to redraw is to either reload it or revisit it from
            // back/forward list. To try and avoid hitting the network again
            // for the same PDF, we revisit the current back/forward item and
            // restore the previous scrollview zoom scale and content offset
            // after a short 100ms delay. *facepalm*
            //
            // https://bugzilla.mozilla.org/show_bug.cgi?id=1516524
            if #available(iOS 12.0, *) {
                if tab.mimeType == MIMEType.PDF {
                    let previousZoomScale = webView.scrollView.zoomScale
                    let previousContentOffset = webView.scrollView.contentOffset

                    if let currentItem = webView.backForwardList.currentItem {
                        webView.go(to: currentItem)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                        webView.scrollView.setZoomScale(previousZoomScale, animated: false)
                        webView.scrollView.setContentOffset(previousContentOffset, animated: false)
                    }
                }
            }

            webView.accessibilityLabel = Strings.Accessibility.WebContent
            webView.accessibilityIdentifier = "contentView"
            webView.accessibilityElementsHidden = false

            if webView.url == nil {
                // The web view can go gray if it was zombified due to memory pressure.
                // When this happens, the URL is nil, so try restoring the page upon selection.
                tab.reload()
            }
        }

        updateTabCountUsingTabManager(tabManager)

        removeAllBars()
        if let bars = selected?.bars {
            for bar in bars {
                showBar(bar, animated: true)
            }
        }

        updateFindInPageVisibility(visible: false, tab: previous)

        navigationToolbar.updateReloadStatus(selected?.loading ?? false)
        navigationToolbar.updateBackStatus(selected?.canGoBack ?? false)
        navigationToolbar.updateForwardStatus(selected?.canGoForward ?? false)
        if let url = selected?.webView?.url, !InternalURL.isValid(url: url) {
            self.urlBar.updateProgressBar(Float(selected?.estimatedProgress ?? 0))
        }

        if let readerMode = selected?.getContentScript(name: ReaderMode.name()) as? ReaderMode {
            self.readerModeState = readerMode.state
            if readerMode.state == .active {
                showReaderModeBar(animated: false)
            } else {
                hideReaderModeBar(animated: false)
            }
        } else {
            self.readerModeState = .unavailable
        }

        if topTabsVisible {
            topTabsDidChangeTab()
        }

        updateInContentHomePanel(selected?.url as URL?)
    }

    func tabManager(_ tabManager: TabManager, didAddTab tab: Tab, isRestoring: Bool) {
        // If we are restoring tabs then we update the count once at the end
        if !isRestoring {
            updateTabCountUsingTabManager(tabManager)
        }
        tab.tabDelegate = self
    }

    func tabManager(_ tabManager: TabManager, didRemoveTab tab: Tab, isRestoring: Bool) {
        if let url = tab.url, !(InternalURL(url)?.isAboutURL ?? false), !tab.isPrivate {
            profile.recentlyClosedTabs.addTab(url as URL, title: tab.title, faviconURL: tab.displayFavicon?.url)
        }
        if (tab.isPrivate && self.tabManager.privateTabs.isEmpty) || (!tab.isPrivate && self.tabManager.normalTabs.isEmpty) {
            self.homeViewController?.switchViewToDefaultSegment()
        }
        updateTabCountUsingTabManager(tabManager)
    }

    func tabManager(_ tabManager: TabManager, didUpdateTab tab: Tab, isRestoring: Bool) {

    }

    func tabManagerDidAddTabs(_ tabManager: TabManager) {
        updateTabCountUsingTabManager(tabManager)
    }

    func tabManagerDidRestoreTabs(_ tabManager: TabManager) {
        updateTabCountUsingTabManager(tabManager)
    }

    func show(toast: Toast, afterWaiting delay: DispatchTimeInterval = SimpleToastUX.ToastDelayBefore, duration: DispatchTimeInterval? = SimpleToastUX.ToastDismissAfter) {
        if let downloadToast = toast as? DownloadToast {
            self.downloadToast = downloadToast
        }

        // If BVC isnt visible hold on to this toast until viewDidAppear
        if self.view.window == nil {
            self.pendingToast = toast
            return
        }

        toast.showToast(viewController: self, delay: delay, duration: duration, makeConstraints: { make in
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.webViewContainer?.safeArea.bottom ?? 0)
        })
    }

    func tabManagerDidRemoveAllTabs(_ tabManager: TabManager, toast: ButtonToast?) {
        guard let toast = toast, !(tabTrayController?.tabDisplayManager.isPrivate  ?? false) else {
            return
        }
        show(toast: toast, afterWaiting: ButtonToastUX.ToastDelay)
    }

    func updateTabCountUsingTabManager(_ tabManager: TabManager, animated: Bool = true) {
        if let selectedTab = tabManager.selectedTab {
            let count = selectedTab.isPrivate ? tabManager.privateTabs.count : tabManager.normalTabs.count
            toolbar?.updateTabCount(count, animated: animated)
            urlBar.updateTabCount(count, animated: !urlBar.inOverlayMode)
            self.toolbar?.searchBadge(visible: !selectedTab.isNewTabPage)
            self.urlBar.searchBadge(visible: !selectedTab.isNewTabPage)
            topTabsViewController?.updateTabCount(count, animated: animated)
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension BrowserViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        displayedPopoverController = nil
        updateDisplayedPopoverProperties = nil
    }
}

extension BrowserViewController: OnboardingViewControllerDelegate {

    func onboardingViewControllerDidFinish(_ onboardingViewController: UIViewController) {
        let shouldPresentPrivacyStatement = self.profile.prefs.intForKey(PrefsKeys.IntroSeen) == nil
        self.profile.prefs.setInt(1, forKey: PrefsKeys.IntroSeen)
        onboardingViewController.dismiss(animated: true) {
            if self.navigationController?.viewControllers.count ?? 0 > 1 {
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
            if shouldPresentPrivacyStatement && DataAndPrivacy.isEnabled {
                self.presentDataAndPrivacyViewController()
            }
        }
    }

    func presentOnboarding(_ force: Bool = false, animated: Bool = true) {
        if Onboarding.isEnabled && (force || profile.prefs.intForKey(PrefsKeys.IntroSeen) == nil) {
            guard let onboardingViewController = Onboarding.presentingViewController(delegate: self) else { return }
            // On iPad we present it modally in a controller
            if topTabsVisible {
                onboardingViewController.preferredContentSize = CGSize(width: BrowserViewControllerUX.OnboardingWidth, height: BrowserViewControllerUX.OnboardingHeight)
                onboardingViewController.modalPresentationStyle = UIDevice.current.isPhone ? .fullScreen : .formSheet
            } else {
                onboardingViewController.modalPresentationStyle = .fullScreen
            }
            present(onboardingViewController, animated: animated) {
                // On first run (and forced) open up the homepage in the background.
                if let homePageURL = NewTabPage.topSites.url, let tab = self.tabManager.selectedTab, DeviceInfo.hasConnectivity() {
                    tab.loadRequest(URLRequest(url: homePageURL))
                }
            }

            return
        }
        return
    }

}

extension BrowserViewController: DataAndPrivacyViewControllerDelegate {

    func dataAndPrivacyViewControllerDidClose() {
        self.setPhoneWindowBackground(color: Theme.browser.background, animationDuration: 1.0)
    }

}

extension BrowserViewController: ContextMenuHelperDelegate {
    func contextMenuHelper(_ contextMenuHelper: ContextMenuHelper, didLongPressElements elements: ContextMenuHelper.Elements, gestureRecognizer: UIGestureRecognizer) {
        // locationInView can return (0, 0) when the long press is triggered in an invalid page
        // state (e.g., long pressing a link before the document changes, then releasing after a
        // different page loads).
        let touchPoint = gestureRecognizer.location(in: view)
        guard touchPoint != CGPoint.zero else { return }

        let touchSize = CGSize(width: 0, height: 16)

        let actionSheetController = AlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var dialogTitle: String?

        if let url = elements.link, let currentTab = tabManager.selectedTab {
            dialogTitle = url.absoluteString
            let isPrivate = currentTab.isPrivate
            screenshotHelper.takeDelayedScreenshot(currentTab)

            let addTab = { (rURL: URL, isPrivate: Bool) in
                let tab = self.tabManager.addTab(URLRequest(url: rURL as URL), afterTab: currentTab, isPrivate: isPrivate)

                self.tabManager.selectTab(tab)
            }

            if !isPrivate {
                let openNewTabAction =  UIAlertAction(title: Strings.ContextMenu.OpenInNewTab, style: .default) { _ in
                    addTab(url, false)
                }
                actionSheetController.addAction(openNewTabAction, accessibilityIdentifier: "linkContextMenu.openInNewTab")
            }

            let openNewPrivateTabAction =  UIAlertAction(title: Strings.ForgetMode.ContextMenu.OpenInNewPrivateTab, style: .default) { _ in
                addTab(url, true)
            }
            actionSheetController.addAction(openNewPrivateTabAction, accessibilityIdentifier: "linkContextMenu.openInNewPrivateTab")

            let bookmarkAction = UIAlertAction(title: Strings.ContextMenu.BookmarkLink, style: .default) { _ in
                self.addBookmark(url: url.absoluteString, title: elements.title)
                SimpleToast().showAlertWithText(Strings.Menu.AddBookmarkConfirmMessage, bottomContainer: self.webViewContainer)
            }
            actionSheetController.addAction(bookmarkAction, accessibilityIdentifier: "linkContextMenu.bookmarkLink")

            let downloadAction = UIAlertAction(title: Strings.ContextMenu.DownloadLink, style: .default) { _ in
                // This checks if download is a blob, if yes, begin blob download process
                if !DownloadContentScript.requestBlobDownload(url: url, tab: currentTab) {
                    //if not a blob, set pendingDownloadWebView and load the request in the webview, which will trigger the WKWebView navigationResponse delegate function and eventually downloadHelper.open()
                    self.pendingDownloadWebView = currentTab.webView
                    let request = URLRequest(url: url)
                    currentTab.webView?.load(request)
                }
            }
            actionSheetController.addAction(downloadAction, accessibilityIdentifier: "linkContextMenu.download")

            let copyAction = UIAlertAction(title: Strings.ContextMenu.CopyLink, style: .default) { _ in
                UIPasteboard.general.url = url as URL
            }
            actionSheetController.addAction(copyAction, accessibilityIdentifier: "linkContextMenu.copyLink")

            let shareAction = UIAlertAction(title: Strings.ContextMenu.ShareLink, style: .default) { _ in
                self.presentActivityViewController(url as URL, sourceView: self.view, sourceRect: CGRect(origin: touchPoint, size: touchSize), arrowDirection: .any)
            }
            actionSheetController.addAction(shareAction, accessibilityIdentifier: "linkContextMenu.share")
        }

        if let url = elements.image {
            if dialogTitle == nil {
                dialogTitle = elements.title ?? url.absoluteString
            }

            let photoAuthorizeStatus = PHPhotoLibrary.authorizationStatus()
            let saveImageAction = UIAlertAction(title: Strings.ContextMenu.SaveImage, style: .default) { _ in
                let handlePhotoLibraryAuthorized = {
                    DispatchQueue.main.async {
                        self.getImageData(url) { data in
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
                            })
                        }
                    }
                }

                let handlePhotoLibraryDenied = {
                    DispatchQueue.main.async {
                        let accessDenied = UIAlertController(title: Strings.PhotoLibrary.AppWouldLikeAccessTitle, message: Strings.PhotoLibrary.AppWouldLikeAccessMessage, preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: Strings.General.CancelString, style: .default, handler: nil)
                        accessDenied.addAction(dismissAction)
                        let settingsAction = UIAlertAction(title: Strings.General.OpenSettingsString, style: .default ) { _ in
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
                        }
                        accessDenied.addAction(settingsAction)
                        self.present(accessDenied, animated: true, completion: nil)
                    }
                }

                if photoAuthorizeStatus == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({ status in
                        guard status == .authorized else {
                            handlePhotoLibraryDenied()
                            return
                        }

                        handlePhotoLibraryAuthorized()
                    })
                } else if photoAuthorizeStatus == .authorized {
                    handlePhotoLibraryAuthorized()
                } else {
                    handlePhotoLibraryDenied()
                }
            }
            actionSheetController.addAction(saveImageAction, accessibilityIdentifier: "linkContextMenu.saveImage")

            let copyAction = UIAlertAction(title: Strings.ContextMenu.CopyImage, style: .default) { _ in
                // put the actual image on the clipboard
                // do this asynchronously just in case we're in a low bandwidth situation
                let pasteboard = UIPasteboard.general
                pasteboard.url = url as URL
                let changeCount = pasteboard.changeCount
                let application = UIApplication.shared
                var taskId: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
                taskId = application.beginBackgroundTask(expirationHandler: {
                    application.endBackgroundTask(taskId)
                })

                makeURLSession(userAgent: UserAgent.fxaUserAgent, configuration: URLSessionConfiguration.default).dataTask(with: url) { (data, response, error) in
                    guard let _ = validatedHTTPResponse(response, statusCode: 200..<300) else {
                        application.endBackgroundTask(taskId)
                        return
                    }

                    // Only set the image onto the pasteboard if the pasteboard hasn't changed since
                    // fetching the image; otherwise, in low-bandwidth situations,
                    // we might be overwriting something that the user has subsequently added.
                    if changeCount == pasteboard.changeCount, let imageData = data, error == nil {
                        pasteboard.addImageWithData(imageData, forURL: url)
                    }

                    application.endBackgroundTask(taskId)
                }.resume()

            }
            actionSheetController.addAction(copyAction, accessibilityIdentifier: "linkContextMenu.copyImage")

            let copyImageLinkAction = UIAlertAction(title: Strings.ContextMenu.CopyImageLink, style: .default) { _ in
                UIPasteboard.general.url = url as URL
            }
            actionSheetController.addAction(copyImageLinkAction, accessibilityIdentifier: "linkContextMenu.copyImageLink")
        }

        let setupPopover = { [unowned self] in
            // If we're showing an arrow popup, set the anchor to the long press location.
            if let popoverPresentationController = actionSheetController.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = CGRect(origin: touchPoint, size: touchSize)
                popoverPresentationController.permittedArrowDirections = .any
                popoverPresentationController.delegate = self
            }
        }
        setupPopover()

        if actionSheetController.popoverPresentationController != nil {
            displayedPopoverController = actionSheetController
            updateDisplayedPopoverProperties = setupPopover
        }

        if let dialogTitle = dialogTitle {
            if let _ = dialogTitle.asURL {
                actionSheetController.title = dialogTitle.ellipsize(maxLength: ActionSheetTitleMaxLength)
            } else {
                actionSheetController.title = dialogTitle
            }
        }

        let cancelAction = UIAlertAction(title: Strings.General.CancelString, style: UIAlertAction.Style.cancel, handler: nil)
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }

    fileprivate func getImageData(_ url: URL, success: @escaping (Data) -> Void) {
        makeURLSession(userAgent: UserAgent.fxaUserAgent, configuration: URLSessionConfiguration.default).dataTask(with: url) { (data, response, error) in
            if let _ = validatedHTTPResponse(response, statusCode: 200..<300), let data = data {
                success(data)
            }
        }.resume()
    }

    func contextMenuHelper(_ contextMenuHelper: ContextMenuHelper, didCancelGestureRecognizer: UIGestureRecognizer) {
        displayedPopoverController?.dismiss(animated: true) {
            self.displayedPopoverController = nil
        }
    }
}

extension BrowserViewController {
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
        }
    }
}


extension BrowserViewController: KeyboardHelperDelegate {
    func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState) {
        keyboardState = state
        updateViewConstraints()

        UIView.animate(withDuration: state.animationDuration) {
            UIView.setAnimationCurve(state.animationCurve)
            self.alertStackView.layoutIfNeeded()
        }
    }

    func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState) {

    }

    func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState) {
        keyboardState = nil
        updateViewConstraints()

        UIView.animate(withDuration: state.animationDuration) {
            UIView.setAnimationCurve(state.animationCurve)
            self.alertStackView.layoutIfNeeded()
        }
    }
}

extension BrowserViewController: SessionRestoreHelperDelegate {
    func sessionRestoreHelper(_ helper: SessionRestoreHelper, didRestoreSessionForTab tab: Tab) {
        tab.restoring = false

        if let tab = tabManager.selectedTab, tab.webView === tab.webView {
            updateUIForReaderHomeStateForTab(tab)
        }

        clipboardBarDisplayHandler?.didRestoreSession()
    }
}

extension BrowserViewController: TabTrayDelegate {
    // This function animates and resets the tab chrome transforms when
    // the tab tray dismisses.
    func tabTrayDidDismiss(_ tabTray: TabTrayControllerV1) {
        resetBrowserChrome()
    }

    func tabTrayDidAddTab(_ tabTray: TabTrayControllerV1, tab: Tab) {}

    func tabTrayDidAddBookmark(_ tab: Tab) {
        guard let url = tab.url?.absoluteString, !url.isEmpty else { return }
        let tabState = tab.tabState
        addBookmark(url: url, title: tabState.title, favicon: tabState.favicon)
    }

    func tabTrayRequestsPresentationOf(_ viewController: UIViewController) {
        self.present(viewController, animated: false, completion: nil)
    }
}

// MARK: Browser Chrome Theming
extension BrowserViewController: Themeable {
    func applyTheme() {
        guard self.isViewLoaded else { return }
        let ui: [Themeable?] = [urlBar, toolbar, readerModeBar, topTabsViewController, tabTrayController, homeViewController, searchController]
        ui.forEach { $0?.applyTheme() }
        setNeedsStatusBarAppearanceUpdate()

        (presentedViewController as? Themeable)?.applyTheme()

        // Update the `background-color` of any blank webviews.
        let webViews = tabManager.tabs.compactMap({ $0.webView as? TabWebView })
        webViews.forEach({ $0.applyTheme() })

        self.notchAreaCover.backgroundColor = .clear
        self.overlayBackground.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        tabManager.tabs.forEach { $0.applyTheme() }

        guard let contentScript = self.tabManager.selectedTab?.getContentScript(name: ReaderMode.name()) else { return }
        appyThemeForPreferences(profile.prefs, contentScript: contentScript)
    }
}

extension BrowserViewController: JSPromptAlertControllerDelegate {
    func promptAlertControllerDidDismiss(_ alertController: JSPromptAlertController) {
        showQueuedAlertIfAvailable()
    }
}

extension BrowserViewController: TopTabsDelegate {
    func topTabsDidPressTabs() {
        urlBar.leaveOverlayMode(didCancel: true)
        self.urlBarDidPressTabs(urlBar)
    }

    func topTabsDidPressNewTab(_ isPrivate: Bool) {
        openBlankNewTab(focusLocationField: false, isPrivate: isPrivate)
    }

    func topTabsDidTogglePrivateMode() {
        guard let _ = tabManager.selectedTab else {
            return
        }
        urlBar.leaveOverlayMode()
    }

    func topTabsDidChangeTab() {
        urlBar.leaveOverlayMode(didCancel: true)
    }
}

extension BrowserViewController: InstructionsViewControllerDelegate {
    func instructionsViewControllerDidClose(_ instructionsViewController: InstructionsViewController) {
        self.popToBVC()
    }
}

// MARK: - reopen last closed tab

extension BrowserViewController {
    func homePanelDidRequestToRestoreClosedTab(_ motion: UIEvent.EventSubtype) {
        guard motion == .motionShake, !topTabsVisible, !urlBar.inOverlayMode,
            let lastClosedURL = profile.recentlyClosedTabs.tabs.first?.url,
            let selectedTab = tabManager.selectedTab else { return }

        let alertTitleText = Strings.HomePanel.ReopenAlert.Title
        let reopenButtonText = Strings.HomePanel.ReopenAlert.ActionsReopen
        let cancelButtonText = Strings.HomePanel.ReopenAlert.ActionsCancel

        func reopenLastTab(_ action: UIAlertAction) {
            let request = PrivilegedRequest(url: lastClosedURL) as URLRequest
            let closedTab = tabManager.addTab(request, afterTab: selectedTab, isPrivate: false)
            tabManager.selectTab(closedTab)
        }

        let alert = AlertController(title: alertTitleText, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: reopenButtonText, style: .default, handler: reopenLastTab), accessibilityIdentifier: "BrowserViewController.ReopenLastTabAlert.ReopenButton")
        alert.addAction(UIAlertAction(title: cancelButtonText, style: .cancel, handler: nil), accessibilityIdentifier: "BrowserViewController.ReopenLastTabAlert.CancelButton")

        self.present(alert, animated: true, completion: nil)
    }
}

extension BrowserViewController {
    public static func foregroundBVC() -> BrowserViewController {
        return (UIApplication.shared.delegate as! AppDelegate).browserViewController
    }
}

extension BrowserViewController: UIAdaptivePresentationControllerDelegate {
    // Returning None here makes sure that the Popover is actually presented as a Popover and
    // not as a full-screen modal, which is the default on compact device classes.
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        if #available(iOS 13.0, *) {
            transitionCoordinator?.animate(alongsideTransition: { (_) in
                self.setPhoneWindowBackground(color: .black)
            })
        }
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.setPhoneWindowBackground(color: Theme.browser.background, animationDuration: 0.05)
    }

}
