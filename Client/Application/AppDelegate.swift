/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Storage
import AVFoundation
import XCGLogger
import MessageUI
import SDWebImage
import LocalAuthentication
import CoreSpotlight
import UserNotifications
import StoreKit
#if FB_SONARKIT_ENABLED
import FlipperKit
#endif

private let log = Logger.browserLogger

let LatestAppVersionProfileKey = "latestAppVersion"
let AllowThirdPartyKeyboardsKey = "settings.allowThirdPartyKeyboards"
private let InitialPingSentKey = "initialPingSent"

class AppDelegate: UIResponder, UIApplicationDelegate, UIViewControllerRestoration {
    public static func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        return nil
    }

    var window: UIWindow?
    var browserViewController: BrowserViewController!
    var rootViewController: UIViewController!
    weak var profile: Profile?
    var tabManager: TabManager!
    var applicationCleanlyBackgrounded = true
    var shutdownWebServer: DispatchSourceTimer?
    var interceptorFeature: InterceptorFeature!
    var humanWebFeature: HumanWebFeature!
    var insightsFeature: InsightsFeature!
    var useCases: UseCases!
    var afterStartupAction: (() -> Void)?

    weak var application: UIApplication?
    var launchOptions: [AnyHashable: Any]?

    let appVersion = AppInfo.appVersion

    var receivedURLs = [URL]()

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //
        // Determine if the application cleanly exited last time it was used. We default to true in
        // case we have never done this before. Then check if the "ApplicationCleanlyBackgrounded" user
        // default exists and whether was properly set to true on app exit.
        //
        // Then we always set the user default to false. It will be set to true when we the application
        // is backgrounded.
        //

        self.applicationCleanlyBackgrounded = true

        let defaults = UserDefaults()
        if defaults.object(forKey: "ApplicationCleanlyBackgrounded") != nil {
            self.applicationCleanlyBackgrounded = defaults.bool(forKey: "ApplicationCleanlyBackgrounded")
        }
        defaults.set(false, forKey: "ApplicationCleanlyBackgrounded")

        // Hold references to willFinishLaunching parameters for delayed app launch
        self.application = application
        self.launchOptions = launchOptions

        self.window = UIWindow(frame: UIScreen.main.bounds)

        self.window!.backgroundColor = Theme.browser.background

        // If the 'Save logs to Files app on next launch' toggle
        // is turned on in the Settings app, copy over old logs.
        if DebugSettingsBundleOptions.saveLogsToDocuments {
            Logger.copyPreviousLogsToDocuments()
        }

        return startApplication(application, withLaunchOptions: launchOptions)
    }

    func startApplication(_ application: UIApplication, withLaunchOptions launchOptions: [AnyHashable: Any]?) -> Bool {
        log.info("startApplication begin")

        // Need to get "settings.sendUsageData" this way so that Sentry can be initialized
        // before getting the Profile.
        let sendUsageData = Features.Telemetry.isEnabled && NSUserDefaultsPrefs(prefix: "profile").boolForKey(AppConstants.PrefSendUsageData) ?? true
        Sentry.shared.setup(sendUsageData: sendUsageData)

        // Set the Firefox UA for browsing.
        setUserAgent()

        // Start the keyboard helper to monitor and cache keyboard state.
        KeyboardHelper.defaultHelper.startObserving()

        DynamicFontHelper.defaultHelper.startObserving()

        MenuHelper.defaultHelper.setItems()

        let logDate = Date()
        // Create a new sync log file on cold app launch. Note that this doesn't roll old logs.
        Logger.syncLogger.newLogWithDate(logDate)

        Logger.browserLogger.newLogWithDate(logDate)

        let profile = getProfile(application)

        // Set up a web server that serves us static content. Do this early so that it is ready when the UI is presented.
        setUpWebServer(profile)

        let imageStore = DiskImageStore(files: profile.files, namespace: "TabManagerScreenshots", quality: UIConstants.ScreenshotQuality)

        // Temporary fix for Bug 1390871 - NSInvalidArgumentException: -[WKContentView menuHelperFindInPage]: unrecognized selector
        if let clazz = NSClassFromString("WKCont" + "ent" + "View"), let swizzledMethod = class_getInstanceMethod(TabWebViewMenuHelper.self, #selector(TabWebViewMenuHelper.swizzledMenuHelperFindInPage)) {
            class_addMethod(clazz, MenuHelper.SelectorFindInPage, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        }

        self.tabManager = TabManager(profile: profile, imageStore: imageStore)

        // Add restoration class, the factory that will return the ViewController we
        // will restore with.

        setupRootViewController()

        SystemUtils.onFirstRun()

        log.info("startApplication end")
        return true
    }

    private func setupRootViewController() {
        browserViewController = BrowserViewController(profile: self.profile!, tabManager: self.tabManager)
        browserViewController.edgesForExtendedLayout = []

        browserViewController.restorationIdentifier = NSStringFromClass(BrowserViewController.self)
        browserViewController.restorationClass = AppDelegate.self

        self.useCases = UseCases(tabManager: self.tabManager, profile: self.profile!, viewController: self.browserViewController)
        self.interceptorFeature = InterceptorFeature(tabManager: self.tabManager, ui: self.browserViewController, useCases: self.useCases)
        if Features.HumanWeb.isEnabled {
            self.humanWebFeature = HumanWebFeature(tabManager: self.tabManager)
        }
        self.insightsFeature = InsightsFeature(tabManager: self.tabManager)

        self.browserViewController.useCases = self.useCases

        let navigationController = UINavigationController(rootViewController: browserViewController)
        navigationController.delegate = self
        navigationController.isNavigationBarHidden = true
        navigationController.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        rootViewController = navigationController

        self.window!.rootViewController = rootViewController
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // We have only five seconds here, so let's hope this doesn't take too long.
        profile?._shutdown()

        // Allow deinitializers to close our database connections.
        profile = nil
        tabManager = nil
        browserViewController = nil
        rootViewController = nil
    }

    /**
     * We maintain a weak reference to the profile so that we can pause timed
     * syncs when we're backgrounded.
     *
     * The long-lasting ref to the profile lives in BrowserViewController,
     * which we set in application:willFinishLaunchingWithOptions:.
     *
     * If that ever disappears, we won't be able to grab the profile to stop
     * syncing... but in that case the profile's deinit will take care of things.
     */
    func getProfile(_ application: UIApplication) -> Profile {
        if let profile = self.profile {
            return profile
        }
        let p = BrowserProfile(localName: "profile")
        self.profile = p
        return p
    }

    #if FB_SONARKIT_ENABLED
    private func setupFlipper(_ application: UIApplication) {
        let client = FlipperClient.shared()
        let layoutDescriptorMapper = SKDescriptorMapper(defaults: ())
        client?.add(FlipperKitLayoutPlugin(rootNode: application, with: layoutDescriptorMapper!))
        client?.add(FlipperKitNetworkPlugin(networkAdapter: SKIOSNetworkAdapter()))
        client?.add(FKUserDefaultsPlugin(suiteName: AppInfo.sharedContainerIdentifier))
        client?.add(FlipperKitReactPlugin())
        client?.start()
    }
    #endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if FB_SONARKIT_ENABLED
        self.setupFlipper(application)
        #endif
        // Override point for customization after application launch.
        var shouldPerformAdditionalDelegateHandling = true
        self.askForReview()
        UNUserNotificationCenter.current().delegate = self
        SentTabAction.registerActions()
        UIScrollView.doBadSwizzleStuff()

        window!.makeKeyAndVisible()

        // Now roll logs.
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            Logger.syncLogger.deleteOldLogsDownToSizeLimit()
            Logger.browserLogger.deleteOldLogsDownToSizeLimit()
        }

        QuickActions.sharedInstance.filterOutUnsupportedShortcutItems(application: application)
        // If a shortcut was launched, display its information and take the appropriate action
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {

            QuickActions.sharedInstance.launchedShortcutItem = shortcutItem
            // This will block "performActionForShortcutItem:completionHandler" from being called.
            shouldPerformAdditionalDelegateHandling = false
        }

        // Force the ToolbarTextField in LTR mode - without this change the UITextField's clear
        // button will be in the incorrect position and overlap with the input text. Not clear if
        // that is an iOS bug or not.
        AutocompleteTextField.appearance().semanticContentAttribute = .forceLeftToRight

        return shouldPerformAdditionalDelegateHandling
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard let routerpath = NavigationPath(url: url) else {
            return false
        }

        if let profile = profile, let _ = profile.prefs.boolForKey(PrefsKeys.AppExtensionTelemetryOpenUrl) {
            profile.prefs.removeObjectForKey(PrefsKeys.AppExtensionTelemetryOpenUrl)
        }

        DispatchQueue.main.async {
            NavigationPath.handle(nav: routerpath, with: BrowserViewController.foregroundBVC())
        }
        return true
    }

    // We sync in the foreground only, to avoid the possibility of runaway resource usage.
    // Eventually we'll sync in response to notifications.
    func applicationDidBecomeActive(_ application: UIApplication) {
        shutdownWebServer?.cancel()
        shutdownWebServer = nil

        if #available(iOS 13.0, *) {
            // Matching interface style in dispatch block because of iOS 13 bug.
            // UITraitCollection.current.userInterfaceStyle value is beeing updated with delay.
            DispatchQueue.main.async {
                Theme.updateTheme(UITraitCollection.current.userInterfaceStyle)
            }
        }

        //
        // We are back in the foreground, so set CleanlyBackgrounded to false so that we can detect that
        // the application was cleanly backgrounded later.
        //

        let defaults = UserDefaults()
        defaults.set(false, forKey: "ApplicationCleanlyBackgrounded")

        if let profile = self.profile {
            profile._reopen()

            setUpWebServer(profile)
        }

        // We could load these here, but then we have to futz with the tab counter
        // and making NSURLRequests.
        browserViewController.loadQueuedTabs(receivedURLs: receivedURLs)
        receivedURLs.removeAll()
        application.applicationIconBadgeNumber = 0

        // Resume file downloads.
        BrowserViewController.foregroundBVC().downloadQueue.resumeAll()

        // handle quick actions is available
        let quickActions = QuickActions.sharedInstance
        if let shortcut = quickActions.launchedShortcutItem {
            // dispatch asynchronously so that BVC is all set up for handling new tabs
            // when we try and open them
            quickActions.handleShortCutItem(shortcut, withBrowserViewController: BrowserViewController.foregroundBVC())
            quickActions.launchedShortcutItem = nil
        }

        // Delay these operations until after UIKit/UIApp init is complete
        // - LeanPlum does heavy disk access during init, delay this
        // - loadQueuedTabs accesses the DB and shows up as a hot path in profiling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // We could load these here, but then we have to futz with the tab counter
            // and making NSURLRequests.
            self.browserViewController.loadQueuedTabs(receivedURLs: self.receivedURLs)
            self.receivedURLs.removeAll()
            application.applicationIconBadgeNumber = 0
        }

        // Cleanup can be a heavy operation, take it out of the startup path. Instead check after a few seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.profile?.cleanupHistoryIfNeeded()
        }

        if let callback = self.afterStartupAction {
            callback()
            self.afterStartupAction = nil
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //
        // At this point we are happy to mark the app as CleanlyBackgrounded. If a crash happens in background
        // sync then that crash will still be reported. But we won't bother the user with the Restore Tabs
        // dialog. We don't have to because at this point we already saved the tab state properly.
        //

        let defaults = UserDefaults()
        defaults.set(true, forKey: "ApplicationCleanlyBackgrounded")

        // Pause file downloads.
        BrowserViewController.foregroundBVC().downloadQueue.pauseAll()

        syncOnDidEnterBackground(application: application)

        let singleShotTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        // 2 seconds is ample for a localhost request to be completed by GCDWebServer. <500ms is expected on newer devices.
        singleShotTimer.schedule(deadline: .now() + 2.0, repeating: .never)
        singleShotTimer.setEventHandler {
            WebServer.sharedInstance.server.stop()
            self.shutdownWebServer = nil
        }
        singleShotTimer.resume()
        shutdownWebServer = singleShotTimer
    }

    fileprivate func syncOnDidEnterBackground(application: UIApplication) {
        guard let profile = self.profile else {
            return
        }

        var taskId: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
        taskId = application.beginBackgroundTask(expirationHandler: {
            print("Running out of background time, but we have a profile shutdown pending.")
            self.shutdownProfileWhenNotActive(application)
            application.endBackgroundTask(taskId)
        })

        profile._shutdown()
        application.endBackgroundTask(taskId)
    }

    fileprivate func shutdownProfileWhenNotActive(_ application: UIApplication) {
        // Only shutdown the profile if we are not in the foreground
        guard application.applicationState != .active else {
            return
        }

        profile?._shutdown()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // The reason we need to call this method here instead of `applicationDidBecomeActive`
        // is that this method is only invoked whenever the application is entering the foreground where as
        // `applicationDidBecomeActive` will get called whenever the Touch ID authentication overlay disappears.
    }

    fileprivate func setUpWebServer(_ profile: Profile) {
        let server = WebServer.sharedInstance
        guard !server.server.isRunning else { return }

        ReaderModeHandlers.register(server, profile: profile)

        let responders: [(String, InternalSchemeResponse)] =
            [ (AboutHomeHandler.path, AboutHomeHandler()),
              (AboutLicenseHandler.path, AboutLicenseHandler()),
              (SessionRestoreHandler.path, SessionRestoreHandler()),
              (ErrorPageHandler.path, ErrorPageHandler()), ]
        responders.forEach { (path, responder) in
            InternalSchemeHandler.responders[path] = responder
        }

        if AppConstants.IsRunningTest {
            registerHandlersForTestMethods(server: server.server)
        }

        // Bug 1223009 was an issue whereby CGDWebserver crashed when moving to a background task
        // catching and handling the error seemed to fix things, but we're not sure why.
        // Either way, not implicitly unwrapping a try is not a great way of doing things
        // so this is better anyway.
        do {
            try server.start()
        } catch let err as NSError {
            print("Error: Unable to start WebServer \(err)")
        }
    }

    fileprivate func setUserAgent() {
        let firefoxUA = UserAgent.getUserAgent()

        // Set the UA for WKWebView (via defaults), the favicon fetcher, and the image loader.
        // This only needs to be done once per runtime. Note that we use defaults here that are
        // readable from extensions, so they can just use the cached identifier.

        SDWebImageDownloader.shared.setValue(firefoxUA, forHTTPHeaderField: "User-Agent")
        // SDWebImage is setting accept headers that report we support webp. We don't
        SDWebImageDownloader.shared.setValue("image/*;q=0.8", forHTTPHeaderField: "Accept")

        FaviconFetcher.userAgent = UserAgent.desktopUserAgent()
    }

    private func shouldAskForReview() -> Bool {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyyMMdd"
        let today = dateformat.string(from: Date())
        guard UserAgentConstants.installDate != today else {
            self.profile?.prefs.setBool(false, forKey: PrefsKeys.ShowAppReview)
            return false
        }
        guard let showAppReview = self.profile?.prefs.boolForKey(PrefsKeys.ShowAppReview), showAppReview else {
            return false
        }
        self.profile?.prefs.setBool(false, forKey: PrefsKeys.ShowAppReview)
        #if DEBUG
            return true
        #else
            let random = Int.random(in: 1...100)
            guard random <= 5 else {
                return false
            }
            return true
        #endif
    }

    private func askForReview() {
        guard self.shouldAskForReview() else {
            return
        }
        SKStoreReviewController.requestReview()
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let bvc = BrowserViewController.foregroundBVC()
        if #available(iOS 12.0, *), let activityType = SiriActivityTypes(value: userActivity.activityType) {
            switch activityType {
            case .openURL:
                self.afterStartupAction = {
                    bvc.openBlankNewTab(focusLocationField: false)
                }
                return true
            case .searchWith:
                self.afterStartupAction = {
                    let query = userActivity.userInfo?["query"] as? String
                    self.browserViewController.showSearchInNewTab(query: query)
                }
                return true
            }
        }

        // If the `NSUserActivity` has a `webpageURL`, it is either a deep link or an old history item
        // reached via a "Spotlight" search before we began indexing visited pages via CoreSpotlight.
        if let url = userActivity.webpageURL {
            let query = url.getQuery()
            // Per Adjust documenation, https://docs.adjust.com/en/universal-links/#running-campaigns-through-universal-links,
            // it is recommended that links contain the `deep_link` query parameter. This link will also
            // be url encoded.
            if let deepLink = query["deep_link"]?.removingPercentEncoding, let url = URL(string: deepLink) {
                self.afterStartupAction = {
                    bvc.switchToTabForURLOrOpen(url, isPrivileged: true)
                }
                return true
            }
            self.afterStartupAction = {
                bvc.switchToTabForURLOrOpen(url, isPrivileged: true)
            }
            return true
        }

        // Otherwise, check if the `NSUserActivity` is a CoreSpotlight item and switch to its tab or
        // open a new one.
        if userActivity.activityType == CSSearchableItemActionType {
            if let userInfo = userActivity.userInfo,
                let urlString = userInfo[CSSearchableItemActivityIdentifier] as? String,
                let url = URL(string: urlString) {
                self.afterStartupAction = {
                    bvc.switchToTabForURLOrOpen(url, isPrivileged: true)
                }
                return true
            }
        }

        return false
    }

    fileprivate func openURLsInNewTabs(_ notification: UNNotification) {
        guard let urls = notification.request.content.userInfo["sentTabs"] as? [NSDictionary]  else { return }
        for sentURL in urls {
            if let urlString = sentURL.value(forKey: "url") as? String, let url = URL(string: urlString) {
                receivedURLs.append(url)
            }
        }

        // Check if the app is foregrounded, _also_ verify the BVC is initialized. Most BVC functions depend on viewDidLoad() having run –if not, they will crash.
        if UIApplication.shared.applicationState == .active && BrowserViewController.foregroundBVC().isViewLoaded {
            BrowserViewController.foregroundBVC().loadQueuedTabs(receivedURLs: receivedURLs)
            receivedURLs.removeAll()
        }
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShortCutItem = QuickActions.sharedInstance.canHandleShortCutItem(shortcutItem)
        self.afterStartupAction = {
            QuickActions.sharedInstance.handleShortCutItem(shortcutItem, withBrowserViewController: BrowserViewController.foregroundBVC())
            completionHandler(handledShortCutItem)
        }
    }
}

