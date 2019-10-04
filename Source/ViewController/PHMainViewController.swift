//
//  PHMainViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SafariServices
import SwiftyUserDefaults


class PHMainViewController: PHBaseViewController {

    static let shared = PHMainViewController()

    static let viewSpacing = PHGlobal.font.regular.pointSize

    let userView = PHMainUserView()
    let statusView = PHMainStatusView()
    let moduleView = PHMainModuleView()

    var user: PHUser? {
        didSet {
            userView.user = user
        }
    }

    var statusDataSource: PHMainStatusView.Model! {
        didSet {
            statusView.models = statusDataSource
        }
    }

    var moduleDataSource: PHMainModuleView.Model! {
        didSet {
            moduleView.models = moduleDataSource
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "PKU Helper"

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.navbar.gear(), style: .plain, target: self, action: #selector(navBarSettingButtonTapped))

        view.backgroundColor = UIColor.groupTableViewBackground

        userView.delegate = self
        statusView.delegate = self
        moduleView.delegate = self

        user = PHUser.default
        statusDataSource = populateStatusDataSource()
        moduleDataSource = populateModuleDataSource()

        let viewSpacing = PHMainViewController.viewSpacing

        view.addSubviews([userView, statusView, moduleView])

        userView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(PHGlobal.topBarsHeight)
            make.left.right.equalToSuperview()
        }

        statusView.snp.makeConstraints { make in
            make.top.equalTo(userView.snp.bottom).offset(viewSpacing)
            make.left.right.equalToSuperview()
        }

        moduleView.snp.makeConstraints { make in
            make.top.equalTo(statusView.snp.bottom).offset(viewSpacing)
            make.left.right.bottom.equalToSuperview()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUserLogin(_:)), name: .PHUserDidLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUserLogout(_:)), name: .PHUserDidLogout, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var timeIntervalForCheckUnreadMessage: TimeInterval = 15.0
    var timeIntervalForCheckUnreadEmail: TimeInterval = 15.0
    var timeIntervalForCheckCardBalance: TimeInterval = 600.0
    var timeIntervalForCheckNetFeeBalance: TimeInterval = 3600.0 * 2
    var timeIntervalForUpdateSemesterBeginning: TimeInterval = 3600 * 24

    func startBackgroundTasks(forced: Bool) {
        if forced || PHUtil.now() - Defaults[.lastCheckUnreadMessage] > timeIntervalForCheckUnreadMessage {
            checkUnreadMessage()
        }
        if forced || PHUtil.now() - Defaults[.lastCheckUnreadEmail] > timeIntervalForCheckUnreadEmail {
            checkUnreadEmail()
        }
        if forced || PHUtil.now() - Defaults[.lastCheckCardBalance] > timeIntervalForCheckCardBalance {
            checkCardBalance()
        }
        if forced || PHUtil.now() - Defaults[.lastCheckNetFeeBalance] > timeIntervalForCheckNetFeeBalance {
            checkNetFeeBalance()
        }
        if forced || PHUtil.now() - Defaults[.lastUpdateSemesterBeginning] > timeIntervalForUpdateSemesterBeginning {
            updateSemesterBeginning()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startBackgroundTasks(forced: false)
    }

    @objc func appDidBecomeActive(_ notification: Notification) {
        startBackgroundTasks(forced: false)
    }

    @objc func didUserLogin(_ notification: Notification) {
        user = PHUser.default
        startBackgroundTasks(forced: true)
    }

    @objc func didUserLogout(_ notification: Notification) {
        user = PHUser.default
        statusDataSource = populateStatusDataSource()
        moduleDataSource = populateModuleDataSource()
    }

    func setNeedsCheckUnreadMessage() {
        Defaults[.lastCheckUnreadMessage] -= timeIntervalForCheckUnreadMessage
    }
}

extension PHMainViewController: PHMainUserViewDelegate {

    func userView(_ userView: PHMainUserView, didPressAvaterImageView avaterImageView: UIImageView) {
        userViewDidTapped()
    }

    func userView(_ userView: PHMainUserView, didPressNameLabel nameLabel: UILabel) {
        userViewDidTapped()
    }

