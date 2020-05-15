/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

private struct ReaderModeStyleViewControllerUX {
    static let RowHeight = 50

    static let Width = 270
    static let Height = 4 * RowHeight

    static let FontTypeRowBackground = UIColor.Grey10

    static let FontTypeTitleSelectedColor = UIColor.Grey90
    static let FontTypeTitleNormalColor = UIColor.Grey60

    static let FontSizeRowBackground = UIColor.Grey20
    static let FontSizeLabelColor = UIColor.Grey80
    static let FontSizeButtonTextColorEnabled = Theme.textField.textAndTint
    static let FontSizeButtonTextColorDisabled = UIColor.Grey60

    static let ThemeRowBackgroundColor = UIColor.White
    static let ThemeTitleColorLight = UIColor.darkGray
    static let ThemeTitleColorDark = UIColor.White
    static let ThemeTitleColorSepia = UIColor.darkGray
    static let ThemeBackgroundColorLight = UIColor.White
    static let ThemeBackgroundColorDark = UIColor.darkGray
    static let ThemeBackgroundColorSepia = UIColor.ReaderModeSepia

    static let BrightnessRowBackground = UIColor.Grey20
    static let BrightnessSliderTintColor = UIColor.Orange
    static let BrightnessSliderWidth = 140
    static let BrightnessIconOffset = 10
}

// MARK: -

protocol ReaderModeStyleViewControllerDelegate {
    // isUsingUserDefinedColor should be false by default unless we need to override the default color 
    func readerModeStyleViewController(_ readerModeStyleViewController: ReaderModeStyleViewController,
                                       didConfigureStyle style: ReaderModeStyle,
                                       isUsingUserDefinedColor: Bool)
}

// MARK: -

class ReaderModeStyleViewController: UIViewController {
    var delegate: ReaderModeStyleViewControllerDelegate?
    var readerModeStyle: ReaderModeStyle = DefaultReaderModeStyle

    fileprivate var fontTypeButtons: [FontTypeButton]!
    fileprivate var fontSizeLabel: FontSizeLabel!
    fileprivate var fontSizeButtons: [FontSizeButton]!
    fileprivate var themeButtons: [ThemeButton]!

    fileprivate var separatorLines = [UIView(), UIView(), UIView()]

    fileprivate var fontTypeRow: UIView!
    fileprivate var fontSizeRow: UIView!
    fileprivate var brightnessRow: UIView!

    // Keeps user-defined reader color until reader mode is closed or reloaded
    fileprivate var isUsingUserDefinedColor = false

