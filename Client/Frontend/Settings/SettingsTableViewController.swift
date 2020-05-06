/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import UIKit

struct SettingsUX {
    static let TableViewHeaderFooterHeight = CGFloat(44)

}

extension UILabel {
    // iOS bug: NSAttributed string color is ignored without setting font/color to nil
    func assign(attributed: NSAttributedString?) {
        guard let attributed = attributed else { return }
        let attribs = attributed.attributes(at: 0, effectiveRange: nil)
        if attribs[NSAttributedString.Key.foregroundColor] == nil {
            // If the text color attribute isn't set, use the table view row text color.
            textColor = Theme.tableView.rowText
        } else {
            textColor = nil
        }
        attributedText = attributed
    }
}

// A base setting class that shows a title. You probably want to subclass this, not use it directly.
class Setting: NSObject {
    fileprivate var _title: NSAttributedString?
    fileprivate var _footerTitle: NSAttributedString?
    fileprivate var _cellHeight: CGFloat?
    fileprivate var _image: UIImage?

    weak var delegate: SettingsDelegate?

    // The url the SettingsContentViewController will show, e.g. Licenses and Privacy Policy.
    var url: URL? { return nil }

    // The title shown on the pref.
    var title: NSAttributedString? { return _title }
    var footerTitle: NSAttributedString? { return _footerTitle }
    var cellHeight: CGFloat? { return _cellHeight}
    fileprivate(set) var accessibilityIdentifier: String?

    // An optional second line of text shown on the pref.
    var status: NSAttributedString? { return nil }

    // Whether or not to show this pref.
    var hidden: Bool { return false }

    var style: UITableViewCell.CellStyle { return .subtitle }

    var accessoryType: UITableViewCell.AccessoryType { return .none }

    var textAlignment: NSTextAlignment { return .natural }

    var image: UIImage? { return _image }

    fileprivate(set) var enabled: Bool = true

    // Called when the cell is setup. Call if you need the default behaviour.
    func onConfigureCell(_ cell: ThemedTableViewCell) {
        cell.detailLabel.assign(attributed: status)
        cell.detailLabel.attributedText = status
        cell.detailLabel.numberOfLines = 0
        cell.titleLabel.assign(attributed: title)
        cell.titleLabel.textAlignment = textAlignment
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.lineBreakMode = .byTruncatingTail
        cell.accessoryType = accessoryType
        cell.accessoryView = nil
        cell.selectionStyle = enabled ? .default : .none
        cell.accessibilityIdentifier = accessibilityIdentifier
        cell.iconImage = self.image
        if let title = title?.string {
            if let detailText = cell.detailLabel.text {
                cell.accessibilityLabel = "\(title), \(detailText)"
            } else if let status = status?.string {
                cell.accessibilityLabel = "\(title), \(status)"
            } else {
                cell.accessibilityLabel = title
            }
        }
        cell.accessibilityTraits = UIAccessibilityTraits.button
        // So that the separator line goes all the way to the left edge.
        cell.separatorInset = .zero
        cell.applyTheme()
    }

    // Called when the pref is tapped.
    func onClick(_ navigationController: UINavigationController?) { return }

    // Called when the pref is long-pressed.
    func onLongPress(_ navigationController: UINavigationController?) { return }

