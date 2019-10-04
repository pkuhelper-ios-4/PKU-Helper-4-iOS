//
//  PHScoreMainViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import SwiftDate

class PHScoreMainViewController: PHBaseViewController {

    static let sideSpacing = PHGlobal.font.huge.pointSize
    static let labelSpacing = PHGlobal.font.regular.pointSize
    static let nullField = PHScoreTableViewCell.nullField

    let tableView: UITableView = {
        let view = UITableView(frame: .null, style: .grouped)
        view.register(PHScoreTableViewCell.self, forCellReuseIdentifier: PHScoreTableViewCell.identifier)
        view.register(PHScoreSummaryTableViewCell.self, forCellReuseIdentifier: PHScoreSummaryTableViewCell.identifier)
        view.register(PHScoreTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: PHScoreTableViewHeaderView.identifier)
        view.register(PHScoreTableViewFooterView.self, forHeaderFooterViewReuseIdentifier: PHScoreTableViewFooterView.identifier)

        view.allowsSelection = true
        view.allowsMultipleSelection = false
        view.showsVerticalScrollIndicator = false

        let leftInset = PHScoreMainViewController.sideSpacing + PHScoreMainViewController.labelSpacing + PHScoreTableViewCell.diameterOfRound
        let rightInset = PHScoreMainViewController.sideSpacing

        view.separatorStyle = .singleLine
        view.separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)

        return view
    }()

    private let refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = .lightGray
        return refresher
    }()

    var overallScore: PHOverallScore? {
        didSet {
            guard self.overallScore != nil else { return }
            tableView.reloadData()
        }
    }
    
    /// MARK: Generate 2 dummy CourseScore for summary
    var summaryScores: [PHCourseScore] {
        return [
            PHCourseScore(name: "Average GPA", gpa: overallScore?.gpa),
            PHCourseScore(name: "ISOP GPA", gpa: overallScore?.gpaISOP),
        ]
    }

    var lastCheckTime: TimeInterval? {
        get {
            return Defaults[.lastFetchScore]
        }
        set {
            Defaults[.lastFetchScore] = newValue
        }
    }

    func updateRefresherTime() {
        guard let time = lastCheckTime else { return }
        refresher.attributedTitle = NSAttributedString(string: "Last check: \(time.secondsToRelativeDate())")
        debugPrint(refresher.attributedTitle as Any)
    }

    func updateLastCheckTime() {
        lastCheckTime = PHUtil.now()
        updateRefresherTime()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Score Report"

        tableView.dataSource = self
        tableView.delegate = self

        tableView.refreshControl = refresher

        updateRefresherTime()
        refresher.addTarget(self, action: #selector(handleRefresher(_:)), for: .valueChanged)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired() { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }

        PHBackendAPI.request(
            PHBackendAPI.Person.score(utoken: user.utoken),
            on: self,
            errorHandler: { [weak self] errcode, error in
                switch errcode {
                case .isopUnauthorized:
                    PHAlert(on: self)?.infoISOPTokenExpired()
                default:
                    PHAlert(on: self)?.backendError(error)
                }
            },
            detailHandler: { [weak self] (detail: PHV2PersonScore) in
                self?.updateLastCheckTime()
                self?.overallScore = detail.scores
            }
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showTabBar(animated: animated)
    }

    @objc func handleRefresher(_ refresher: UIRefreshControl) {
        guard let user = PHUser.default else {
            refresher.endRefreshing()
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(
            PHBackendAPI.Person.score(utoken: user.utoken),
            on: self,
            errorHandler: { [weak self] error in
                PHAlert.init(on: self)?.backendError(error)
                refresher.endRefreshing()
            },
            detailHandler: { [weak self] (detail: PHV2PersonScore) in
                refresher.endRefreshing()
                self?.updateLastCheckTime()
                self?.overallScore = detail.scores
            }
        )
    }
}

extension PHScoreMainViewController {
    
    func getSemesterScore(at section: Int) -> PHSemesterScore? {
        return overallScore?.semesterScores[safe: section]
    }
    
    func getCourseScore(at indexPath: IndexPath) -> PHCourseScore? {
        return getSemesterScore(at: indexPath.section)?.courseScores[indexPath.row]
    }
}

extension PHScoreMainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let overallScore = self.overallScore else { return 0 }
        return overallScore.semesterScores.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = getSemesterScore(at: section)?.courseScores.count {
            return count
        } else if section == tableView.lastSection! {
            return summaryScores.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let score = getSemesterScore(at: section) {
            if score.beginYear == PHSemesterScore.dummyYear
                || score.endYear == PHSemesterScore.dummyYear
                || score.semester == PHSemesterScore.dummySemester {
                return "Unknown Academic Year / Semester"
            } else {
                return "Academic Year \(score.beginYear)-\(score.endYear) Semester \(score.semester)"
            }
        } else if section == tableView.lastSection {
            return "Summary"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let score = getSemesterScore(at: section) {
            if let gpa = score.gpa {
                return String(format: "Credit: %g  GPA: %.2f", score.credit, gpa)
            } else {
                return String(format: "Credit: %g  GPA: \(PHScoreMainViewController.nullField)", score.credit)
            }

        } else if section == tableView.lastSection {
            guard let totalCredit = overallScore?.credit else { return nil }
            return String(format: "Total Credit: %g", totalCredit)
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == tableView.lastSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: PHScoreSummaryTableViewCell.identifier, for: indexPath) as! PHScoreSummaryTableViewCell
            cell.score = summaryScores[indexPath.row]
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: PHScoreTableViewCell.identifier, for: indexPath) as! PHScoreTableViewCell

        guard let score = getCourseScore(at: indexPath) else { return cell }
        cell.score = score
        return cell
    }
}

extension PHScoreMainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PHScoreTableViewHeaderView.identifier) as! PHScoreTableViewHeaderView
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: PHScoreTableViewFooterView.identifier) as! PHScoreTableViewFooterView
        footer.summaryLabel.text = self.tableView(tableView, titleForFooterInSection: section)
        return footer
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? PHScoreTableViewHeaderView else { return }
        header.textLabel?.text = nil
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footer = view as? PHScoreTableViewFooterView else { return }
        footer.textLabel?.text = nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PHGlobal.font.regular.pointSize * 3  // Refer to PHScoreTableViewCell.textLabel
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section != tableView.lastSection else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? PHScoreTableViewCell else { return }
        let detailViewController = PHScoreDetailViewController()
        detailViewController.score = cell.score
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