    func userView(_ userView: PHMainUserView, didPressDepartmentLabel departmentLabel: UILabel) {
        userViewDidTapped()
    }
}

extension PHMainViewController: PHMainStatusViewDelegate {

    func statusView(_ statusView: PHMainStatusView, didPressCell cell: PHMainStatusCellView) {
        guard let status = Status(rawValue: cell.id) else { return }
        switch status {
        case .message:
            statusCellUnreadMessageTapped()
        case .email:
            statusCellUnreadEmailTapped()
        case .cardBalance:
            statusCellStudentCardBalanceTapped()
        case .netFeeBalance:
            statusCellNetFeeBalanceTapped()
        }
    }
}

extension PHMainViewController: PHMainModuleViewDelegate {

    func moduleView(_ moduleView: PHMainModuleView, didPressCell cell: PHMainModuleCollectionViewCell) {
        guard let module = Module(rawValue: cell.id) else { return }
        switch module {
        case .pkuHole:
            moduleCellPKUHoleTapped()
        case .courseTable:
            moduleCellCourseTabelTapped()
        case .score:
            moduleCellScoreTapped()
        case .pkuWiFi:
            moduleCellPKUIPGWTapped()
        case .pzxySurvey:
            moduleCellPZXYSurveyTapped()
//        case .test:
//            let vc = PHTestColorPickerViewController()
//            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension PHMainViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }
}

extension PHMainViewController {

    enum Status: Int {
        case message = 0, email, cardBalance, netFeeBalance
    }

    enum Module: Int {
        case pkuHole = 0, courseTable, score, pkuWiFi, pzxySurvey
//        case test = 99
    }

    func populateStatusDataSource() -> PHMainStatusView.Model {
        return [
            (id: Status.message.rawValue, count: Double(Defaults[.lastUnreadMessageCount]), description: "New Message"),
            (id: Status.email.rawValue, count: Double(Defaults[.lastUnreadEmailCount]), description: "New Email"),
            (id: Status.cardBalance.rawValue, count: Defaults[.lastCardBalance], description: "Card Balance"),
            (id: Status.netFeeBalance.rawValue, count: Defaults[.lastNetFeeBalance], description: "Net Fee Balance"),
        ]
    }

    func populateModuleDataSource() -> PHMainModuleView.Model {
        return [
            (id: Module.pkuHole.rawValue, title: "PKU Hole", icon: R.image.homepage.chat()!),
            (id: Module.courseTable.rawValue, title: "Course Table", icon: R.image.homepage.course_table()!),
            (id: Module.score.rawValue, title: "Score", icon: R.image.homepage.score_card()!),
            (id: Module.pkuWiFi.rawValue, title: "PKU IPGW", icon: R.image.homepage.wifi()!),
            (id: Module.pzxySurvey.rawValue, title: "PZXY Survey", icon: R.image.homepage.pzxy_course()!),
//            (id: Module.test.rawValue, title: "Test", icon: R.image.services()!),
        ]
    }
}

extension PHMainViewController {

    @objc func navBarSettingButtonTapped() {
        let viewController = PHSettingMainViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    func userViewDidTapped() {
        if let user = self.user {
            let viewController = PHUserDetailViewController()
            viewController.user = user
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            let viewController = PHUserLoginViewController()
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func statusCellUnreadMessageTapped() {
        let viewController = PHMessageMainViewController()
        navigationController?.pushViewController(viewController) { [weak self] in
            self?.setNeedsCheckUnreadMessage()
        }
    }

    func statusCellUnreadEmailTapped() {
        let safari = SFSafariViewController(url: PHURL.pkuEmailURL)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
    }

    func statusCellStudentCardBalanceTapped() {
        print("student card balance tapped")
    }

    func statusCellNetFeeBalanceTapped() {
        print("net fee balance tapped")
    }

    func moduleCellPKUHoleTapped() {
        guard let _ = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        if Defaults[.hasAgreedPKUHoleTerms] {
            let viewController = PHHoleMainViewController.shared
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            let viewController = PHHoleWelcomeViewController()
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func moduleCellCourseTabelTapped() {
        let viewController = PHCTMainViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    func moduleCellScoreTapped() {
        let viewController = PHScoreMainViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    func moduleCellPKUIPGWTapped() {
        let viewController = PHIPGWMainViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    func moduleCellPZXYSurveyTapped() {
        let safari = SFSafariViewController(url: PHURL.pzxyCourseHomeURL)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
    }
}

extension PHMainViewController: PHHoleWelcomeViewControllerDelegate {

    func welcomeViewDidDisappear(_ controller: PHHoleWelcomeViewController) {
        guard controller.hasAgreedTerms else { return }
        Defaults[.hasAgreedPKUHoleTerms] = true
        let viewController = PHHoleMainViewController.shared
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension PHMainViewController {

    func refreshStatusData() {
        statusDataSource = populateStatusDataSource()
    }
}

extension PHMainViewController {

    func checkUnreadMessage() {
        Defaults[.lastCheckUnreadMessage] = PHUtil.now() // update first
        guard let user = PHUser.default else { return }
        PHBackendAPI.request(
            PHBackendAPI.Message.personUnreadCount(utoken: user.utoken),
            on: self,
            errorHandler: { error in
                Defaults[.lastCheckUnreadMessage] = PHUtil.now()
                debugPrint(error)
            },
            detailHandler: { [weak self] (detail: PHV2MessageUnreadCount) in
                Defaults[.lastCheckUnreadMessage] = PHUtil.now()
                Defaults[.lastUnreadMessageCount] = detail.count
                self?.refreshStatusData()
            }
        )
    }

    func checkUnreadEmail() {
        Defaults[.lastCheckUnreadEmail] = PHUtil.now() // update first
        guard let user = PHUser.default else { return }
        PHBackendAPI.request(
            PHBackendAPI.Person.unreadEmail(utoken: user.utoken),
            on: self,
            errorHandler: { error in
                Defaults[.lastCheckUnreadEmail] = PHUtil.now()
                debugPrint(error)
            },
            detailHandler: { [weak self] (detail: PHV2PersonUnreadEmail) in
                Defaults[.lastCheckUnreadEmail] = PHUtil.now()
                Defaults[.lastUnreadEmailCount] = detail.count
                self?.refreshStatusData()
            }
        )
    }

    func checkCardBalance() {
        Defaults[.lastCheckCardBalance] = PHUtil.now() // update first
        guard let user = PHUser.default else { return }
        PHBackendAPI.request(
            PHBackendAPI.Person.cardBalance(utoken: user.utoken),
            on: self,
            errorHandler: { error in
                Defaults[.lastCheckCardBalance] = PHUtil.now()
                debugPrint(error)
            },
            detailHandler: { [weak self] (detail: PHV2PersonBalance) in
                Defaults[.lastCheckCardBalance] = PHUtil.now()
                Defaults[.lastCardBalance] = detail.balance
                self?.refreshStatusData()
            }
        )
    }

    func checkNetFeeBalance() {
        Defaults[.lastCheckNetFeeBalance] += timeIntervalForCheckNetFeeBalance * 0.1
        guard let user = PHUser.default else { return }
        PHBackendAPI.request(
            PHBackendAPI.Person.netBalance(utoken: user.utoken),
            on: self,
            errorHandler: { error in
                Defaults[.lastCheckNetFeeBalance] = PHUtil.now()
                debugPrint(error)
            },
            detailHandler: { [weak self] (detail: PHV2PersonBalance) in
                Defaults[.lastCheckNetFeeBalance] = PHUtil.now()
                Defaults[.lastNetFeeBalance] = detail.balance
                self?.refreshStatusData()
            }
        )
    }

    func updateSemesterBeginning() {
        Defaults[.lastUpdateSemesterBeginning] += timeIntervalForUpdateSemesterBeginning * 0.1
        PHBackendAPI.request(
            PHBackendAPI.Base.getSemesterBeginning,
            on: self,
            errorHandler: { error in
                debugPrint(error)
            },
            detailHandler: { (detail: PHV2BaseGetSemesterBeginning) in
                Defaults[.lastUpdateSemesterBeginning] = PHUtil.now()
                Defaults[.standardSemesterBeginning] = detail.date
            }
        )
    }
}


