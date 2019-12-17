/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Shared

struct IntroUX {
    static let Width = 375
    static let Height = 667
    static let MinimumFontScale: CGFloat = 0.5
    static let PagerCenterOffsetFromScrollViewBottom = UIScreen.main.bounds.width <= 320 ? 10 : 20
    static let TitleColor = UIColor(hexString: "#1A1A25")
    static let TextColor = UIColor(hexString: "#607c85")
    static let SkipButtonColor = UIColor(hexString: "#97A4AE")
    static let SkipButtonHeight = 50
    static let StartBrowsingButtonColor = UIColor.CliqzBlue
    static let StartBrowsingButtonHeight = UIScreen.main.bounds.width <= 320 ? 40 : 50
    static let StartBrowsingButtonWidth = UIScreen.main.bounds.width <= 320 ? 200 : 240
    static let PageControlHeight = 40
    static let FadeDuration = 0.25
    static let LogoImageSize = 42.0
    static let StartBrowsingBottomOffset = UIScreen.main.bounds.width <= 320 ? -30 : -20
    static let ContainerImageTopOffes = -40.0
}

protocol IntroViewControllerDelegate: AnyObject {
    func introViewControllerDidFinish(_ introViewController: IntroViewController)
}

class IntroViewController: UIViewController {
    weak var delegate: IntroViewControllerDelegate?

    // We need to hang on to views so we can animate and change constraints as we scroll
    var cardViews = [CardView]()
    var cards = IntroCard.defaultCards()

    lazy fileprivate var skipButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setTitle(Strings.Intro.Slides.SkipButtonTitle, for: UIControl.State())
        button.setTitleColor(IntroUX.SkipButtonColor, for: UIControl.State())
        button.addTarget(self, action: #selector(IntroViewController.startBrowsing), for: UIControl.Event.touchUpInside)
        button.accessibilityIdentifier = "IntroViewController.startBrowsingButton"
        return button
    }()

    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
        pc.currentPageIndicatorTintColor = UIColor.CliqzBlue
        pc.accessibilityIdentifier = "IntroViewController.pageControl"
        pc.addTarget(self, action: #selector(IntroViewController.changePage), for: UIControl.Event.valueChanged)
        return pc
    }()

