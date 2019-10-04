//
//  PHCTCalendarManageViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import EventKit
import SwiftDate
import PopupDialog

class PHCTCalendarManageViewController: PHCTCalendarBaseClassListViewController {

    fileprivate lazy var rightBarButtonItemsNormal: [UIBarButtonItem] = {
        let itemDeleteAll = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(navBarDeleteAllButtonTapped(_:)))
        let itemManage = UIBarButtonItem(image: R.image.navbar.gear(), style: .plain, target: self, action: #selector(navBarManageButtonTapped(_:)))
        return [itemManage, itemDeleteAll]
    }()

    fileprivate lazy var rightBarButtonItemsOnEditing: [UIBarButtonItem] = {
        let itemDeleteAllSelected = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(navBarDeleteAllSelectedEventsButtonTapped(_:)))
        let itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(navBarDoneButtonTapped(_:)))
        return [itemDone, itemDeleteAllSelected]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Manage Calendar"

        navigationItem.rightBarButtonItems = rightBarButtonItemsNormal

        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = true

        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressTableView(_:))))

        setupEvents()
    }

    func setupEvents() {
        guard let calendar = PHEventManager.default.getCalendar() else {
            alertCalendarNotFound { [weak self] in
                debugPrint("popviewcontroller \(self as Any)")
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }

        guard let semesterBeginning = getSemesterBeginning() else {
            alertSemesterBeginningNotSet { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }

        // predicateForEvents:
        // this method matches only those events within a four year time span. If the date range between startDate and endDate is greater than four years, it is shortened to the first four years.
        let start = semesterBeginning.date - 2.years
        let end = semesterBeginning.date + 2.years

        self.isNavigationBarNetworkActivityIndicatorVisable = true

        PHEventManager.default.checkAccess(on: self) { [weak self] (granted, status) in
            guard granted else { return }
            guard let strongSelf = self else { return }

            strongSelf.isNavigationBarNetworkActivityIndicatorVisable = true

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }

                let events = PHEventManager.default.getEvents(from: start, to: end, in: [calendar]).sortedClassEvents()
                strongSelf.setEvents(events)
                strongSelf.isNavigationBarNetworkActivityIndicatorVisable = false
            }
        }
    }

    @objc func navBarDeleteAllButtonTapped(_ item: UIBarButtonItem) {
        guard let calendar = PHEventManager.default.getCalendar() else {
            alertCalendarNotFound { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }

        let popup = PopupDialog(title: "Delete Course Table Calendar",
                                message: "All \(events.count) events on \(calendar.title) will be permanently deleted.",
                                image: PHAlert.infoHeaderImage,
                                buttonAlignment: .horizontal,
                                transitionStyle: .fadeIn)

        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        let okButton = DefaultButton(title: "OK") { [weak self] in
            guard let strongSelf = self else { return }
            do {
                try PHEventManager.default.deleteCalendar(calendar)
            } catch {
                PHAlert(on: strongSelf)?.error(error: error)
                return
            }
            strongSelf.navigationController?.popViewController(animated: true)
        }

        popup.addButtons([okButton, cancelButton])
        present(popup, animated: true, completion: nil)
    }

    @objc func navBarDeleteAllSelectedEventsButtonTapped(_ item: UIBarButtonItem) {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        guard indexPaths.count > 0 else { return }
        let selectedEvents = indexPaths.map { events[$0.row] }

        let popup = PopupDialog(title: "Delete Events",
                                message: "All \(selectedEvents.count) selected events will be permanently deleted.",
                                image: PHAlert.infoHeaderImage,
                                buttonAlignment: .horizontal,
                                transitionStyle: .fadeIn)

        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        let okButton = DefaultButton(title: "OK") { [weak self] in
            PHEventManager.default.checkAccess(on: self) { [weak self] (granted, status) in
                guard granted else { return }
                guard let strongSelf = self else { return }

                do {
                    for event in selectedEvents {
                        try PHEventManager.default.delete(event, commit: false)
                    }
                    try PHEventManager.default.commit()
                } catch {
                    PHAlert(on: strongSelf)?.error(error: error)
                    return
                }

                strongSelf.events.removeAll(selectedEvents)
                strongSelf.tableView.beginUpdates()
                strongSelf.tableView.deleteRows(at: indexPaths, with: .middle)
                strongSelf.tableView.endUpdates()
            }
        }

        popup.addButtons([okButton, cancelButton])
        present(popup, animated: true, completion: nil)
    }

    @objc func navBarManageButtonTapped(_ item: UIBarButtonItem) {
        guard !tableView.isEditing else { return }
        tableView.setEditing(true, animated: true)
        navigationItem.setRightBarButtonItems(rightBarButtonItemsOnEditing, animated: true)
    }

    @objc func navBarDoneButtonTapped(_ item: UIBarButtonItem) {
        guard tableView.isEditing else { return }
        tableView.setEditing(false, animated: true)
        navigationItem.setRightBarButtonItems(rightBarButtonItemsNormal, animated: true)
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

extension PHCTCalendarManageViewController {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        PHEventManager.default.checkAccess(on: self) { [weak self] (granted, status) in
            guard granted else { return }
            guard let strongSelf = self else { return }

            let event = strongSelf.events[indexPath.row]

            do {
                try PHEventManager.default.delete(event)
            } catch {
                PHAlert(on: self)?.error(error: error)
                return
            }

            strongSelf.events.remove(at: indexPath.row)
            strongSelf.tableView.beginUpdates()
            strongSelf.tableView.deleteRows(at: [indexPath], with: .middle)
            strongSelf.tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
