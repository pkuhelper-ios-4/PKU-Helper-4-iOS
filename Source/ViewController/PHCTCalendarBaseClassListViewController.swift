//
//  PHCTCalendarBaseClassListViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import EventKit
import SwiftyUserDefaults
import SwiftDate

protocol PHCTCalendarBaseClassListViewControllerDelegate: AnyObject {

}

class PHCTCalendarBaseClassListViewController: PHBaseViewController {

    weak var delegate: PHCTCalendarBaseClassListViewControllerDelegate?

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(PHCTCalendarClassListTableViewCell.self, forCellReuseIdentifier: PHCTCalendarClassListTableViewCell.identifier)

        view.allowsSelection = false
        view.allowsMultipleSelection = false

        view.separatorStyle = .singleLine

        return view
    }()

    var events: [EKEvent] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


extension PHCTCalendarBaseClassListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PHCTCalendarClassListTableViewCell.identifier, for: indexPath) as! PHCTCalendarClassListTableViewCell
        cell.event = events[indexPath.row]
        return cell
    }
}

extension PHCTCalendarBaseClassListViewController: UITableViewDelegate {

}

extension PHCTCalendarBaseClassListViewController {

    func getSemesterBeginning() -> DateInRegion? {
        if Defaults[.useCustomSemesterBeginning], let date = Defaults[.customSemesterBeginning] {
            return date.in(region: PHGlobal.regionBJ)
        } else if let date = Defaults[.standardSemesterBeginning] {
            return date.in(region: PHGlobal.regionBJ)
        } else {
            return nil
        }
    }

    func setEvents(_ events: [EKEvent]) {
        self.events = events
        tableView.reloadData()
    }

    func alertSemesterBeginningNotSet(completion: (() -> Void)? = nil) {
        PHAlert(on: self)?.warning(title: "Undefined semester beginning",
                                   message: "The beginning week of this semester is not defined. You can go to 'Settings' to maually refresh the standard semester beginning provided by PKU Helper backend, or setup a custom semseter beginning.",
                                   completion: completion)
    }

    func alertCalendarNotFound(completion: (() -> Void)? = nil) {
        PHAlert(on: self)?.info(title: "Calendar not found",
                                message: "The calendar of PKU Helper 4 course table was not found. Perhaps it hasn't been set yet or has already been deleted.",
                                completion: completion)
    }
}
