//
//  PHCTCalendarExportViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftDate
import SwiftyUserDefaults
import EventKit

class PHCTCalendarExportViewController: PHCTCalendarBaseClassListViewController {

    fileprivate lazy var rightBarButtonItemsNormal: [UIBarButtonItem] = {
        let itemSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(navBarSaveButtonTapped(_:)))
        return [itemSave]
    }()

    fileprivate lazy var rightBarButtonItemsOnEditing: [UIBarButtonItem] = {
        let itemDeleteAllSelected = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(navBarDeleteAllSelectedEventsButtonTapped(_:)))
        let itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(navBarDoneButtonTapped(_:)))
        return [itemDone, itemDeleteAllSelected]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Export To Calendar"

        navigationItem.rightBarButtonItems = rightBarButtonItemsNormal

        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = true

        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressTableView(_:))))

        setupEvents()
    }

    func setupEvents() {
        guard let semesterBeginning = getSemesterBeginning() else {
            alertSemesterBeginningNotSet { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }

        self.isNavigationBarNetworkActivityIndicatorVisable = true

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            let events = Defaults[.courseTableCourses].flatMap { course -> [EKEvent] in

                let classes = course.classes.flatMap { class_ -> [PHClass] in
                    switch class_.week {
                    case .every, .odd, .dual:
                        return class_.toClassesWithSpecificWeeks(includeExamWeeks: false)!
                    case .week0:
                        return []
                    default:
                        return [class_]
                    }
                }

                let events: [EKEvent] = classes.compactMap { class_ in
                    guard let intWeek = class_.week.weekday else { return nil }
                    let weekday = class_.weekday
                    let date = semesterBeginning + (intWeek - 1).weeks + (weekday - 1).days

                    guard let start = class_.startDate.dateBySet([.year: date.year, .month: date.month, .day: date.day]) else { return nil }
                    guard let end = class_.endDate.dateBySet([.year: date.year, .month: date.month, .day: date.day]) else { return nil }

                    let event = PHEventManager.default.create()
                    event.timeZone = PHGlobal.regionBJ.timeZone
                    event.title = course.name
                    event.location = class_.classroom
                    event.startDate = start.date
                    event.endDate = end.date
                    return event
                }

                return events
            }

            strongSelf.setEvents(events)
            strongSelf.isNavigationBarNetworkActivityIndicatorVisable = false
        }
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

    @objc func navBarDeleteAllSelectedEventsButtonTapped(_ item: UIBarButtonItem) {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        guard indexPaths.count > 0 else { return }
        let selectedEvents = indexPaths.map { events[$0.row] }

        events.removeAll(selectedEvents)
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPaths, with: .middle)
        tableView.endUpdates()
    }

    @objc func navBarDoneButtonTapped(_ item: UIBarButtonItem) {
        guard tableView.isEditing else { return }
        tableView.setEditing(false, animated: true)
        navigationItem.setRightBarButtonItems(rightBarButtonItemsNormal, animated: true)
    }

    @objc func navBarSaveButtonTapped(_ item: UIBarButtonItem) {
        PHEventManager.default.checkAccess(on: self) { [weak self] (granted, status) in
            guard granted else { return }
            guard let strongSelf = self else { return }
            guard let semesterBeginning = strongSelf.getSemesterBeginning() else { return }
            guard let calendar = PHEventManager.default.getCalendarAndSaveIfNeeded(on: strongSelf) else { return }

            // the save as manage view controller
            let start = semesterBeginning.date - 2.years
            let end = semesterBeginning.date + 2.years

            strongSelf.isNavigationBarNetworkActivityIndicatorVisable = true

            let existedEvents = PHEventManager.default.getEvents(from: start, to: end, in: [calendar])

            do {
                for event in strongSelf.events {
                    guard !existedEvents.contains(where: { $0.isSameClass(with: event) }) else { continue }
                    event.calendar = calendar
                    try PHEventManager.default.save(event, commit: false)
                }
                try PHEventManager.default.commit()
            } catch {
                PHAlert(on: strongSelf)?.error(error: error)
                return
            }

            strongSelf.isNavigationBarNetworkActivityIndicatorVisable = false
            strongSelf.navigationController?.popViewController(animated: true)
        }
    }
}

extension PHCTCalendarExportViewController {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            events.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
        default:
            break
        }
    }
}