    // Helper method to set up and push a SettingsContentViewController
    func setUpAndPushSettingsContentViewController(_ navigationController: UINavigationController?) {
        if let url = self.url {
            let viewController = SettingsContentViewController()
            viewController.settingsTitle = self.title
            viewController.url = url
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    init(title: NSAttributedString? = nil, footerTitle: NSAttributedString? = nil, cellHeight: CGFloat? = nil, delegate: SettingsDelegate? = nil, enabled: Bool? = nil) {
        self._title = title
        self._footerTitle = footerTitle
        self._cellHeight = cellHeight
        self.delegate = delegate
        self.enabled = enabled ?? true
    }
}

// A setting in the sections panel. Contains a sublist of Settings
class SettingSection: Setting {
    fileprivate let children: [Setting]

    init(title: NSAttributedString? = nil, footerTitle: NSAttributedString? = nil, cellHeight: CGFloat? = nil, children: [Setting]) {
        self.children = children
        super.init(title: title, footerTitle: footerTitle, cellHeight: cellHeight)
    }

    var count: Int {
        var count = 0
        for setting in children where !setting.hidden {
            count += 1
        }
        return count
    }

    subscript(val: Int) -> Setting? {
        var i = 0
        for setting in children where !setting.hidden {
            if i == val {
                return setting
            }
            i += 1
        }
        return nil
    }
}

private class PaddedSwitch: UIView {
    fileprivate static let Padding: CGFloat = 8

    init(switchView: UISwitch) {
        super.init(frame: .zero)

        addSubview(switchView)

        frame.size = CGSize(width: switchView.frame.width + PaddedSwitch.Padding, height: switchView.frame.height)
        switchView.frame.origin = CGPoint(x: PaddedSwitch.Padding, y: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// A helper class for settings with a UISwitch.
// Takes and optional settingsDidChange callback and status text.
class BoolSetting: Setting {
    let prefKey: String? // Sometimes a subclass will manage its own pref setting. In that case the prefkey will be nil

    fileprivate let prefs: Prefs
    fileprivate let defaultValue: Bool
    fileprivate let settingDidChange: ((Bool) -> Void)?
    fileprivate let statusText: NSAttributedString?
    fileprivate let switchEnabled: Bool

    init(prefs: Prefs, prefKey: String? = nil, defaultValue: Bool, attributedTitleText: NSAttributedString, attributedStatusText: NSAttributedString? = nil, enabled: Bool = true, settingDidChange: ((Bool) -> Void)? = nil) {
        self.prefs = prefs
        self.prefKey = prefKey
        self.defaultValue = defaultValue
        self.settingDidChange = settingDidChange
        self.statusText = attributedStatusText
        self.switchEnabled = enabled
        super.init(title: attributedTitleText)
    }

    convenience init(prefs: Prefs, prefKey: String? = nil, defaultValue: Bool, titleText: String, statusText: String? = nil, enabled: Bool = true, settingDidChange: ((Bool) -> Void)? = nil) {
        var statusTextAttributedString: NSAttributedString?
        if let statusTextString = statusText {
            statusTextAttributedString = NSAttributedString(string: statusTextString, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.headerTextLight])
        }
        self.init(prefs: prefs, prefKey: prefKey, defaultValue: defaultValue, attributedTitleText: NSAttributedString(string: titleText, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]), attributedStatusText: statusTextAttributedString, enabled: enabled, settingDidChange: settingDidChange)
    }

    override var status: NSAttributedString? {
        return statusText
    }

    override func onConfigureCell(_ cell: ThemedTableViewCell) {
        super.onConfigureCell(cell)

        let control = UISwitchThemed()
        control.isEnabled = self.switchEnabled
        control.onTintColor = UIConstants.SystemBlueColor
        control.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        control.accessibilityIdentifier = prefKey

        displayBool(control)
        if let title = title {
            if let status = status {
                control.accessibilityLabel = "\(title.string), \(status.string)"
            } else {
                control.accessibilityLabel = title.string
            }
            cell.accessibilityLabel = nil
        }
        cell.accessoryView = PaddedSwitch(switchView: control)
        cell.selectionStyle = .none
    }

    @objc func switchValueChanged(_ control: UISwitch) {
        writeBool(control)
        settingDidChange?(control.isOn)
    }

    // These methods allow a subclass to control how the pref is saved
    func displayBool(_ control: UISwitch) {
        guard let key = prefKey else {
            control.isOn = defaultValue
            return
        }
        control.isOn = prefs.boolForKey(key) ?? defaultValue
    }

    func writeBool(_ control: UISwitch) {
        guard let key = prefKey else {
            return
        }
        prefs.setBool(control.isOn, forKey: key)
    }
}

class PrefPersister: SettingValuePersister {
    fileprivate let prefs: Prefs
    let prefKey: String

    init(prefs: Prefs, prefKey: String) {
        self.prefs = prefs
        self.prefKey = prefKey
    }

    func readPersistedValue() -> String? {
        return prefs.stringForKey(prefKey)
    }

    func writePersistedValue(value: String?) {
        if let value = value {
            prefs.setString(value, forKey: prefKey)
        } else {
            prefs.removeObjectForKey(prefKey)
        }
    }
}

class StringPrefSetting: StringSetting {
    init(prefs: Prefs, prefKey: String, defaultValue: String? = nil, placeholder: String, accessibilityIdentifier: String, settingIsValid isValueValid: ((String?) -> Bool)? = nil, settingDidChange: ((String?) -> Void)? = nil) {
        super.init(defaultValue: defaultValue, placeholder: placeholder, accessibilityIdentifier: accessibilityIdentifier, persister: PrefPersister(prefs: prefs, prefKey: prefKey), settingIsValid: isValueValid, settingDidChange: settingDidChange)
    }
}

class WebPageSetting: StringPrefSetting {
    init(prefs: Prefs, prefKey: String, defaultValue: String? = nil, placeholder: String, accessibilityIdentifier: String, settingDidChange: ((String?) -> Void)? = nil) {
        super.init(prefs: prefs,
                   prefKey: prefKey,
                   defaultValue: defaultValue,
                   placeholder: placeholder,
                   accessibilityIdentifier: accessibilityIdentifier,
                   settingIsValid: WebPageSetting.isURLOrEmpty,
                   settingDidChange: settingDidChange)
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
    }

    override func prepareValidValue(userInput value: String?) -> String? {
        guard let value = value else {
            return nil
        }
        return URIFixup.getURL(value)?.absoluteString
    }

    override func onConfigureCell(_ cell: ThemedTableViewCell) {
        super.onConfigureCell(cell)
        cell.accessoryType = .checkmark
        textField.textAlignment = .left
    }

    static func isURLOrEmpty(_ string: String?) -> Bool {
        guard let string = string, !string.isEmpty else {
            return true
        }
        return URL(string: string)?.isWebPage() ?? false
    }
}

protocol SettingValuePersister {
    func readPersistedValue() -> String?
    func writePersistedValue(value: String?)
}

/// A helper class for a setting backed by a UITextField.
/// This takes an optional settingIsValid and settingDidChange callback
/// If settingIsValid returns false, the Setting will not change and the text remains red.
class StringSetting: Setting, UITextFieldDelegate {
    var Padding: CGFloat = 15

    fileprivate let defaultValue: String?
    fileprivate let placeholder: String
    fileprivate let settingDidChange: ((String?) -> Void)?
    fileprivate let settingIsValid: ((String?) -> Bool)?
    fileprivate let persister: SettingValuePersister

    let textField = UITextField()

    init(defaultValue: String? = nil, placeholder: String, accessibilityIdentifier: String, persister: SettingValuePersister, settingIsValid isValueValid: ((String?) -> Bool)? = nil, settingDidChange: ((String?) -> Void)? = nil) {
        self.defaultValue = defaultValue
        self.settingDidChange = settingDidChange
        self.settingIsValid = isValueValid
        self.placeholder = placeholder
        self.persister = persister

        super.init()
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    override func onConfigureCell(_ cell: ThemedTableViewCell) {
        super.onConfigureCell(cell)
        if let id = accessibilityIdentifier {
            textField.accessibilityIdentifier = id + "TextField"
        }
        let placeholderColor = Theme.general.settingsTextPlaceholder
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])

        cell.tintColor = self.persister.readPersistedValue() != nil ? Theme.tableView.rowActionAccessory : UIColor.clear
        textField.textAlignment = .center
        textField.delegate = self
        textField.tintColor = Theme.tableView.rowActionAccessory
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        cell.isUserInteractionEnabled = true
        cell.accessibilityTraits = UIAccessibilityTraits.none
        cell.contentView.addSubview(textField)

        textField.font = DynamicFontHelper.defaultHelper.DefaultStandardFont

        textField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.trailing.equalTo(cell.contentView).offset(-Padding)
            make.leading.equalTo(cell.contentView).offset(Padding)
        }
        textField.text = self.persister.readPersistedValue() ?? defaultValue
        textFieldDidChange(textField)
    }

    override func onClick(_ navigationController: UINavigationController?) {
        textField.becomeFirstResponder()
    }

    fileprivate func isValid(_ value: String?) -> Bool {
        guard let test = settingIsValid else {
            return true
        }
        return test(prepareValidValue(userInput: value))
    }

    /// This gives subclasses an opportunity to treat the user input string
    /// before it is saved or tested.
    /// Default implementation does nothing.
    func prepareValidValue(userInput value: String?) -> String? {
        return value
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        let color = isValid(textField.text) ? Theme.tableView.rowText : Theme.general.destructiveRed
        textField.textColor = color
    }

    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return isValid(textField.text)
    }

    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text
        if !isValid(text) {
            return
        }
        self.persister.writePersistedValue(value: prepareValidValue(userInput: text))
        // Call settingDidChange with text or nil.
        settingDidChange?(text)
    }
}

