//
//  PHCTCustomCoursesViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/20.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHCTCustomCoursesViewControllerDelegate: AnyObject {

    func customCoursesViewControllerViewDidDisappear(_ viewController: PHCTCustomCoursesViewController)
}

extension PHCTCustomCoursesViewControllerDelegate {

    func customCoursesViewControllerViewDidDisappear(_ viewController: PHCTCustomCoursesViewController) {}
}

class PHCTCustomCoursesViewController: PHBaseViewController {

    weak var delegate: PHCTCustomCoursesViewControllerDelegate?

    fileprivate lazy var rightBarButtonItemsOnNormal: [UIBarButtonItem] = {
        let itemAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(navBarAddButtonTapped(_:)))
        let itemManage = UIBarButtonItem(image: R.image.navbar.gear(), style: .plain, target: self, action: #selector(navBarManageButtonTapped(_:)))
        return [itemManage, itemAdd]
    }()

    fileprivate lazy var rightBarButtonItemsOnEditing: [UIBarButtonItem] = {
        let itemDeleteAllSelected = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(navBarDeleteAllSelectedCourseButtonTapped(_:)))
        let itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(navBarDoneButtonTapped(_:)))
        return [itemDone, itemDeleteAllSelected]
    }()

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(PHCTCustomCoursesTableViewCell.self, forCellReuseIdentifier: PHCTCustomCoursesTableViewCell.identifier)

        view.allowsSelection = true
        view.allowsMultipleSelection = false
        view.allowsSelectionDuringEditing = true
        view.allowsMultipleSelectionDuringEditing = true

        let sideSpacing = PHCTCustomCoursesTableViewCell.sideSpacing

        view.separatorStyle = .singleLine
        view.separatorInset = UIEdgeInsets(px: sideSpacing, py: 0)

        return view
    }()

    var courses: [PHCourse] = [] {
        didSet {
            //
            // MARK: This will cause the app when deleting rows !!!
            //
            // tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Custom Courses"

        navigationItem.rightBarButtonItems = rightBarButtonItemsOnNormal

        tableView.dataSource = self
        tableView.delegate = self

        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressTableView(_:))))

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        delegate?.customCoursesViewControllerViewDidDisappear(self)
    }
}

extension PHCTCustomCoursesViewController {

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

    @objc func navBarAddButtonTapped(_ item: UIBarButtonItem) {
        let viewController = PHCTCustomCoursesAddCourseViewController()
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func navBarDeleteAllSelectedCourseButtonTapped(_ item: UIBarButtonItem) {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        guard indexPaths.count > 0 else { return }
        let selectedCourses = indexPaths.map { courses[$0.row] }

        courses.removeAll(selectedCourses)
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPaths, with: .middle)
        tableView.endUpdates()
    }

    @objc func handleLongPressTableView(_ gesture: UILongPressGestureRecognizer) {
        guard !tableView.isEditing else { return }
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        if gesture.state == .recognized {
            tableView.setEditing(true, animated: true)
            navigationItem.setRightBarButtonItems(rightBarButtonItemsOnEditing, animated: true)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
}

extension PHCTCustomCoursesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PHCTCustomCoursesTableViewCell.identifier, for: indexPath) as! PHCTCustomCoursesTableViewCell

        cell.course = courses[indexPath.row]
        cell.delegate = self

        return cell
    }
}

extension PHCTCustomCoursesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PHGlobal.font.regular.pointSize * 3
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            courses.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .middle)
            self.tableView.endUpdates()
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else { return }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PHCTCustomCoursesViewController: PHCourseTableCustomCoursesTableViewCellDelegate {

    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressSyncButton button: UIButton) {
        guard !tableView.isEditing else {
            pressCell(cell)
            return
        }
        guard let course = cell.course else { return }
        guard !course.isSync else { return }
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(PHBackendAPI.Cloud.uploadCourse(course: course, utoken: user.utoken), on: self) {
            (detail: PHV2CloudUploadCourse) in
            course.isSync = true
            course.cid = detail.cid
            cell.course = course // trigger didSet
        }
    }

    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressVisableButton button: UIButton) {
        guard !tableView.isEditing else {
            pressCell(cell)
            return
        }
        guard let course = cell.course else { return }
        course.isVisable.toggle()
        cell.course = course // trigger didSet
    }

    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressCourseNameLabel label: UILabel) {
        guard !tableView.isEditing else {
            pressCell(cell)
            return
        }
        guard let course = cell.course else { return }
        let viewController = PHCTCustomCoursesEditCourseViewController()
        viewController.delegate = self
        viewController.originalCourse = course
        viewController.course = course.copy() as! PHCourse
        navigationController?.pushViewController(viewController, animated: true)
    }

    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressContentView view: UIView) {
        if tableView.isEditing {
            pressCell(cell)
        }
    }

    func pressCell(_ cell: PHCTCustomCoursesTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        if tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
}

extension PHCTCustomCoursesViewController: PHCTCustomCoursesEditingViewControllerDelegate {

    func editingViewControllerDidSubmitChange(_ viewController: PHCTCustomCoursesEditingBaseViewController, newCourse: PHCourse, oldCourse: PHCourse?) {
        switch viewController {
        case _ as PHCTCustomCoursesAddCourseViewController:
            newCourse.isSync = false
            courses.append(newCourse)
            tableView.reloadData()
        case _ as PHCTCustomCoursesEditCourseViewController:
            guard oldCourse != newCourse else { return }
            newCourse.isSync = false
            courses.first{ $0 === oldCourse }?.update(by: newCourse)
            tableView.reloadData()
        default:
            break
        }
    }
}
