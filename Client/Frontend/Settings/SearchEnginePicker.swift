/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

class SearchEnginePicker: ThemedTableViewController {
    weak var delegate: SearchEnginePickerDelegate?
    var engines: [OpenSearchEngine]!
    var selectedSearchEngineName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Strings.Settings.Search.AdditionalSearchEngines.DefaultSearchEngine
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: Strings.General.CancelString, style: .plain, target: self, action: #selector(cancel))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return engines.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let engine = engines[indexPath.item]
        let identifier = "SearchSettingsTableViewCell"
        var cell: SearchSettingsTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? SearchSettingsTableViewCell
        if cell == nil {
            cell = SearchSettingsTableViewCell(style: .default, reuseIdentifier: identifier)
        }
        cell.label.text = engine.shortName
        cell.updateLogo(engine: engine)
        if engine.shortName == selectedSearchEngineName {
            cell.accessoryType = .checkmark
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let engine = engines[indexPath.item]
        delegate?.searchEnginePicker(self, didSelectSearchEngine: engine)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

    @objc func cancel() {
        delegate?.searchEnginePicker(self, didSelectSearchEngine: nil)
    }
}