class CheckmarkSetting: Setting {
    let onChanged: () -> Void
    let isEnabled: () -> Bool
    private let subtitle: NSAttributedString?

    override var status: NSAttributedString? {
        return subtitle
    }

    init(title: NSAttributedString, subtitle: NSAttributedString?, accessibilityIdentifier: String? = nil, isEnabled: @escaping () -> Bool, onChanged: @escaping () -> Void) {
        self.subtitle = subtitle
        self.onChanged = onChanged
        self.isEnabled = isEnabled
        super.init(title: title)
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    override func onConfigureCell(_ cell: ThemedTableViewCell) {
        super.onConfigureCell(cell)
        cell.accessoryType = .checkmark
        cell.tintColor = isEnabled() ? Theme.tableView.rowActionAccessory : UIColor.clear
    }

    override func onClick(_ navigationController: UINavigationController?) {
        // Force editing to end for any focused text fields so they can finish up validation first.
        navigationController?.view.endEditing(true)
        if !isEnabled() {
            onChanged()
        }
    }
}

/// A helper class for a setting backed by a UITextField.
/// This takes an optional isEnabled and mandatory onClick callback
/// isEnabled is called on each tableview.reloadData. If it returns
/// false then the 'button' appears disabled.
class ButtonSetting: Setting {
    var Padding: CGFloat = 8

