//
//  PHCTMainViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import PopMenu
import SwiftDate
import SwiftyUserDefaults

class PHCTMainViewController: PHBaseViewController {

    let courseTableView = PHCTCourseTableView()

    var courses: [PHCourse] = [] {
        didSet {
            courses.sortCourses()
            courseTableView.courses = courses
            Defaults[.courseTableCourses] = courses
        }
    }

    static var currentWeek: PHClass.Week?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        if Defaults[.useCustomSemesterBeginning], let date = Defaults[.customSemesterBeginning] {
            PHCTMainViewController.currentWeek = PHClass.Week(from: date)
        } else if let date = Defaults[.standardSemesterBeginning] {
            PHCTMainViewController.currentWeek = PHClass.Week(from: date)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = getTitleText()

        courseTableView.delegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.navbar.menu(), style: .plain, target: self, action: #selector(navBarMenuButtonTapped(_:)))

        view.addSubview(courseTableView)
        courseTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        courses = Defaults[.courseTableCourses]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The pop gesture must be banned here rather than viewWillAppear,
        // or the PHCTCustomCoursesViewController will not disappear correctly !!
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        showTabBar(animated: animated)
    }
}

extension PHCTMainViewController {

    func getTitleText() -> String {
        if let week = PHCTMainViewController.currentWeek {
            if week == .week0 {
                return "During holiday"
            } else if let weekday = week.weekday {
                return "Week: \(weekday)"
            }
        }
        return "Week: ?"
    }

    @objc func navBarMenuButtonTapped(_ item: UINavigationItem) {

        let manager = PopMenuManager()
        manager.popMenuDelegate = self

        manager.actions = [
            PopMenuDefaultAction(title: "Fetch from ISOP", image: R.image.download()),
            PopMenuDefaultAction(title: "Fetch from cloud", image: R.image.cloud_download()),
            PopMenuDefaultAction(title: "Manage cloud", image: R.image.database_setting()),
            PopMenuDefaultAction(title: "Export to calendar", image: R.image.export()),
            PopMenuDefaultAction(title: "Manage calendar", image: R.image.calendar()),
            PopMenuDefaultAction(title: "Custom courses", image: R.image.create_new()),
        ]

        manager.popMenuAppearance.popMenuBackgroundStyle = .dimmed(color: .black, opacity: 0.6)
        manager.popMenuAppearance.popMenuColor.backgroundColor = .solid(fill: .darkGray)
        manager.popMenuAppearance.popMenuColor.actionColor = .tint(.white)
        manager.popMenuAppearance.popMenuCornerRadius = 0
        manager.popMenuAppearance.popMenuFont = PHGlobal.font.regularBold
        manager.popMenuAppearance.popMenuActionCountForScrollable = 10

        manager.present(navItem: item, on: self, animated: true, completion: nil)
    }

    func addCourses(_ newCourses: [PHCourse]) {
        guard !newCourses.isEmpty else { return }
        var _courses = newCourses + courses // newCourses in the former
        courses = _courses.removeDuplicates()
    }
}

extension PHCTMainViewController: PHCTCourseTableViewDelegate {

    func courseTable(_ view: PHCTCourseTableView, didDyeWithLargerColorPoolSize actualColorPoolSize: Int, currentColorPoolSize: Int) {
        guard !Defaults[.courseTableDisableColorPoolSizeAlert] else { return }
        PHAlert(on: self)?.info(title: "More colors are needed",
                                message: "Your currently used color pool are too small to guarantee that the background colors between all adjacent classes are different. The size of current color pool is \(currentColorPoolSize), but at least \(actualColorPoolSize) colors are required.")
    }
}

extension PHCTMainViewController: PopMenuViewControllerDelegate {

    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        switch index {

        // Fetch from ISOP
        case 0:
            popMenuViewController.dismiss(animated: false) { [weak self] in // dismiss first, or other alert can't be presented
                self?.fetchCoursesFromISOP()
            }

        // Fetch from cloud
        case 1:
            popMenuViewController.dismiss(animated: false) { [weak self] in
                self?.fetchCoursesFromCloud()
            }

        // Manage cloud
        case 2:
            let viewController = PHCTManageCloudViewController()
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)

        // Export to calendar
        case 3:
            popMenuViewController.dismiss(animated: false) { [weak self] in // dismiss first
                let viewController = PHCTCalendarExportViewController()
                self?.navigationController?.pushViewController(viewController, animated: true)
            }

        // Manage calendar
        case 4:
            popMenuViewController.dismiss(animated: false) { [weak self] in // dismiss first
                let viewController = PHCTCalendarManageViewController()
                self?.navigationController?.pushViewController(viewController, animated: true)
            }

        // Custom courses
        case 5:
            let viewController = PHCTCustomCoursesViewController()
            viewController.delegate = self
            viewController.courses = courses
            navigationController?.pushViewController(viewController, animated: true)

        default:
            break
        }
    }
}

extension PHCTMainViewController: PHCTCustomCoursesViewControllerDelegate {

    func customCoursesViewControllerViewDidDisappear(_ viewController: PHCTCustomCoursesViewController) {
        guard navigationController?.topViewController === self else { return }
        courses = viewController.courses // trigger didSet
    }
}

extension PHCTMainViewController: PHCTManageCloudViewControllerDelegate {

    func manageCloudViewControllerViewDidDisappear(_ viewController: PHCTManageCloudViewController) {
        let deleted = viewController.deletedCourses
        courses.filter{ deleted.contains($0) }.forEach{ $0.isSync = false; $0.cid = nil }
    }
}

extension PHCTMainViewController {

    func fetchCoursesFromISOP() {
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(
            PHBackendAPI.Person.courseTable(utoken: user.utoken),
            on: self,
            errorHandler: { [weak self] errcode, error in
                switch errcode {
                case .isopUnauthorized:
                    PHAlert(on: self)?.infoISOPTokenExpired()
                default:
                    PHAlert(on: self)?.backendError(error)
                }
            },
            detailHandler: { [weak self] (detail: PHV2PersonCourseTable) in
                self?.addCourses(detail.courses)
            }
        )
    }

    func fetchCoursesFromCloud() {
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(PHBackendAPI.Cloud.getAllCourses(utoken: user.utoken), on: self) {
            [weak self] (detail: PHV2CloudCourseList) in
            guard let strongSelf = self else { return }
            let newCloudCourses = detail.courses.filter { course in
                // cid must be unique !
                return !strongSelf.courses.contains(where: { $0.cid == course.cid })
            }
            newCloudCourses.forEach { $0.isSync = true }
            self?.addCourses(newCloudCourses)
        }
    }
}