    lazy fileprivate var scrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.backgroundColor = UIColor.clear
        sc.accessibilityLabel = NSLocalizedString("Intro Tour Carousel", comment: "Accessibility label for the introduction tour carousel")
        sc.delegate = self
        sc.bounces = false
        sc.isPagingEnabled = true
        sc.showsHorizontalScrollIndicator = false
        sc.accessibilityIdentifier = "IntroViewController.scrollView"
        return sc
    }()

    var horizontalPadding: Int {
        return self.view.frame.width <= 320 ? 20 : 50
    }

    var verticalPadding: CGFloat {
        return self.view.frame.width <= 320 ? 20 : 40
    }

    lazy fileprivate var imageViewContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        return sv
    }()

    // Because a stackview cannot have a background color
    fileprivate var imagesBackgroundView = UIView()

    fileprivate var logoImageView = UIImageView(image: UIImage(named: "tour-Logo"))

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(cards.count > 1, "Intro is empty. At least 2 cards are required")
        view.backgroundColor = UIColor.White

        // Add Views
        view.addSubview(pageControl)
        view.addSubview(scrollView)
        view.addSubview(skipButton)
        view.addSubview(self.logoImageView)
        scrollView.addSubview(imagesBackgroundView)
        scrollView.addSubview(imageViewContainer)

        // Setup constraints
        self.logoImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.imageViewContainer.snp.bottom)
            make.height.width.equalTo(IntroUX.LogoImageSize)
        }

        imagesBackgroundView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(imageViewContainer)
        }
        imageViewContainer.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.left.equalTo(self.scrollView)
            make.height.equalTo(self.view.snp.height).multipliedBy(0.5)
        }
        skipButton.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view.safeArea.bottom)
            make.height.equalTo(IntroUX.SkipButtonHeight)
        }
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(pageControl.snp.top)
        }

        pageControl.snp.makeConstraints { make in
            make.centerX.equalTo(self.scrollView)
            make.centerY.equalTo(self.skipButton.snp.top).offset(-IntroUX.PagerCenterOffsetFromScrollViewBottom)
        }

        createSlides()
        pageControl.addTarget(self, action: #selector(changePage), for: .valueChanged)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = imageViewContainer.frame.size
    }

    func createSlides() {
        // Make sure the scrollView has been setup before setting up the slides
        guard scrollView.superview != nil else {
            return
        }
        // Wipe any existing slides
        imageViewContainer.subviews.forEach { $0.removeFromSuperview() }
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews = cards.compactMap { addIntro(card: $0) }
        pageControl.numberOfPages = cardViews.count
        setupDynamicFonts()
        if let firstCard = cardViews.first {
            setActive(firstCard, forPage: 0)
            self.imagesBackgroundView.backgroundColor = self.cards.first!.imageBackgroundColor
        }
        imageViewContainer.layoutSubviews()
        scrollView.contentSize = imageViewContainer.frame.size
    }

    func addIntro(card: IntroCard) -> CardView? {
        guard let image = UIImage(named: card.imageName) else {
            return nil
        }
        let imageContentView = UIView()
        imageContentView.backgroundColor = .clear
        let imageView = UIImageView(image: image)
        imageView.contentMode = card.imageContentMode
        imageContentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(imageContentView)
            make.height.equalTo(imageContentView.snp.height).offset(IntroUX.ContainerImageTopOffes)
            make.centerX.equalTo(imageContentView.snp.centerX)
            make.height.equalTo(imageView.snp.width).multipliedBy(975.0/879.0)
        }
        imageViewContainer.addArrangedSubview(imageContentView)
        imageContentView.snp.makeConstraints { make in
            make.height.equalTo(imageViewContainer.snp.height)
            make.width.equalTo(self.view.snp.width)
        }

        let cardView = CardView(verticleSpacing: verticalPadding)
        cardView.configureWith(card: card)
        if let selectorString = card.buttonSelector, self.responds(to: NSSelectorFromString(selectorString)) {
            cardView.button.addTarget(self, action: NSSelectorFromString(selectorString), for: .touchUpInside)
            cardView.button.snp.makeConstraints { make in
                make.width.equalTo(IntroUX.StartBrowsingButtonWidth)
                make.height.equalTo(IntroUX.StartBrowsingButtonHeight)
            }
        }
        self.view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.top.equalTo(self.imageViewContainer.snp.bottom).offset(verticalPadding)
            make.bottom.equalTo(self.pageControl.snp.top)
            make.left.right.equalTo(self.view).inset(horizontalPadding)
        }
        return cardView
    }

    @objc func startBrowsing() {
        delegate?.introViewControllerDidFinish(self)
    }

    @objc func changePage() {
        let swipeCoordinate = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: swipeCoordinate, y: 0), animated: true)
    }

    fileprivate func setActive(_ introView: UIView, forPage page: Int) {
        guard introView.alpha != 1 else {
            return
        }

        UIView.animate(withDuration: IntroUX.FadeDuration, animations: {
            self.cardViews.forEach { $0.alpha = 0.0 }
            introView.alpha = 1.0
            self.pageControl.currentPage = page
        }, completion: nil)
    }
}

// UIViewController setup
extension IntroViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // This actually does the right thing on iPad where the modally
        // presented version happily rotates with the iPad orientation.
        return .portrait
    }
}

// Dynamic Font Helper
extension IntroViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(dynamicFontChanged), name: .DynamicFontChanged, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .DynamicFontChanged, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func dynamicFontChanged(_ notification: Notification) {
        guard notification.name == .DynamicFontChanged else { return }
        setupDynamicFonts()
    }

    fileprivate func setupDynamicFonts() {
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: DynamicFontHelper.defaultHelper.IntroStandardFontSize)
        cardViews.forEach { cardView in
            cardView.titleLabel.font = UIFont.boldSystemFont(ofSize: DynamicFontHelper.defaultHelper.IntroBigFontSize)
            cardView.textLabel.font = UIFont.systemFont(ofSize: DynamicFontHelper.defaultHelper.IntroStandardFontSize)
        }
    }
}

extension IntroViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Need to add this method so that when forcibly dragging, instead of letting deceleration happen, should also calculate what card it's on.
        // This especially affects sliding to the last or first cards.
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Need to add this method so that tapping the pageControl will also change the card texts.
        // scrollViewDidEndDecelerating waits until the end of the animation to calculate what card it's on.
        scrollViewDidEndDecelerating(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        if let cardView = cardViews[safe: page] {
            setActive(cardView, forPage: page)
        }
        skipButton.isHidden = page == self.cardViews.count - 1
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        if self.cards.count > page {
            if self.cards.count == page + 1 {
                self.logoImageView.image = UIImage(named: "tour-checkmark")
            } else {
                self.logoImageView.image = UIImage(named: "tour-Logo")
            }
            let card = self.cards[page]
            if self.imagesBackgroundView.backgroundColor != card.imageBackgroundColor {
                UIView.animate(withDuration: 0.1) {
                    self.imagesBackgroundView.backgroundColor = card.imageBackgroundColor
                }
            }
        }
    }
}