// MARK: - Root View Controller Animations
extension AppDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return BrowserToTrayAnimator()
        case .pop:
            return TrayToBrowserAnimator()
        default:
            return nil
        }
    }
}

extension AppDelegate: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the view controller and start the app up
        controller.dismiss(animated: true, completion: nil)
        _ = startApplication(application!, withLaunchOptions: self.launchOptions)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Called when the user taps on a sent-tab notification from the background.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        openURLsInNewTabs(response.notification)
    }

    // Called when the user receives a tab while in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        openURLsInNewTabs(notification)
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register. \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // TO DO : Check if this whole method can be removed, seeing that we don't Accound and Sync modules any more

        if Logger.logPII && log.isEnabledFor(level: .info) {
            NSLog("APNS NOTIFICATION \(userInfo)")
        }

        // At this point, we know that NotificationService has been run.
        // We get to this point if the notification was received while the app was in the foreground
        // OR the app was backgrounded and now the user has tapped on the notification.
        // Either way, if this method is being run, then the app is foregrounded.

        // Either way, we should zero the badge number.
        application.applicationIconBadgeNumber = 0

        guard self.profile != nil else {
            return completionHandler(.noData)
        }

        // NotificationService will have decrypted the push message, and done some syncing
        // activity. If the `client` collection was synced, and there are `displayURI` commands (i.e. sent tabs)
        // NotificationService will have collected them for us in the userInfo.
        if let serializedTabs = userInfo["sentTabs"] as? [NSDictionary] {
            // Let's go ahead and open those.
            for item in serializedTabs {
                if let urlString = item["url"] as? String, let url = URL(string: urlString) {
                    receivedURLs.append(url)
                }
            }

            if !receivedURLs.isEmpty {
                // If we're in the foreground, load the queued tabs now.
                if application.applicationState == .active {
                    DispatchQueue.main.async {
                        BrowserViewController.foregroundBVC().loadQueuedTabs(receivedURLs: self.receivedURLs)
                        self.receivedURLs.removeAll()
                    }
                }

                return completionHandler(.newData)
            }
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        let completionHandler: (UIBackgroundFetchResult) -> Void = { _ in }
        self.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
}

extension UIApplication {

    static var isInPrivateMode: Bool {
        return BrowserViewController.foregroundBVC().tabManager.selectedTab?.isPrivate ?? false
    }
}

/**
 * This exists because the Sync code is extension-safe, and thus doesn't get
 * direct access to UIApplication.sharedApplication, which it would need to
 * display a notification.
 * This will also likely be the extension point for wipes, resets, and
 * getting access to data sources during a sync.
 */

enum SentTabAction: String {
    case view = "TabSendViewAction"

    static let TabSendURLKey = "TabSendURL"
    static let TabSendTitleKey = "TabSendTitle"
    static let TabSendCategory = "TabSendCategory"

    static func registerActions() {
        let viewAction = UNNotificationAction(identifier: SentTabAction.view.rawValue, title: Strings.SentTab.ViewAction.Title, options: .foreground)

        // Register ourselves to handle the notification category set by NotificationService for APNS notifications
        let sentTabCategory = UNNotificationCategory(identifier: "org.mozilla.ios.SentTab.placeholder", actions: [viewAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        UNUserNotificationCenter.current().setNotificationCategories([sentTabCategory])
    }
}
