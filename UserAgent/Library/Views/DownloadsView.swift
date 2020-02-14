//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared
import Storage

private struct DownloadsViewUX {
    static let EmptyScreenItemWidth = 170
}

struct DownloadFolder {
    static func downloadsURL() throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Downloads")
    }
}

struct DownloadedFile: Equatable {
    let path: URL
    let size: UInt64
    let lastModified: Date

    var canShowInWebView: Bool {
        return MIMEType.canShowInWebView(self.mimeType)
    }

    var filename: String {
        return self.path.lastPathComponent
    }

    var fileExtension: String {
        return self.path.pathExtension
    }

    var formattedSize: String {
        return ByteCountFormatter.string(fromByteCount: Int64(self.size), countStyle: .file)
    }

    var mimeType: String {
        return MIMEType.mimeTypeFromFileExtension(self.fileExtension)
    }

    static public func == (lhs: DownloadedFile, rhs: DownloadedFile) -> Bool {
        return lhs.path == rhs.path
    }
}

protocol DownloadsViewDocumentDelegate: AnyObject {
    func downlaodsView(wantsToPresentDocument path: URL)
}

class DownloadsView: LibraryView {

    weak var documentDelegate: DownloadsViewDocumentDelegate?

    private let cellIdentifier = "cellIdentifier"

    private var groupedDownloadedFiles = DateGroupedTableData<DownloadedFile>()
    private var fileExtensionIcons: [String: UIImage] = [:]

    override func setup() {
        super.setup()
        self.tableView.accessibilityIdentifier = "DownloadsTable"
        self.tableView.register(TwoLineTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.registerNotification()
    }

    override func reloadData() {
        self.groupedDownloadedFiles = DateGroupedTableData<DownloadedFile>()
        let downloadedFiles = self.fetchData()
        for downloadedFile in downloadedFiles {
            self.groupedDownloadedFiles.add(downloadedFile, timestamp: downloadedFile.lastModified.timeIntervalSince1970)
        }
        self.fileExtensionIcons = [:]
        self.tableView.reloadData()
        self.updateEmptyPanelState()
    }

    override func emptyMessage() -> String? {
        return Strings.DownloadsPanel.EmptyStateTitle
    }

}

// MARK: - Events
extension DownloadsView {

    @objc private func notificationReceived(_ notification: Notification) {
        DispatchQueue.main.async {
            switch notification.name {
            case .FileDidDownload, .PrivateDataClearedDownloadedFiles:
                self.reloadData()
            default:
                print("Error: Received unexpected notification \(notification.name)")
            }
        }
    }

}

// MARK: - Private methods
extension DownloadsView {

    private func registerNotification() {
        [Notification.Name.FileDidDownload, Notification.Name.PrivateDataClearedDownloadedFiles].forEach {
            NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: $0, object: nil)
        }
    }