// A cardView repersents the text for each page of the intro. It does not include the image.
class CardView: UIView {

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = IntroUX.TitleColor
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = IntroUX.MinimumFontScale
        titleLabel.textAlignment = .center
        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        return titleLabel
    }()

    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textColor = IntroUX.TextColor
        textLabel.numberOfLines = 5
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = IntroUX.MinimumFontScale
        textLabel.textAlignment = .center
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        return textLabel
    }()

    lazy var button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = CGFloat(IntroUX.StartBrowsingButtonHeight) / 2
        button.backgroundColor = IntroUX.StartBrowsingButtonColor
        button.setTitle(Strings.Intro.Slides.Welcome.ButtonTitle, for: [])
        button.setTitleColor(.white, for: [])
        button.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        button.clipsToBounds = true
        button.accessibilityIdentifier = "turnOnSync.button"
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(verticleSpacing: CGFloat) {
        super.init(frame: .zero)
        stackView.spacing = verticleSpacing
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textLabel)
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self)
            make.bottom.lessThanOrEqualTo(self).offset(-IntroUX.PageControlHeight)
        }
        alpha = 0
    }

    func configureWith(card: IntroCard) {
        titleLabel.text = card.title
        textLabel.text = card.text
        if let buttonText = card.buttonText, card.buttonSelector != nil {
            button.setTitle(buttonText, for: .normal)
            addSubview(button)
            button.snp.makeConstraints { make in
                make.bottom.equalTo(self).offset(IntroUX.StartBrowsingBottomOffset)
                make.centerX.equalTo(self)
            }
            // When there is a button reduce the spacing to make more room for text
            stackView.spacing = stackView.spacing / 2
        }
    }

    // Allows the scrollView to scroll while the CardView is in front
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let buttonSV = button.superview {
            return convert(button.frame, from: buttonSV).contains(point)
        }
        return false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct IntroCard {
    let title: String
    let text: String
    let buttonText: String?
    let buttonSelector: String? // Selector is a string that is synthisized into a Selector via NSSelectorFromString (for LeanPlum's sake)
    let imageName: String
    let imageContentMode: UIView.ContentMode
    let imageBackgroundColor: UIColor

    init(title: String, text: String, imageName: String, imageContentMode: UIView.ContentMode = .center, imageBackgroundColor: UIColor = UIColor.White, buttonText: String? = nil, buttonSelector: String? = nil) {
        self.title = title
        self.text = text
        self.imageName = imageName
        self.buttonText = buttonText
        self.buttonSelector = buttonSelector
        self.imageBackgroundColor = imageBackgroundColor
        self.imageContentMode = imageContentMode
    }

    static func defaultCards() -> [IntroCard] {
        let search = IntroCard(title: Strings.Intro.Slides.Search.Title, text: Strings.Intro.Slides.Search.Description, imageName: "tour-Search", imageContentMode: .scaleAspectFit, imageBackgroundColor: UIColor.LightBlue)
        let antiTracking = IntroCard(title: Strings.Intro.Slides.AntiTracking.Title, text: Strings.Intro.Slides.AntiTracking.Description, imageName: "tour-antiTracking", imageContentMode: .scaleAspectFit, imageBackgroundColor: UIColor.LightBlue)
        let welcome = IntroCard(title: "", text: Strings.Intro.Slides.Welcome.Description, imageName: "tour-LogoFull", imageContentMode: .center, buttonText: Strings.Intro.Slides.Welcome.ButtonTitle, buttonSelector: #selector(IntroViewController.startBrowsing).description)
        return [search, antiTracking, welcome]
    }

}

extension IntroCard: Equatable {}

func == (lhs: IntroCard, rhs: IntroCard) -> Bool {
    return lhs.buttonText == rhs.buttonText && lhs.buttonSelector == rhs.buttonSelector && lhs.imageBackgroundColor == rhs.imageBackgroundColor
        && lhs.imageContentMode == rhs.imageContentMode && lhs.imageName == rhs.imageName && lhs.text == rhs.text && lhs.title == rhs.title
}

extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}
