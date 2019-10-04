//
//  PHMultiColorPicker.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import AudioToolbox

//protocol PHMultiColorPickerDelegate: AnyObject {
//
//    func colorPicker(_ picker: PHMultiColorPicker, didAddColors: [UIColor])
//    func colorPicker(_ picker: PHMultiColorPicker, didDeleteColors: [UIColor])
//}
//
//extension PHMultiColorPickerDelegate {
//
//    func colorPicker(_ picker: PHMultiColorPicker, didAddColors: [UIColor]) {}
//    func colorPicker(_ picker: PHMultiColorPicker, didDeleteColors: [UIColor]) {}
//}

class PHMultiColorPicker: PHBaseColorPicker {

//    weak var delegate: PHMultiColorPickerDelegate?

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
        view.allowsMultipleSelection = true

        view.contentInset = UIEdgeInsets(px: sideSpacing, py: sideSpacing)

        return view
    }()

    let buttonCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: sideSpacing, left: 0, bottom: sideSpacing, right: sideSpacing)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PHColorPickerButtonCollectionViewCell.self, forCellWithReuseIdentifier: PHColorPickerButtonCollectionViewCell.identifier)

        view.backgroundColor = .white

        view.bounces = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false

        view.allowsSelection = true
        view.allowsMultipleSelection = false

        return view
    }()

    let usedColorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: sideSpacing, left: sideSpacing, bottom: sideSpacing, right: 0)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PHColorPickerColorCircleCollectionViewCell.self, forCellWithReuseIdentifier: PHColorPickerColorCircleCollectionViewCell.identifier)

        view.backgroundColor = .white

        view.bounces = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false

        view.allowsSelection = true
        view.allowsMultipleSelection = true

        return view
    }()

    fileprivate lazy var collectionViews = [colorPoolCollectionView, usedColorCollectionView, buttonCollectionView]

    var colorPool: [ColorPoolSectionModel] = [] {
        didSet {
            colorPoolCollectionView.reloadData()
        }
    }


    var usedColors: [UIColor] = [] {
        didSet {
            usedColorCollectionView.reloadData()
        }
    }

    fileprivate let buttonImages: [UIImage] = [
        R.image.full.minus()!.template,
        R.image.full.add()!.template,
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        collectionViews.forEach { view in
            view.delegate = self
            view.dataSource = self
        }

        addSubviews(collectionViews)

        let sideSpacing = PHBaseColorPicker.sideSpacing
        let itemCountPerLine = PHBaseColorPicker.itemCountPerLine
        let itemSideLength = PHBaseColorPicker.itemSideLength

        usedColorCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(itemSideLength + sideSpacing * 2)
            make.width.equalTo(itemSideLength * CGFloat(itemCountPerLine - buttonImages.count) + sideSpacing)
            make.bottom.equalTo(colorPoolCollectionView.snp.top)
        }

        buttonCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalTo(usedColorCollectionView.snp.right)
            make.height.equalTo(itemSideLength + sideSpacing * 2)
            make.width.equalTo(itemSideLength * CGFloat(buttonImages.count) + sideSpacing)
            make.bottom.equalTo(colorPoolCollectionView.snp.top)
        }

        colorPoolCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

//        self.addBorder(side: .top, thickness: 0.25, color: .gray)
        [usedColorCollectionView, buttonCollectionView].forEach { view in
            view.addBorder(side: .top, thickness: 0.25, color: .gray)
            view.addBorder(side: .bottom, thickness: 0.25, color: .lightGray)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PHMultiColorPicker: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case colorPoolCollectionView:
            return colorPool.count
        default:
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case colorPoolCollectionView:
            return colorPool[section].colors.count
        case usedColorCollectionView:
            return usedColors.count
        case buttonCollectionView:
            return buttonImages.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case colorPoolCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHColorPickerColorCircleCollectionViewCell.identifier, for: indexPath) as! PHColorPickerColorCircleCollectionViewCell
            cell.color = colorPool[indexPath.section].colors[indexPath.item]
            return cell
        case usedColorCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHColorPickerColorCircleCollectionViewCell.identifier, for: indexPath) as! PHColorPickerColorCircleCollectionViewCell
            cell.color = usedColors[indexPath.item]
            return cell
        case buttonCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHColorPickerButtonCollectionViewCell.identifier, for: indexPath) as! PHColorPickerButtonCollectionViewCell
            cell.image = buttonImages[indexPath.item]
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension PHMultiColorPicker: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            switch collectionView {
            case colorPoolCollectionView:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PHColorPickerColorPoolCollectionViewHeaderView.identifier, for: indexPath) as! PHColorPickerColorPoolCollectionViewHeaderView
                header.title = colorPool[indexPath.section].title
                return header
            default:
                break
            }
        default:
            break
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AudioServicesPlaySystemSound(1104)
        switch collectionView {
        case buttonCollectionView:
            switch indexPath.item {
            case 0: // minus
                guard let indexPaths = usedColorCollectionView.indexPathsForSelectedItems else { break }
                guard indexPaths.count > 0 else { return }
                let deletedColors = indexPaths.map { usedColors[$0.item] }
                usedColors.removeAll(deletedColors)
//                delegate?.colorPicker(self, didDeleteColors: deletedColors)
                sendActions(for: .valueChanged)
            case 1: // add
                guard let indexPaths = colorPoolCollectionView.indexPathsForSelectedItems?.sorted() else { break }
                guard indexPaths.count > 0 else { return }
                let newColors = indexPaths.map { colorPool[$0.section].colors[$0.item] }
                var _usedColors = usedColors + newColors
                _usedColors.removeDuplicates()
                usedColors = _usedColors
                indexPaths.forEach { colorPoolCollectionView.deselectItem(at: $0, animated: false) }
//                delegate?.colorPicker(self, didAddColors: newColors)
                sendActions(for: .valueChanged)
            default:
                break
            }
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        AudioServicesPlaySystemSound(1104)
    }
}

extension PHMultiColorPicker: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(side: PHBaseColorPicker.itemSideLength)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch collectionView {
        case colorPoolCollectionView:
            return CGSize(width: collectionView.frame.width, height: PHBaseColorPicker.itemSideLength * 0.8)
        default:
            return .zero
        }
    }
}
