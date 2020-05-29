/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage

struct TopTabsSeparatorUX {
    static let Identifier = "Separator"
    static let Width: CGFloat = 1
}

class TopTabsSeparator: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Theme.topTabs.separator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TopTabsHeaderFooter: UICollectionReusableView {
    let line = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        line.semanticContentAttribute = .forceLeftToRight
        addSubview(line)
        line.backgroundColor = Theme.topTabs.separator
    }

    func arrangeLine(_ kind: String) {
        line.snp.removeConstraints()
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            line.snp.makeConstraints { make in
                make.trailing.equalTo(self)
            }
        case UICollectionView.elementKindSectionFooter:
            line.snp.makeConstraints { make in
                make.leading.equalTo(self)
            }
        default:
            break
        }
        line.snp.makeConstraints { make in
            make.height.equalTo(TopTabsUX.SeparatorHeight)
            make.width.equalTo(TopTabsUX.SeparatorWidth)
            make.top.equalTo(self).offset(TopTabsUX.SeparatorYOffset)
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        layer.zPosition = CGFloat(layoutAttributes.zIndex)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TopTabCell: UICollectionViewCell {

    static let Identifier = "TopTabCellIdentifier"
    static let ShadowOffsetSize: CGFloat = 2 //The shadow is used to hide the tab separator

    var selectedTab = false {
        didSet {
            backgroundColor = selectedTab ? Theme.topTabs.tabBackgroundSelected : Theme.topTabs.tabBackgroundUnselected
            titleText.textColor = selectedTab ? Theme.topTabs.tabForegroundSelected : Theme.topTabs.tabForegroundUnselected
            closeButton.tintColor = selectedTab ? Theme.topTabs.closeButtonSelectedTab : Theme.topTabs.closeButtonUnselectedTab
            closeButton.backgroundColor = .clear
            closeButton.layer.shadowColor = backgroundColor?.cgColor
            if selectedTab {
                drawShadow()
            } else {
                self.layer.shadowOpacity = 0
            }
        }
    }

    let titleText: UILabel = {
        let titleText = UILabel()
        titleText.textAlignment = .left
        titleText.isUserInteractionEnabled = false
        titleText.numberOfLines = 1
        titleText.lineBreakMode = .byCharWrapping
        titleText.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
        titleText.semanticContentAttribute = .forceLeftToRight
        return titleText
    }()

    let iconView = IconView()

    let closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage.templateImageNamed("menu-CloseTabs"), for: [])
        closeButton.imageEdgeInsets = UIEdgeInsets(top: TopTabsUX.TabCloseButtonImagePadding, left: TopTabsUX.TabCloseButtonImagePadding, bottom: TopTabsUX.TabCloseButtonImagePadding, right: TopTabsUX.TabCloseButtonImagePadding)
        closeButton.layer.shadowOpacity = 0.8
        closeButton.layer.masksToBounds = false
        closeButton.layer.shadowOffset = CGSize(width: -TopTabsUX.TabTitlePadding, height: 0)
        closeButton.semanticContentAttribute = .forceLeftToRight
        return closeButton
    }()

    weak var delegate: TopTabCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        closeButton.addTarget(self, action: #selector(closeTab), for: .touchUpInside)

        contentView.addSubview(titleText)
        contentView.addSubview(closeButton)
        contentView.addSubview(iconView)

        self.clipsToBounds = true
        self.layer.cornerRadius = 18
        self.closeButton.layer.cornerRadius = self.layer.cornerRadius

        iconView.snp.makeConstraints { make in
            make.centerY.equalTo(self).offset(TopTabsUX.TabNudge)
            make.size.equalTo(TabTrayControllerUX.FaviconSize)
            make.leading.equalTo(self).offset(self.layer.cornerRadius)
        }
        titleText.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.height.equalTo(self)
            make.trailing.equalTo(closeButton.snp.leading).offset(TopTabsUX.TabTitlePadding)
            make.leading.equalTo(iconView.snp.trailing).offset(TopTabsUX.TabTitlePadding)
        }
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(self).offset(TopTabsUX.TabNudge)
            make.height.equalTo(self)
            make.width.equalTo(self.snp.height)
            make.trailing.equalTo(self.snp.trailing)
        }
    }

    func configureWith(tab: Tab, isSelected: Bool) {
        self.titleText.text = tab.displayTitle

        if tab.displayTitle.isEmpty {
            if let url = tab.webView?.url, let internalScheme = InternalURL(url) {
                self.titleText.text = Strings.Menu.NewTabTitleString
                self.accessibilityLabel = internalScheme.aboutComponent
            } else {
                self.titleText.text = tab.webView?.url?.absoluteDisplayString
            }

            self.closeButton.accessibilityLabel = String(format: Strings.TopSites.RemoveButtonAccessibilityLabel, self.titleText.text ?? "")
        } else {
            self.accessibilityLabel = tab.displayTitle
            self.closeButton.accessibilityLabel = String(format: Strings.TopSites.RemoveButtonAccessibilityLabel, tab.displayTitle)
        }

        self.selectedTab = isSelected
        if InternalURL.isValid(url: tab.url) || SearchURL.isValid(url: tab.url) || tab.isNewTabPage {
            self.iconView.getIcon(site: Site(url: Strings.BrandWebsite, title: tab.title ?? ""))
        } else {
            self.iconView.setTabIcon(tab: tab)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.shadowOpacity = 0
    }

    @objc func closeTab() {
        delegate?.tabCellDidClose(self)
    }

    // When a tab is selected the shadow prevents the tab separators from showing.
    func drawShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = backgroundColor?.cgColor
        self.layer.shadowOpacity  = 1
        self.layer.shadowRadius = 0

        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(width: self.frame.size.width + (TopTabCell.ShadowOffsetSize * 2), height: self.frame.size.height), cornerRadius: 0).cgPath
        self.layer.shadowOffset = CGSize(width: -TopTabCell.ShadowOffsetSize, height: 0)
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        layer.zPosition = CGFloat(layoutAttributes.zIndex)
    }
}

class TopTabFader: UIView {
    lazy var hMaskLayer: CAGradientLayer = {
        let innerColor: CGColor = UIColor.White.cgColor
        let outerColor: CGColor = UIColor.White.withAlphaComponent(0.0).cgColor
        let hMaskLayer = CAGradientLayer()
        hMaskLayer.colors = [outerColor, innerColor, innerColor, outerColor]
        hMaskLayer.locations = [0.00, 0.005, 0.995, 1.0]
        hMaskLayer.startPoint = CGPoint(x: 0, y: 0.5)
        hMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        hMaskLayer.anchorPoint = .zero
        return hMaskLayer
    }()

    init() {
        super.init(frame: .zero)
        layer.mask = hMaskLayer
    }

    internal override func layoutSubviews() {
        super.layoutSubviews()

        let widthA = NSNumber(value: Float(CGFloat(8) / frame.width))
        let widthB = NSNumber(value: Float(1 - CGFloat(8) / frame.width))

        hMaskLayer.locations = [0.00, widthA, widthB, 1.0]
        hMaskLayer.frame = CGRect(width: frame.width, height: frame.height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TopTabsViewLayoutAttributes: UICollectionViewLayoutAttributes {

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TopTabsViewLayoutAttributes else {
            return false
        }
        return super.isEqual(object)
    }
}
