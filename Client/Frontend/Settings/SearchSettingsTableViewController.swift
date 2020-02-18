/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SDWebImage
import Shared

class SearchSettingsTableViewController: ThemedTableViewController {
    fileprivate let ItemAddCustomSearch = 2
    fileprivate let NumberOfItemsInSectionDefault = 2
    fileprivate let SectionOrder = 1
    fileprivate let NumberOfSections = 1
    fileprivate let IconSize = CGSize(width: OpenSearchEngine.PreferredIconSize, height: OpenSearchEngine.PreferredIconSize)
    fileprivate let SectionHeaderIdentifier = "SectionHeaderIdentifier"

    fileprivate var showDeletion = false

    var profile: Profile?
    var tabManager: TabManager?

    fileprivate var isEditable: Bool {
        // If the default engine is a custom one, make sure we have more than one since we can't edit the default.
        // Otherwise, enable editing if we have at least one custom engine.
        let customEngineCount = model.orderedEngines.filter({$0.isCustomEngine}).count
        return model.defaultEngine.isCustomEngine ? customEngineCount > 1 : customEngineCount > 0
    }

    var model: SearchEngines!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Strings.Settings.AdditionalSearchEngines.SectionTitle

        // To allow re-ordering the list of search engines at all times.
        tableView.isEditing = true
        // So that we push the default search engine controller on selection.
        tableView.allowsSelectionDuringEditing = true

        tableView.register(ThemedTableSectionHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderIdentifier)

