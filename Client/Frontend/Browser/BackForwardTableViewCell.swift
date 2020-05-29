/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Storage
import Shared

class BackForwardTableViewCell: UITableViewCell {

    private struct BackForwardViewCellUX {
        static let bgColor = UIColor.Grey50
        static let faviconWidth = 29
        static let faviconPadding: CGFloat = 20
        static let labelPadding = 20
        static let borderSmall = 2
        static let borderBold = 5
        static let IconSize = 23
        static let fontSize: CGFloat = 12.0
        static let textColor = UIColor.Grey80
    }

    lazy var iconView = IconView()

    lazy var label: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = label.font.withSize(BackForwardViewCellUX.fontSize)
        label.textColor = Theme.tabTray.tabTitleText
        return label
    }()

    var connectingForwards = true
    var connectingBackwards = true

    var isCurrentTab = false {
        didSet {
            if isCurrentTab {
                label.font = UIFont.boldSystemFont(ofSize: BackForwardViewCellUX.fontSize)
            }
        }
    }

    var site: Site? {
        didSet {
            if let s = site {
                let scaled = CGSize(width: BackForwardViewCellUX.IconSize, height: BackForwardViewCellUX.IconSize)
                if InternalURL.isValid(url: s.tileURL) || SearchURL.isValid(url: s.tileURL) {
                    self.iconView.getIcon(site: Site(url: Strings.BrandWebsite, title: s.title), scaled: scaled)
                } else {
                    self.iconView.setIcon(site: s, scaled: scaled)
                }
                var title = s.title
                if title.isEmpty {
                    if let fullUrl = URL(string: s.url), let searchUrl = SearchURL(fullUrl) {
                        title = searchUrl.title
                    } else {
                        title = s.url
                    }
                }
                label.text = title
                setNeedsLayout()
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none

        contentView.addSubview(self.iconView)
        contentView.addSubview(label)

        self.iconView.snp.makeConstraints { make in
            make.height.equalTo(BackForwardViewCellUX.faviconWidth)
            make.width.equalTo(BackForwardViewCellUX.faviconWidth)
            make.centerY.equalTo(self)
            make.leading.equalTo(self.snp.leading).offset(BackForwardViewCellUX.faviconPadding)
        }

        label.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(self.iconView.snp.trailing).offset(BackForwardViewCellUX.labelPadding)
            make.trailing.equalTo(self.snp.trailing).offset(-BackForwardViewCellUX.labelPadding)
        }

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        var startPoint = CGPoint(x: rect.origin.x + BackForwardViewCellUX.faviconPadding + CGFloat(Double(BackForwardViewCellUX.faviconWidth)*0.5),
                                     y: rect.origin.y + (connectingForwards ?  0 : rect.size.height/2))
        var endPoint   = CGPoint(x: rect.origin.x + BackForwardViewCellUX.faviconPadding + CGFloat(Double(BackForwardViewCellUX.faviconWidth)*0.5),
                                     y: rect.origin.y + rect.size.height - (connectingBackwards  ? 0 : rect.size.height/2))

        // flip the x component if RTL
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            startPoint.x = rect.origin.x - startPoint.x + rect.size.width
            endPoint.x = rect.origin.x - endPoint.x + rect.size.width
        }

        context.saveGState()
        context.setLineCap(.square)
        context.setStrokeColor(BackForwardViewCellUX.bgColor.cgColor)
        context.setLineWidth(1.0)
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.strokePath()
        context.restoreGState()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        } else {
            self.backgroundColor = UIColor.clear
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        connectingForwards = true
        connectingBackwards = true
        isCurrentTab = false
        label.font = UIFont.systemFont(ofSize: BackForwardViewCellUX.fontSize)
    }
}