    private func fetchData() -> [DownloadedFile] {
        var downloadedFiles: [DownloadedFile] = []
        do {
            let downloadsPath = try DownloadFolder.downloadsURL()
            let files = try FileManager.default.contentsOfDirectory(at: downloadsPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
            for file in files {
                let attributes = try FileManager.default.attributesOfItem(atPath: file.path) as NSDictionary
                let downloadedFile = DownloadedFile(path: file, size: attributes.fileSize(), lastModified: attributes.fileModificationDate() ?? Date())
                downloadedFiles.append(downloadedFile)
            }
        } catch let error {
            print("Unable to get files in Downloads folder: \(error.localizedDescription)")
            return []
        }
        return downloadedFiles.sorted(by: { a, b -> Bool in
            return a.lastModified > b.lastModified
        })
    }

    private func deleteDownloadedFile(_ downloadedFile: DownloadedFile) -> Bool {
        do {
            try FileManager.default.removeItem(at: downloadedFile.path)
            return true
        } catch let error {
            print("Unable to delete downloaded file: \(error.localizedDescription)")
        }
        return false
    }

    private func shareDownloadedFile(_ downloadedFile: DownloadedFile, indexPath: IndexPath) {
        let helper = ShareExtensionHelper(url: downloadedFile.path, tab: nil)
        let controller = helper.createActivityViewController { completed, activityType in
            print("Shared downloaded file: \(completed)")
        }
        if let popoverPresentationController = controller.popoverPresentationController {
            guard let tableViewCell = tableView.cellForRow(at: indexPath) else {
                print("Unable to get table view cell at index path: \(indexPath)")
                return
            }
            popoverPresentationController.sourceView = tableViewCell
            popoverPresentationController.sourceRect = tableViewCell.bounds
            popoverPresentationController.permittedArrowDirections = .any
        }
        self.delegate?.library(wantsToPresent: controller)
    }

    private func iconForFileExtension(_ fileExtension: String) -> UIImage? {
        if let icon = self.fileExtensionIcons[fileExtension] {
            return icon
        }
        guard let icon = self.roundRectImageWithLabel(fileExtension, width: 29, height: 29) else {
            return nil
        }
        self.fileExtensionIcons[fileExtension] = icon
        return icon
    }

    private func roundRectImageWithLabel(_ label: String, width: CGFloat, height: CGFloat, radius: CGFloat = 5.0, strokeWidth: CGFloat = 1.0, strokeColor: UIColor = Theme.homePanel.downloadedFileIcon, fontSize: CGFloat = 9.0) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(strokeColor.cgColor)
        let rect = CGRect(x: strokeWidth / 2, y: strokeWidth / 2, width: width - strokeWidth, height: height - strokeWidth)
        let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        bezierPath.lineWidth = strokeWidth
        bezierPath.stroke()
        let attributedString = NSAttributedString(string: label, attributes: [.baselineOffset: -(strokeWidth * 2), .font: UIFont.systemFont(ofSize: fontSize), .foregroundColor: strokeColor])
        let stringHeight: CGFloat = fontSize * 2
        let stringWidth = attributedString.boundingRect(with: CGSize(width: width, height: stringHeight), options: .usesLineFragmentOrigin, context: nil).size.width
        attributedString.draw(at: CGPoint(x: (width - stringWidth) / 2 + strokeWidth, y: (height - stringHeight) / 2 + strokeWidth))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    private func updateEmptyPanelState() {
        if self.groupedDownloadedFiles.isEmpty {
            if self.emptyStateOverlayView.superview == nil {
                self.tableView.tableFooterView = self.emptyStateOverlayView
            }
        } else {
            self.tableView.alwaysBounceVertical = true
            self.tableView.tableFooterView = UIView()
        }
    }

    private func downloadedFileForIndexPath(_ indexPath: IndexPath) -> DownloadedFile? {
        let downloadedFilesInSection = self.groupedDownloadedFiles.itemsForSection(indexPath.section)
        return downloadedFilesInSection[safe: indexPath.row]
    }

    private func configureDownloadedFile(_ cell: UITableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        if let downloadedFile = self.downloadedFileForIndexPath(indexPath), let cell = cell as? TwoLineTableViewCell {
            cell.setLines(downloadedFile.filename, detailText: downloadedFile.formattedSize)
            cell.imageView?.image = self.iconForFileExtension(downloadedFile.fileExtension)
        }
        return cell
    }

}

// MARK: - Table view dataSource
extension DownloadsView {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return LibrarySection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupedDownloadedFiles.numberOfItemsForSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! TwoLineTableViewCell
        return self.configureDownloadedFile(cell, for: indexPath)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard self.groupedDownloadedFiles.numberOfItemsForSection(section) > 0 else {
            return nil
        }
        return LibrarySection(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.groupedDownloadedFiles.numberOfItemsForSection(section) > 0 else {
            return 0
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

}

// MARK: - Table view delegate
extension DownloadsView {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteTitle = Strings.DownloadsPanel.DeleteTitle
        let shareTitle = Strings.DownloadsPanel.ShareTitle
        let delete = UITableViewRowAction(style: .destructive, title: deleteTitle, handler: { (action, indexPath) in
            if let downloadedFile = self.downloadedFileForIndexPath(indexPath) {
                if self.deleteDownloadedFile(downloadedFile) {
                    self.tableView.beginUpdates()
                    self.groupedDownloadedFiles.remove(downloadedFile)
                    self.tableView.deleteRows(at: [indexPath], with: .right)
                    self.tableView.endUpdates()
                    self.updateEmptyPanelState()
                }
            }
        })
        let share = UITableViewRowAction(style: .normal, title: shareTitle, handler: { (action, indexPath) in
            if let downloadedFile = self.downloadedFileForIndexPath(indexPath) {
                self.shareDownloadedFile(downloadedFile, indexPath: indexPath)
            }
        })
        share.backgroundColor = self.tintColor
        return [delete, share]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let downloadedFile = self.downloadedFileForIndexPath(indexPath) {
            if downloadedFile.mimeType == MIMEType.Calendar {
                self.documentDelegate?.downlaodsView(wantsToPresentDocument: downloadedFile.path)
                return
            }
            guard downloadedFile.canShowInWebView else {
                self.shareDownloadedFile(downloadedFile, indexPath: indexPath)
                return
            }
            self.delegate?.library(didSelectURL: downloadedFile.path, visitType: .typed)
        }
    }

}
