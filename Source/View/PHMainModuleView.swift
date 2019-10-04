//
//  PHMainModuleView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHMainModuleViewDelegate: AnyObject {

    func moduleView(_ moduleView: PHMainModuleView, didPressCell cell: PHMainModuleCollectionViewCell)
}

extension PHMainModuleViewDelegate {

    func moduleView(_ moduleView: PHMainModuleView, didPressCell cell: PHMainModuleCollectionViewCell) {}
}

class PHMainModuleView: UIView {

    weak var delegate: PHMainModuleViewDelegate?

    static let numberOfItemsInRow = 4

    let contentCollectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let sideLength = PHGlobal.screenWidth / CGFloat(numberOfItemsInRow)
        layout.itemSize = CGSize(side: sideLength)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PHMainModuleCollectionViewCell.self, forCellWithReuseIdentifier: PHMainModuleCollectionViewCell.identifier)
        view.backgroundColor = .white

        view.allowsSelection = true
        view.allowsMultipleSelection = false

        return view
    }()

    typealias Model = [PHMainModuleCollectionViewCell.CellModel]

    var models: Model! {
        didSet {
            contentCollectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentCollectionView.dataSource = self
        contentCollectionView.delegate = self

        addSubview(contentCollectionView)

        contentCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let numberOfItemsInRow = CGFloat(PHMainModuleView.numberOfItemsInRow)
        let width = contentCollectionView.frame.width
        let height = width / numberOfItemsInRow * (numberOfItemsInRow - 2)
        contentCollectionView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PHMainModuleView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHMainModuleCollectionViewCell.identifier, for: indexPath) as! PHMainModuleCollectionViewCell
        cell.model = models[indexPath.item]
        return cell
    }
}

extension PHMainModuleView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PHMainModuleCollectionViewCell else { return }
        delegate?.moduleView(self, didPressCell: cell)
    }
}
