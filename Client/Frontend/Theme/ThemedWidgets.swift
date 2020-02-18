/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import UIKit

private struct ThemedTableViewCellUX {
    static let CellSideOffset = 20
    static let TitleLabelOffset = 10
    static let CellTopBottomOffset = 10
    static let IconSize = 24
    static let CornerRadius: CGFloat = 3
}

class ThemedTableViewCell: UITableViewCell, Themeable {
    var detailTextColor = Theme.tableView.rowDetailText

    lazy var titleLabel: UILabel = {
        return self.createLabel()
    }()

    lazy var detailLabel: UILabel = {
        return self.createLabel()
    }()

    var iconImage: UIImage? {
        didSet {
            if self.iconImage == nil {
                self.iconImageView.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
            } else {
                self.iconImageView.snp.updateConstraints { (make) in
                    make.width.equalTo(ThemedTableViewCellUX.IconSize)
                }
            }
        }
    }

    lazy private var iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.clipsToBounds = true
        icon.layer.cornerRadius = ThemedTableViewCellUX.CornerRadius
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
        return icon
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup(style: style)
        self.applyTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme() {
        var needToChangeTextColor = true
        if self.titleLabel.attributedText?.length ?? 0 > 0 {
             needToChangeTextColor = self.titleLabel.attributedText?.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) == nil
        }
        if needToChangeTextColor {
            self.titleLabel.textColor = Theme.tableView.rowText
        }
        var needToChangeDetailTextColor = true
        if self.detailLabel.attributedText?.length ?? 0 > 0 {
            needToChangeDetailTextColor = self.detailLabel.attributedText?.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) == nil
        }
        if needToChangeDetailTextColor {
            self.detailLabel.textColor = detailTextColor
        }
        self.backgroundColor = Theme.tableView.rowBackground
        self.tintColor = Theme.general.controlTint
    }

    private func setup(style: UITableViewCell.CellStyle) {
        self.contentView.addSubview(self.iconImageView)
        self.iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(ThemedTableViewCellUX.CellSideOffset / 2)
            make.centerY.equalToSuperview()
            make.width.equalTo(0)
            make.height.equalTo(ThemedTableViewCellUX.IconSize)
        }

        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.iconImageView.snp.right).offset(ThemedTableViewCellUX.TitleLabelOffset / 2)
            if style == .subtitle {
                make.top.equalToSuperview().offset(ThemedTableViewCellUX.CellTopBottomOffset)
                make.right.equalToSuperview().offset(-ThemedTableViewCellUX.CellSideOffset)
            } else {
                make.top.equalToSuperview().offset(ThemedTableViewCellUX.CellTopBottomOffset)
                make.bottom.equalToSuperview().offset(-ThemedTableViewCellUX.CellTopBottomOffset)
            }
        }

        self.contentView.addSubview(self.detailLabel)
        self.detailLabel.snp.makeConstraints { (make) in
            if style == .subtitle {
                make.left.equalTo(self.titleLabel)
                make.right.equalToSuperview().offset(-ThemedTableViewCellUX.CellSideOffset)
                make.top.equalTo(self.titleLabel.snp.bottom).offset(ThemedTableViewCellUX.TitleLabelOffset / 2)
                make.bottom.equalToSuperview().offset(-ThemedTableViewCellUX.CellTopBottomOffset)
            } else {
                make.left.equalTo(self.titleLabel.snp.right).offset(ThemedTableViewCellUX.TitleLabelOffset)
                make.right.equalToSuperview().offset(-ThemedTableViewCellUX.TitleLabelOffset)
                make.top.equalToSuperview().offset(ThemedTableViewCellUX.CellTopBottomOffset)
                make.bottom.equalToSuperview().offset(-ThemedTableViewCellUX.CellTopBottomOffset)
            }
        }
        if style == .subtitle {
            self.detailLabel.textAlignment = .left
            self.detailLabel.font = DynamicFontHelper.defaultHelper.SmallSizeRegularWeightAS
        } else {
            self.detailLabel.textAlignment = .right
            self.detailLabel.font = DynamicFontHelper.defaultHelper.LargeSizeRegularWeightAS
        }
    }

    private func createLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 4
        label.font = DynamicFontHelper.defaultHelper.LargeSizeRegularWeightAS
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }

}

class ThemedTableViewController: UITableViewController, Themeable {
    override init(style: UITableView.Style = .grouped) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ThemedTableViewCell(style: .subtitle, reuseIdentifier: nil)
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
    }

    func reloadData() {
        self.applyTheme()
    }

    func applyTheme() {
        tableView.separatorColor = Theme.tableView.separator
        tableView.backgroundColor = Theme.tableView.headerBackground
        tableView.reloadData()

        (tableView.tableHeaderView as? Themeable)?.applyTheme()
    }
}

class ThemedTableSectionHeaderFooterView: UITableViewHeaderFooterView, Themeable {
    private struct UX {
        static let titleHorizontalPadding: CGFloat = 15
        static let titleVerticalPadding: CGFloat = 6
        static let titleVerticalLongPadding: CGFloat = 20
    }

    enum TitleAlignment {
        case top
        case bottom
    }

    var titleAlignment: TitleAlignment = .bottom {
        didSet {
            remakeTitleAlignmentConstraints()
        }
    }

    var showTopBorder: Bool = true {
        didSet {
            topBorder.isHidden = !showTopBorder
        }
    }

    var showBottomBorder: Bool = true {
        didSet {
            bottomBorder.isHidden = !showBottomBorder
        }
    }

    lazy var titleLabel: UILabel = {
        var headerLabel = UILabel()
        headerLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)
        headerLabel.numberOfLines = 0
        return headerLabel
    }()

    fileprivate lazy var topBorder: UIView = {
        let topBorder = UIView()
       return topBorder
    }()

    fileprivate lazy var bottomBorder: UIView = {
        let bottomBorder = UIView()
        return bottomBorder
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel)
        addSubview(topBorder)
        addSubview(bottomBorder)
        setupInitialConstraints()
        applyTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme() {
        topBorder.backgroundColor = Theme.tableView.separator
        bottomBorder.backgroundColor = Theme.tableView.separator
        contentView.backgroundColor = Theme.tableView.headerBackground
        titleLabel.textColor = Theme.tableView.headerTextLight
    }

    func setupInitialConstraints() {
        bottomBorder.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }

        topBorder.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }

        remakeTitleAlignmentConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        showTopBorder = true
        showBottomBorder = true
        titleLabel.text = nil
        titleAlignment = .bottom

        applyTheme()
    }

    fileprivate func remakeTitleAlignmentConstraints() {
        switch titleAlignment {
        case .top:
            titleLabel.snp.remakeConstraints { make in
                make.left.right.equalTo(self.contentView).inset(UX.titleHorizontalPadding)
                make.top.equalTo(self).offset(UX.titleVerticalPadding)
                make.bottom.equalTo(self).offset(-UX.titleVerticalLongPadding)
            }
        case .bottom:
            titleLabel.snp.remakeConstraints { make in
                make.left.right.equalTo(self.contentView).inset(UX.titleHorizontalPadding)
                make.bottom.equalTo(self).offset(-UX.titleVerticalPadding)
                make.top.equalTo(self).offset(UX.titleVerticalLongPadding)
            }
        }
    }
}

class UISwitchThemed: UISwitch {
    override func layoutSubviews() {
        super.layoutSubviews()
        onTintColor = Theme.general.controlTint
    }
}
