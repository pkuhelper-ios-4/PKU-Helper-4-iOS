//
//  PHCTManageCloudViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/22.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHCTManageCloudViewControllerDelegate: AnyObject {

    func manageCloudViewControllerViewDidDisappear(_ viewController: PHCTManageCloudViewController)
}

extension PHCTManageCloudViewControllerDelegate {

    func manageCloudViewControllerViewDidDisappear(_ viewController: PHCTManageCloudViewController) {}
}

class PHCTManageCloudViewController: PHBaseViewController {

    weak var delegate: PHCTManageCloudViewControllerDelegate?

    fileprivate lazy var rightBarButtonItemsOnNormal: [UIBarButtonItem] = {
        let itemManage = UIBarButtonItem(image: R.image.navbar.gear(), style: .plain, target: self, action: #selector(navBarManageButtonTapped(_:)))
        return [itemManage]
    }()

    fileprivate lazy var rightBarButtonItemsOnEditing: [UIBarButtonItem] = {
        let itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(navBarDoneButtonTapped(_:)))
        return [itemDone]
    }()

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(PHCTManageCloudTableViewCell.self, forCellReuseIdentifier: PHCTManageCloudTableViewCell.identifier)

        view.allowsSelection = true
        view.allowsMultipleSelection = false

        let sideSpacing = PHCTManageCloudTableViewCell.sideSpacing

        view.separatorStyle = .singleLine
        view.separatorInset = UIEdgeInsets(px: sideSpacing, py: 0)

        return view
    }()

    var courses: [PHCourse] = []
    var deletedCourses: [PHCourse] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Manage Cloud"

        navigationItem.rightBarButtonItems = rightBarButtonItemsOnNormal

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        
        PHBackendAPI.request(
            PHBackendAPI.Cloud.getAllCourses(utoken: user.utoken),
            on: self)
        {
            [weak self] (detail: PHV2CloudCourseList) in
            guard let strongSelf = self else { return }
            strongSelf.courses = detail.courses.sortedCourses()
            strongSelf.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showTabBar(animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.manageCloudViewControllerViewDidDisappear(self)
    }
}

extension PHCTManageCloudViewController {

    @objc func navBarManageButtonTapped(_ item: UIBarButtonItem) {
        guard !tableView.isEditing else { return }
        tableView.setEditing(true, animated: true)
        navigationItem.setRightBarButtonItems(rightBarButtonItemsOnEditing, animated: true)
    }

    @objc func navBarDoneButtonTapped(_ item: UIBarButtonItem) {
        guard tableView.isEditing else { return }
        tableView.setEditing(false, animated: true)
        navigationItem.setRightBarButtonItems(rightBarButtonItemsOnNormal, animated: true)
    }
}

extension PHCTManageCloudViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PHCTManageCloudTableViewCell.identifier, for: indexPath) as! PHCTManageCloudTableViewCell
        cell.course = courses[indexPath.row]
        return cell
    }
}

extension PHCTManageCloudViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PHGlobal.font.regular.pointSize * 3
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let user = PHUser.default else {
                PHAlert(on: self)?.infoLoginRequired()
                return
            }
            let course = courses[indexPath.row]
            guard let cid = course.cid else { return }
            PHBackendAPI.request(
                PHBackendAPI.Cloud.deleteCourse(cid: cid, utoken: user.utoken),
                on: self)
            {
                [weak self] (_: PHV2NullDetail) in
                guard let strongSelf = self else { return }
                let deletedCourse = strongSelf.courses.remove(at: indexPath.row)
                strongSelf.deletedCourses.append(deletedCourse)
                strongSelf.tableView.beginUpdates()
                strongSelf.tableView.deleteRows(at: [indexPath], with: .middle)
                strongSelf.tableView.endUpdates()
            }
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else { return }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