    override func viewDidLoad() {
        // Our preferred content size has a fixed width and height based on the rows + padding
        super.viewDidLoad()
        preferredContentSize = CGSize(width: ReaderModeStyleViewControllerUX.Width, height: ReaderModeStyleViewControllerUX.Height)

        popoverPresentationController?.backgroundColor = ReaderModeStyleViewControllerUX.FontTypeRowBackground

        // Font type row

        let fontTypeRow = UIView()
        view.addSubview(fontTypeRow)
        fontTypeRow.backgroundColor = ReaderModeStyleViewControllerUX.FontTypeRowBackground

        fontTypeRow.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view)
            make.left.right.equalTo(self.view)
            make.height.equalTo(ReaderModeStyleViewControllerUX.RowHeight)
        }

        fontTypeButtons = [
            FontTypeButton(fontType: ReaderModeFontType.sansSerif),
            FontTypeButton(fontType: ReaderModeFontType.serif),
        ]

        setupButtons(fontTypeButtons, inRow: fontTypeRow, action: #selector(changeFontType))

        // Font size row

        let fontSizeRow = UIView()
        view.addSubview(fontSizeRow)
        fontSizeRow.backgroundColor = ReaderModeStyleViewControllerUX.FontSizeRowBackground

        fontSizeRow.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(fontTypeRow.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(ReaderModeStyleViewControllerUX.RowHeight)
        }

        fontSizeLabel = FontSizeLabel()
        fontSizeRow.addSubview(fontSizeLabel)

        fontSizeLabel.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(fontSizeRow)
            return
        }

        fontSizeButtons = [
            FontSizeButton(fontSizeAction: FontSizeAction.smaller),
            FontSizeButton(fontSizeAction: FontSizeAction.reset),
            FontSizeButton(fontSizeAction: FontSizeAction.bigger),
        ]

        setupButtons(fontSizeButtons, inRow: fontSizeRow, action: #selector(changeFontSize))

        // Theme row

        let themeRow = UIView()
        view.addSubview(themeRow)

        themeRow.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(fontSizeRow.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(ReaderModeStyleViewControllerUX.RowHeight)
        }

        themeButtons = [
            ThemeButton(theme: ReaderModeTheme.light),
            ThemeButton(theme: ReaderModeTheme.dark),
            ThemeButton(theme: ReaderModeTheme.sepia),
        ]

        setupButtons(themeButtons, inRow: themeRow, action: #selector(changeTheme))

        // Brightness row

        let brightnessRow = UIView()
        view.addSubview(brightnessRow)
        brightnessRow.backgroundColor = ReaderModeStyleViewControllerUX.BrightnessRowBackground

        brightnessRow.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(themeRow.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(ReaderModeStyleViewControllerUX.RowHeight)
        }

        let slider = UISlider()
        brightnessRow.addSubview(slider)
        slider.accessibilityLabel = Strings.Accessibility.ReaderMode.Brightness
        slider.tintColor = ReaderModeStyleViewControllerUX.BrightnessSliderTintColor
        slider.addTarget(self, action: #selector(changeBrightness), for: .valueChanged)

        slider.snp.makeConstraints { make in
            make.center.equalTo(brightnessRow)
            make.width.equalTo(ReaderModeStyleViewControllerUX.BrightnessSliderWidth)
        }

        let brightnessMinImageView = UIImageView(image: UIImage(named: "brightnessMin"))
        brightnessRow.addSubview(brightnessMinImageView)

        brightnessMinImageView.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(slider)
            make.right.equalTo(slider.snp.left).offset(-ReaderModeStyleViewControllerUX.BrightnessIconOffset)
        }

        let brightnessMaxImageView = UIImageView(image: UIImage(named: "brightnessMax"))
        brightnessRow.addSubview(brightnessMaxImageView)

        brightnessMaxImageView.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(slider)
            make.left.equalTo(slider.snp.right).offset(ReaderModeStyleViewControllerUX.BrightnessIconOffset)
        }

        selectFontType(readerModeStyle.fontType)
        updateFontSizeButtons()
        selectTheme(readerModeStyle.theme)
        slider.value = Float(UIScreen.main.brightness)
    }

    // MARK: - Applying Theme
    func applyTheme() {
        fontTypeRow.backgroundColor = Theme.tableView.rowBackground
        fontSizeRow.backgroundColor = Theme.tableView.rowBackground
        brightnessRow.backgroundColor = Theme.tableView.rowBackground
        fontSizeLabel.textColor = Theme.tableView.rowText
        fontTypeButtons.forEach { button in
            button.setTitleColor(Theme.tableView.rowText, for: .selected)
            button.setTitleColor(UIColor.Grey40, for: [])
        }
        fontSizeButtons.forEach { button in
            button.setTitleColor(Theme.tableView.rowText, for: .normal)
            button.setTitleColor(Theme.tableView.disabledRowText, for: .disabled)
        }
        separatorLines.forEach { line in
            line.backgroundColor = Theme.tableView.separator
        }
    }

    func applyTheme(_ preferences: Prefs, contentScript: TabContentScript) {
        let readerPreferences = preferences.dictionaryForKey(ReaderModeProfileKeyStyle) ?? DefaultReaderModeStyle.encodeAsDictionary()
        guard let readerMode = contentScript as? ReaderMode, var style = ReaderModeStyle(dict: readerPreferences) else { return }

        style.ensurePreferredColorThemeIfNeeded()
        readerMode.style = style
    }

    /// Setup constraints for a row of buttons. Left to right. They are all given the same width.
    fileprivate func setupButtons(_ buttons: [UIButton], inRow row: UIView, action: Selector) {
        for (idx, button) in buttons.enumerated() {
            row.addSubview(button)
            button.addTarget(self, action: action, for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.top.equalTo(row.snp.top)
                if idx == 0 {
                    make.left.equalTo(row.snp.left)
                } else {
                    make.left.equalTo(buttons[idx - 1].snp.right)
                }
                make.bottom.equalTo(row.snp.bottom)
                make.width.equalTo(self.preferredContentSize.width / CGFloat(buttons.count))
            }
        }
    }

    @objc func changeFontType(_ button: FontTypeButton) {
        selectFontType(button.fontType)
        delegate?.readerModeStyleViewController(self,
                                                didConfigureStyle: readerModeStyle,
                                                isUsingUserDefinedColor: isUsingUserDefinedColor)
    }

    fileprivate func selectFontType(_ fontType: ReaderModeFontType) {
        readerModeStyle.fontType = fontType
        for button in fontTypeButtons {
            button.isSelected = button.fontType.isSameFamily(fontType)
        }
        for button in themeButtons {
            button.fontType = fontType
        }
        fontSizeLabel.fontType = fontType
    }

    @objc func changeFontSize(_ button: FontSizeButton) {
        switch button.fontSizeAction {
        case .smaller:
            readerModeStyle.fontSize = readerModeStyle.fontSize.smaller()
        case .bigger:
            readerModeStyle.fontSize = readerModeStyle.fontSize.bigger()
        case .reset:
            readerModeStyle.fontSize = ReaderModeFontSize.defaultSize
        }
        updateFontSizeButtons()

        delegate?.readerModeStyleViewController(self,
                                                didConfigureStyle: readerModeStyle,
                                                isUsingUserDefinedColor: isUsingUserDefinedColor)
    }

    fileprivate func updateFontSizeButtons() {
        for button in fontSizeButtons {
            switch button.fontSizeAction {
            case .bigger:
                button.isEnabled = !readerModeStyle.fontSize.isLargest()
            case .smaller:
                button.isEnabled = !readerModeStyle.fontSize.isSmallest()
            case .reset:
                break
            }
        }
    }

    @objc func changeTheme(_ button: ThemeButton) {
        selectTheme(button.theme)
        isUsingUserDefinedColor = true
        delegate?.readerModeStyleViewController(self,
                                                didConfigureStyle: readerModeStyle,
                                                isUsingUserDefinedColor: true)
    }

    fileprivate func selectTheme(_ theme: ReaderModeTheme) {
        readerModeStyle.theme = theme
    }

    @objc func changeBrightness(_ slider: UISlider) {
        UIScreen.main.brightness = CGFloat(slider.value)
    }
}

