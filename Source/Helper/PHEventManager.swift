//
//  PHEventManager.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import EventKit
import UIKit
import SwiftyUserDefaults

//
// https://github.com/ThXou/Klendario/blob/master/Source/Klendario.swift
//
class PHEventManager {

    let eventStore: EKEventStore

    init(eventStore: EKEventStore? = nil) {
        self.eventStore = eventStore ?? EKEventStore()
    }

    static var `default` = PHEventManager()
}

extension PHEventManager {

    typealias AuthorizationCompletion = (_ granted: Bool, _ status: EKAuthorizationStatus) -> Void

    // MARK: authorization

    func checkAccess(
        on viewController: UIViewController? = nil,
        _ completion: AuthorizationCompletion? = nil)
    {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            completion?(true, status)
        case .notDetermined:
            eventStore.requestAccess(to: .event) { (granted, error) in
                if let error = error {
                    PHAlert(on: viewController)?.error(error: error)
                } else {
                    completion?(granted, status)
                }
            }
        case .restricted:
            PHAlert(on: viewController)?.warning(title: "Access Restricted",
                                                 message: "The authorization status can't be changed, possibly due to active restrictions such as parental controls being in place.")
        case .denied:
            PHAlert(on: viewController)?.info(title: "Access Denied",
                                              message: "PKU Helper 4 was not allowed to access your Calendar app, you need to modify the access permission in your 'Setting' app first if you want to use this function.")
        @unknown default:
            break
        }
    }

    func isAuthorized() -> Bool {
        return EKEventStore.authorizationStatus(for: .event) == .authorized
    }

    // MARK: calendar

    func getCalendar() -> EKCalendar? {
        guard let calendarIdentifier = Defaults[.courseTableCalendarIdentifier] else { return nil }
        return eventStore.calendar(withIdentifier: calendarIdentifier)
    }

    func getCalendarAndSaveIfNeeded(on viewController: UIViewController?) -> EKCalendar? {

        if let calendarIdentifier = Defaults[.courseTableCalendarIdentifier] {
            if let calendar = eventStore.calendar(withIdentifier: calendarIdentifier) {
                return calendar
            }
        }
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = "PKU Helper 4 Course Table"

        guard let source =
            eventStore.sources.first(where: { $0.sourceType == .local }) ??
            eventStore.sources.first(where: { $0.sourceType == .calDAV && $0.title == "iCloud" })
            else
        {
            PHAlert(on: viewController)?.error(message: "iCloud source / Local source for calendar is unavailable.")
            return nil
        }

        calendar.source = source

        do {
            try eventStore.saveCalendar(calendar, commit: true)
        } catch {
            PHAlert(on: viewController)?.error(error: error)
            return nil
        }

        Defaults[.courseTableCalendarIdentifier] = calendar.calendarIdentifier
        return calendar
    }

    func deleteCalendar(_ calendar: EKCalendar, commit: Bool = true) throws {
        try eventStore.removeCalendar(calendar, commit: commit)
    }

    // MARK: event

    func create() -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        // calendar of event will be set when it‘s going to be saved
        return event
    }

    func save(_ event: EKEvent, span: EKSpan = .thisEvent, commit: Bool = true) throws {
        try eventStore.save(event, span: span, commit: commit)
    }

    func delete(_ event: EKEvent, span: EKSpan = .thisEvent, commit: Bool = true) throws {
        try eventStore.remove(event, span: span, commit: commit)
    }

    func commit() throws {
        try eventStore.commit()
    }

    func reset() {
        eventStore.reset()
    }

    func getEvents(from start: Date, to end: Date, in calendars: [EKCalendar]? = nil) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        return events
    }
}
