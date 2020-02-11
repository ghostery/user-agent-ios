//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

private struct PhotonActionSheetCollectionCellUX {
    static let VerticalPadding: CGFloat = 10.0
    static let HorizontalPadding: CGFloat = 16.0
    static let Height: CGFloat = 50.0
    static let MaximumCellsCountInScreen: Int = 3
    static let CellName = "PhotonActionSheetCollectionCell"
}

protocol PhotonActionSheetCollectionCellDelegate: class {
    func collectionCellDidSelectItem(item: PhotonActionSheetItem)
}

public class PhotonActionSheetCollectionCell: UITableViewCell {

    weak var delegate: PhotonActionSheetCollectionCellDelegate?

    private var items: [PhotonActionSheetItem]!

    lazy private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.collectionView.register(PhotonActionSheetCollectionItemCell.self, forCellWithReuseIdentifier: PhotonActionSheetCollectionCellUX.CellName)
        self.backgroundColor = .clear
        self.contentView.addSubview(self.collectionView)
        let padding = PhotonActionSheetCollectionCellUX.HorizontalPadding
        let topPadding = PhotonActionSheetCollectionCellUX.VerticalPadding
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: topPadding, left: padding, bottom: topPadding, right: padding))
            make.height.equalTo(PhotonActionSheetCollectionCellUX.Height)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with action: PhotonActionSheetItem) {
        guard let collectionItems = action.collectionItems else {
            return
        }
        self.items = collectionItems
        self.collectionView.reloadData()
    }

}

extension PhotonActionSheetCollectionCell: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotonActionSheetCollectionCellUX.CellName, for: indexPath) as! PhotonActionSheetCollectionItemCell
        let item = self.items[indexPath.row]
        cell.configure(with: item)
        cell.tintColor = self.tintColor
        return cell
    }

}

extension PhotonActionSheetCollectionCell: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        self.delegate?.collectionCellDidSelectItem(item: item)
    }

}

extension PhotonActionSheetCollectionCell: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsCount = min(self.items.count, PhotonActionSheetCollectionCellUX.MaximumCellsCountInScreen)
        return CGSize(width: collectionView.frame.width / CGFloat(cellsCount), height: collectionView.frame.height)
    }

}
