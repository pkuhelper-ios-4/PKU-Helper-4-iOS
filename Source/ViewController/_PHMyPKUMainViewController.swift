//
//  PHMyPKUMainViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit
import SafariServices

class PHMyPKUMainViewController: PHBaseViewController {

    static let shared = PHMyPKUMainViewController()

    static let numberOfItemsInRow = 4

    let collectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let sideLength = PHGlobal.screenWidth / CGFloat(PHMyPKUMainViewController.numberOfItemsInRow)
        layout.itemSize = CGSize(width: sideLength, height: sideLength + PHGlobal.font.regular.pointSize * 2)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PHMyPKUCollectionViewCell.self, forCellWithReuseIdentifier: PHMyPKUCollectionViewCell.identifier)
        view.backgroundColor = .clear

        return view
    }()

    private lazy var dataSource: [ItemModel] = CollectionKeys.populate()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "My PKU"

        view.backgroundColor = .white

        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


extension PHMyPKUMainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHMyPKUCollectionViewCell.identifier, for: indexPath) as! PHMyPKUCollectionViewCell

        let model = dataSource[indexPath.item]

        cell.id = indexPath.item
        cell.titleLabel.text = model[CollectionKeys.Title]
        cell.iconImageView.image = getIconImage(model: model)
        bindTapGesture(cell, model: model)

        return cell
    }
}

extension PHMyPKUMainViewController: UICollectionViewDelegate {

}

extension PHMyPKUMainViewController {

    @objc func itemPKUWiFiTapped() {
        let safari = SFSafariViewController(url: URL(string: "https://its.pku.edu.cn/")!)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
//        let viewController = PHWebBrowserViewController(title: "PKU Wi-Fi",
//                                                        url: URL(string: "https://its.pku.edu.cn/")!)
//        navigationController?.pushViewController(safari, animated: true)
    }

    @objc func itemPKUEmailTapped() {
        let safari = SFSafariViewController(url: URL(string: "https://mail.pku.edu.cn/coremail/hxphone/index.html")!)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
//        let viewController = PHWebBrowserViewController(title: "PKU Email",
//                                                        url: URL(string: "https://mail.pku.edu.cn/coremail/hxphone/index.html")!)
//        navigationController?.pushViewController(safari, animated: true)
    }

    @objc func itemCourseTableTapped() {
        let viewController = PHCTMainViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func itemScoreTapped() {
        let viewController = PHScoreMainViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func itemPZXYSurveyTapped() {
        let safari = SFSafariViewController(url: URL(string: "https://courses.pinzhixiaoyuan.com/")!)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
//        let viewController = PHWebBrowserViewController(title: "Course Survey",
//                                                        url: URL(string: "https://courses.pinzhixiaoyuan.com/")!)
//        navigationController?.pushViewController(safari, animated: true)
    }
}

extension PHMyPKUMainViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }
}

private extension PHMyPKUMainViewController {

    typealias ItemModel = [String: String]

    func getIconImage(model: ItemModel) -> UIImage? {
        guard let iconName = model[CollectionKeys.Icon] else { return nil }
        guard let iconImage = UIImage(named: iconName) else { return nil }
        return iconImage
    }

    func bindTapGesture(_ cell: UICollectionViewCell, model: ItemModel) {
        if let selector = model[CollectionKeys.Selector] {
            cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector(selector)))
        }
    }

    struct CollectionKeys {

        static let Title = "title"
        static let Icon = "icon"
        static let Selector = "selector"

        static func populate() -> [ItemModel] {
            return [
                [
                    CollectionKeys.Title: "PKU Wi-Fi",
                    CollectionKeys.Icon: R.image.homepage.wifi.name,
                    CollectionKeys.Selector: "itemPKUWiFiTapped",
                ],
                [
                    CollectionKeys.Title: "PKU Email",
                    CollectionKeys.Icon: R.image.homepage.email.name,
                    CollectionKeys.Selector: "itemPKUEmailTapped",
                ],
                [
                    CollectionKeys.Title: "Curriculum",
                    CollectionKeys.Icon: R.image.homepage.course_table.name,
                    CollectionKeys.Selector: "itemCourseTableTapped",
                ],
                [
                    CollectionKeys.Title: "Score",
                    CollectionKeys.Icon: R.image.homepage.score_card.name,
                    CollectionKeys.Selector: "itemScoreTapped",
                ],
                [
                    CollectionKeys.Title: "PZXY Survey",
                    CollectionKeys.Icon: R.image.homepage.pzxy_course.name,
                    CollectionKeys.Selector: "itemPZXYSurveyTapped",
                ]
            ]
        }
    }
}
**/