// MARK: -

class FontTypeButton: UIButton {
    var fontType: ReaderModeFontType = .sansSerif

    convenience init(fontType: ReaderModeFontType) {
        self.init(frame: .zero)
        self.fontType = fontType
        setTitleColor(ReaderModeStyleViewControllerUX.FontTypeTitleSelectedColor, for: .selected)
        setTitleColor(ReaderModeStyleViewControllerUX.FontTypeTitleNormalColor, for: [])
        backgroundColor = ReaderModeStyleViewControllerUX.FontTypeRowBackground
        accessibilityHint = Strings.Accessibility.ReaderMode.ChangesFontType
        switch fontType {
        case .sansSerif,
             .sansSerifBold:
            setTitle(Strings.ReaderMode.SansSerif, for: [])
            let f = UIFont(name: "GillSans", size: DynamicFontHelper.defaultHelper.ReaderStandardFontSize)
            titleLabel?.font = f
        case .serif,
             .serifBold:
            setTitle(Strings.ReaderMode.Serif, for: [])
            let f = UIFont(name: "Georgia", size: DynamicFontHelper.defaultHelper.ReaderStandardFontSize)
            titleLabel?.font = f
        }
    }
}

// MARK: -

enum FontSizeAction {
    case smaller
    case reset
    case bigger
}