        // Insert Done button if being presented outside of the Settings Nav stack
        if !(self.navigationController is ThemedNavigationController) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Strings.Settings.Search.DoneButton, style: .done, target: self, action: #selector(self.dismissAnimated))
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.Settings.Search.EditButton, style: .plain, target: self,
                                                                 action: #selector(beginEditing))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Only show the Edit button if custom search engines are in the list.
        // Otherwise, there is nothing to delete.
        navigationItem.rightBarButtonItem?.isEnabled = isEditable
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setEditing(false, animated: false)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.item
        if index < model.orderedEngines.count {
            let engine = model.orderedEngines[index]
            return self.searchEngineCell(tableView: tableView, engine: engine, index: index)
        } else {
            return self.addSearchEngineCell(tableView: tableView)
        }
    }

    private func searchEngineCell(tableView: UITableView, engine: OpenSearchEngine, index: Int) -> UITableViewCell {
        let identifier = "SearchSettingsTableViewCell"
        var cell: SearchSettingsTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "SearchSettingsTableViewCell?") as? SearchSettingsTableViewCell
        if cell == nil {
            cell = SearchSettingsTableViewCell(style: .default, reuseIdentifier: identifier)
        }

        cell.showsReorderControl = true
        let toggle = UISwitchThemed()
        toggle.onTintColor = Theme.tableView.controlTint
        toggle.tag = index
        toggle.addTarget(self, action: #selector(didToggleEngine), for: .valueChanged)
        toggle.isOn = model.isEngineEnabled(engine)
        cell.editingAccessoryView = toggle

        cell.label.text = engine.shortName
        if let url = URL(string: engine.searchTemplate.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""), url.isWebPage() {
            cell.updateLogo(url: url.absoluteString)
        }
        cell.selectionStyle = .none
        cell.separatorInset = .zero
        return cell
    }

    private func addSearchEngineCell(tableView: UITableView) -> UITableViewCell {
        let identifier = "ThemedTableViewCell"
        var cell: ThemedTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "ThemedTableViewCell?") as? ThemedTableViewCell
        if cell == nil {
            cell = ThemedTableViewCell(style: .default, reuseIdentifier: identifier)
        }

        cell.editingAccessoryType = .disclosureIndicator
        cell.accessibilityLabel = Strings.Settings.AddCustomEngine.Title
        cell.accessibilityIdentifier = "customEngineViewButton"
        cell.titleLabel.text = Strings.Settings.AddCustomEngine.ButtonTitle
        cell.separatorInset = .zero
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return NumberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.orderedEngines.count + 1
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.item == model.orderedEngines.count {
            let customSearchEngineForm = CustomSearchViewController()
            customSearchEngineForm.profile = self.profile
            customSearchEngineForm.successCallback = {
                guard let window = self.view.window else { return }
                SimpleToast().showAlertWithText(Strings.Search.ThirdPartyEngines.EngineAdded, bottomContainer: window)
            }
            navigationController?.pushViewController(customSearchEngineForm, animated: true)
        }
        return nil
    }

    // Don't show delete button on the left.
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.item == model.orderedEngines.count {
            return UITableViewCell.EditingStyle.none
        }

        let index = indexPath.item
        let engine = model.orderedEngines[index]
        return (self.showDeletion && engine.isCustomEngine) ? .delete : .none
    }

    // Don't reserve space for the delete button on the left.
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Hide a thin vertical line that iOS renders between the accessoryView and the reordering control.
        if cell.isEditing {
            for v in cell.subviews where v.classForCoder.description() == "_UITableCellVerticalSeparator" {
                v.backgroundColor = UIColor.clear
            }
        }

        // Change re-order control tint color to match app theme
        for subViewA in cell.subviews where subViewA.classForCoder.description() == "UITableViewCellReorderControl" {
            for subViewB in subViewA.subviews {
                if let imageView = subViewB as? UIImageView {
                    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                    imageView.tintColor = Theme.tableView.accessoryViewTint
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderIdentifier) as? ThemedTableSectionHeaderFooterView else {
            return nil
        }

        footerView.showBottomBorder = false
        footerView.applyTheme()
        return footerView
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.item == model.orderedEngines.count {
            return false
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt indexPath: IndexPath, to newIndexPath: IndexPath) {
        // The first engine (default engine) is not shown in the list, so the indices are off-by-1.
        let index = indexPath.item
        let newIndex = newIndexPath.item
        let engine = model.orderedEngines.remove(at: index)
        model.orderedEngines.insert(engine, at: newIndex)
        tableView.reloadData()
    }

    // Snap to first or last row of the list of engines.
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {

        //Can't drag/drop over "Add Custom Engine button"
        if sourceIndexPath.item == model.orderedEngines.count || proposedDestinationIndexPath.item == model.orderedEngines.count {
            return sourceIndexPath
        }

        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = tableView.numberOfRows(inSection: sourceIndexPath.section)
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.item
            let engine = model.orderedEngines[index]
            model.deleteCustomEngine(engine)
            tableView.deleteRows(at: [indexPath], with: .right)

            // End editing if we are no longer edit since we've deleted all editable cells.
            if !isEditable {
                finishEditing()
            }
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = true
        showDeletion = editing
        UIView.performWithoutAnimation {
            self.navigationItem.rightBarButtonItem?.title = editing ? Strings.Settings.Search.DoneButton : Strings.Settings.Search.EditButton
        }
        navigationItem.rightBarButtonItem?.isEnabled = isEditable
        navigationItem.rightBarButtonItem?.action = editing ?
            #selector(finishEditing) : #selector(beginEditing)
        tableView.reloadData()
    }
}

// MARK: - Selectors
extension SearchSettingsTableViewController {
    @objc func didToggleEngine(_ toggle: UISwitch) {
        let engine = model.orderedEngines[toggle.tag] // The tag is 1-based.
        if toggle.isOn {
            model.enableEngine(engine)
        } else {
            model.disableEngine(engine)
        }
    }

    @objc func didToggleSearchSuggestions(_ toggle: UISwitch) {
        // Setting the value in settings dismisses any opt-in.
        model.shouldShowSearchSuggestions = toggle.isOn
    }

    func cancel() {
        _ = navigationController?.popViewController(animated: true)
    }

    @objc func dismissAnimated() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func beginEditing() {
        setEditing(true, animated: false)
    }

    @objc func finishEditing() {
        setEditing(false, animated: false)
    }
}
