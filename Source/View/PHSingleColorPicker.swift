//
//  PHSingleColorPicker.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/10/2.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import AudioToolbox

class PHSingleColorPicker: PHBaseColorPicker {

    let colorPoolCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(px: 0, py: sideSpacing)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PHColorPickerColorCircleCollectionViewCell.self, forCellWithReuseIdentifier: PHColorPickerColorCircleCollectionViewCell.identifier)
        view.register(PHColorPickerColorPoolCollectionViewHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PHColorPickerColorPoolCollectionViewHeaderView.identifier)

        view.backgroundColor = .white

        view.bounces = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false

        view.allowsSelection = true
        view.allowsMultipleSelection = false

        view.contentInset = UIEdgeInsets(px: sideSpacing, py: sideSpacing)
        
        return view
    }()

    var colorPool: [ColorPoolSectionModel] = [] {
        didSet {
            colorPoolCollectionView.reloadData()
            if selectedColor == nil {
                if let section = colorPool.first(where: { $0.colors.count > 0 }) {
                    selectedColor = section.colors[0]
                }
            }
        }
    }

    var selectedColor: UIColor!

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        colorPoolCollectionView.dataSource = self
        colorPoolCollectionView.delegate = self

        addSubview(colorPoolCollectionView)

        colorPoolCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // TODO: It doesn't work on iPhone SE ?
//        self.addBorder(side: .top, thickness: 0.25, color: .gray)
        colorPoolCollectionView.addBorder(side: .top, thickness: 0.25, color: .gray)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PHSingleColorPicker: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return colorPool.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPool[section].colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHColorPickerColorCircleCollectionViewCell.identifier, for: indexPath) as! PHColorPickerColorCircleCollectionViewCell
        cell.color = colorPool[indexPath.section].colors[indexPath.item]
        return cell
    }
}

extension PHSingleColorPicker: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PHColorPickerColorPoolCollectionViewHeaderView.identifier, for: indexPath) as! PHColorPickerColorPoolCollectionViewHeaderView
            header.title = colorPool[indexPath.section].title
            return header
        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PHColorPickerColorCircleCollectionViewCell else { return }
        if cell.color.rgbComponents == selectedColor.rgbComponents && !cell.isSelected {
            if collectionView.indexPathsForSelectedItems?.isEmpty ?? true {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                cell.isSelected = true // immediately trigger didSet
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return !(collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AudioServicesPlaySystemSound(1104)
        selectedColor = colorPool[indexPath.section].colors[indexPath.item]
        sendActions(for: .valueChanged)
    }
}

extension PHSingleColorPicker: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(side: PHBaseColorPicker.itemSideLength)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: PHBaseColorPicker.itemSideLength * 0.8)
    }
}