class FontSizeButton: UIButton {
    var fontSizeAction: FontSizeAction = .bigger

    convenience init(fontSizeAction: FontSizeAction) {
        self.init(frame: .zero)
        self.fontSizeAction = fontSizeAction

        setTitleColor(ReaderModeStyleViewControllerUX.FontSizeButtonTextColorEnabled, for: .normal)
        setTitleColor(ReaderModeStyleViewControllerUX.FontSizeButtonTextColorDisabled, for: .disabled)

        switch fontSizeAction {
        case .smaller:
            let smallerFontLabel = Strings.ReaderMode.Dash
            let smallerFontAccessibilityLabel = Strings.Accessibility.ReaderMode.DecreaseTextSize
            setTitle(smallerFontLabel, for: [])
            accessibilityLabel = smallerFontAccessibilityLabel
        case .bigger:
            let largerFontLabel = Strings.ReaderMode.Plus
            let largerFontAccessibilityLabel = Strings.Accessibility.ReaderMode.IncreaseTextSize
            setTitle(largerFontLabel, for: [])
            accessibilityLabel = largerFontAccessibilityLabel
        case .reset:
            accessibilityLabel = Strings.Accessibility.ReaderMode.ResetFontSize
        }

        // Does this need to change with the selected font type? Not sure if makes sense for just +/-
        titleLabel?.font = UIFont(name: "GillSans", size: DynamicFontHelper.defaultHelper.ReaderBigFontSize)
    }
}

// MARK: -

class FontSizeLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let fontSizeLabel = Strings.ReaderMode.Aa
        text = fontSizeLabel
        isAccessibilityElement = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var fontType: ReaderModeFontType = .sansSerif {
        didSet {
            switch fontType {
            case .sansSerif, .sansSerifBold:
                font = UIFont(name: "GillSans", size: DynamicFontHelper.defaultHelper.ReaderBigFontSize)
            case .serif, .serifBold:
                font = UIFont(name: "Georgia", size: DynamicFontHelper.defaultHelper.ReaderBigFontSize)
            }
        }
    }
}

// MARK: -

class ThemeButton: UIButton {
    var theme: ReaderModeTheme!

    convenience init(theme: ReaderModeTheme) {
        self.init(frame: .zero)
        self.theme = theme

        setTitle(theme.rawValue, for: [])

        accessibilityHint = Strings.Accessibility.ReaderMode.ChangesColorTheme

        switch theme {
        case .light:
            setTitle(Strings.ReaderMode.Light, for: [])
            setTitleColor(ReaderModeStyleViewControllerUX.ThemeTitleColorLight, for: .normal)
            backgroundColor = ReaderModeStyleViewControllerUX.ThemeBackgroundColorLight
        case .dark:
            setTitle(Strings.ReaderMode.Dark, for: [])
            setTitleColor(ReaderModeStyleViewControllerUX.ThemeTitleColorDark, for: [])
            backgroundColor = ReaderModeStyleViewControllerUX.ThemeBackgroundColorDark
        case .sepia:
            setTitle(Strings.ReaderMode.Sepia, for: [])
            setTitleColor(ReaderModeStyleViewControllerUX.ThemeTitleColorSepia, for: .normal)
            backgroundColor = ReaderModeStyleViewControllerUX.ThemeBackgroundColorSepia
        }
    }

    var fontType: ReaderModeFontType = .sansSerif {
        didSet {
            switch fontType {
            case .sansSerif, .sansSerifBold:
                titleLabel?.font = UIFont(name: "GillSans", size: DynamicFontHelper.defaultHelper.ReaderStandardFontSize)
            case .serif, .serifBold:
                titleLabel?.font = UIFont(name: "Georgia", size: DynamicFontHelper.defaultHelper.ReaderStandardFontSize)
            }
        }
    }
}