    let onButtonClick: (UINavigationController?) -> Void
    let destructive: Bool
    let isEnabled: (() -> Bool)?

    init(title: NSAttributedString?, destructive: Bool = false, accessibilityIdentifier: String, isEnabled: (() -> Bool)? = nil, onClick: @escaping (UINavigationController?) -> Void) {
        self.onButtonClick = onClick
        self.destructive = destructive
        self.isEnabled = isEnabled
        super.init(title: title)
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    override func onConfigureCell(_ cell: ThemedTableViewCell) {
        super.onConfigureCell(cell)

        if isEnabled?() ?? true {
            cell.titleLabel.textColor = destructive ? Theme.general.destructiveRed : Theme.general.highlightBlue
        } else {
            cell.titleLabel.textColor = Theme.tableView.disabledRowText
        }
        cell.titleLabel.textAlignment = .center
        cell.accessibilityTraits = UIAccessibilityTraits.button
        cell.selectionStyle = .none
    }

    override func onClick(_ navigationController: UINavigationController?) {
        // Force editing to end for any focused text fields so they can finish up validation first.
        navigationController?.view.endEditing(true)
        if isEnabled?() ?? true {
            onButtonClick(navigationController)
        }
    }
}

@objc
protocol SettingsDelegate: AnyObject {
    func settingsOpenURLInNewTab(_ url: URL)
}

// The base settings view controller.
class SettingsTableViewController: ThemedTableViewController {

    typealias SettingsGenerator = (SettingsTableViewController, SettingsDelegate?) -> [SettingSection]

    fileprivate let Identifier = "CellIdentifier"
    fileprivate let SectionHeaderIdentifier = "SectionHeaderIdentifier"
    var settings = [SettingSection]()

    weak var settingsDelegate: SettingsDelegate?

    var profile: Profile!
    var tabManager: TabManager!

    var hasSectionSeparatorLine = true

    /// Used to calculate cell heights.
    fileprivate lazy var dummyToggleCell: UITableViewCell = {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "dummyCell")
        cell.accessoryView = UISwitchThemed()
        return cell
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(ThemedTableSectionHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect(width: view.frame.width, height: 30))
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = 44

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        tableView.addGestureRecognizer(longPressGestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applyTheme()
    }

    override func applyTheme() {
        settings = generateSettings()
        super.applyTheme()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }

    // Override to provide settings in subclasses
    func generateSettings() -> [SettingSection] {
        return []
    }

    @objc fileprivate func syncDidChangeState() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @objc fileprivate func refresh() {
        self.tableView.reloadData()
    }

    @objc func didLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: location), gestureRecognizer.state == .began else {
            return
        }

        let section = settings[indexPath.section]
        if let setting = section[indexPath.row], setting.enabled {
            setting.onLongPress(navigationController)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = settings[indexPath.section]
        if let setting = section[indexPath.row] {
            let identifier = Identifier + "_\(setting.style.rawValue)"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ThemedTableViewCell
            if cell == nil {
                cell = ThemedTableViewCell(style: setting.style, reuseIdentifier: identifier)
            }
            setting.onConfigureCell(cell!)
            cell!.backgroundColor = Theme.tableView.rowBackground
            return cell!
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = settings[section]
        return section.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderIdentifier) as? ThemedTableSectionHeaderFooterView else {
            return nil
        }

        let sectionSetting = settings[section]
        if let sectionTitle = sectionSetting.title?.string {
            headerView.titleLabel.text = sectionTitle.uppercased()
        }
        // Hide the top border for the top section to avoid having a double line at the top
        if section == 0 || !hasSectionSeparatorLine {
            headerView.showTopBorder = false
        } else {
            headerView.showTopBorder = true
        }

        headerView.applyTheme()
        return headerView
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionSetting = settings[section]
        guard let sectionFooter = sectionSetting.footerTitle?.string,
            let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderIdentifier) as? ThemedTableSectionHeaderFooterView else {
                return nil
        }
        footerView.titleLabel.text = sectionFooter
        footerView.titleAlignment = .top
        footerView.showBottomBorder = false
        footerView.applyTheme()
        return footerView
    }

    // To hide a footer dynamically requires returning nil from viewForFooterInSection
    // and setting the height to zero.
    // However, we also want the height dynamically calculated, there is a magic constant
    // for that: `UITableViewAutomaticDimension`.
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionSetting = settings[section]
        if let _ = sectionSetting.footerTitle?.string {
            return UITableView.automaticDimension
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let setting = settings[indexPath.section][indexPath.row], let height = setting.cellHeight {
            return height
        }

        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = settings[indexPath.section]
        if let setting = section[indexPath.row], setting.enabled {
            setting.onClick(navigationController)
        }
    }

}
