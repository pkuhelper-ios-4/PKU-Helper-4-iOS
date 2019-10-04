//
//  SwiftyUserDefaults+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import SwiftyUserDefaults
import CryptoSwift

extension DefaultsKeys {

    static let user = DefaultsKey<PHUser?>("PH_user")

    // MARK: Setting

    static var theme: DefaultsKey<PHTheme> {
        return DefaultsKey<PHTheme>("\(prefix)_theme", defaultValue: .white)
    }

    static var isDeveloperMode: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_is_developer_mode", defaultValue: false)
    }

    static var isFPSDetectorOn: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_is_FPS_detector_on", defaultValue: false)
    }

    // MARK: Main

    static var lastCheckUnreadMessage: DefaultsKey<TimeInterval> {
        return DefaultsKey<TimeInterval>("\(prefix)_last_check_unread_message", defaultValue: 0.0)
    }

    static var lastCheckUnreadEmail: DefaultsKey<TimeInterval> {
        return DefaultsKey<TimeInterval>("\(prefix)_last_check_unread_email", defaultValue: 0.0)
    }

    static var lastCheckCardBalance: DefaultsKey<TimeInterval> {
        return DefaultsKey<TimeInterval>("\(prefix)_last_check_card_balance", defaultValue: 0.0)
    }

    static var lastCheckNetFeeBalance: DefaultsKey<TimeInterval> {
        return DefaultsKey<TimeInterval>("\(prefix)_last_check_net_fee_balance", defaultValue: 0.0)
    }

    static var lastUpdateSemesterBeginning: DefaultsKey<TimeInterval> {
        return DefaultsKey<TimeInterval>("\(prefix)_last_update_semester_beginning", defaultValue: 0.0)
    }

    static var lastUnreadMessageCount: DefaultsKey<Int> {
        return DefaultsKey<Int>("\(prefix)_last_unread_message_count", defaultValue: 0)
    }

    static var lastUnreadEmailCount: DefaultsKey<Int> {
        return DefaultsKey<Int>("\(prefix)_last_unread_email_count", defaultValue: 0)
    }

    static var lastCardBalance: DefaultsKey<Double> {
        return DefaultsKey<Double>("\(prefix)_last_card_balance", defaultValue: 0.0)
    }

    static var lastNetFeeBalance: DefaultsKey<Double> {
        return DefaultsKey<Double>("\(prefix)_last_net_fee_balance", defaultValue: 0.0)
    }

    static var hasReadPrivacyPolicy: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_has_read_privacy_policy", defaultValue: false)
    }

    // MARK: IPGW

    static var lastIPGWStatus: DefaultsKey<PHIPGWStatus?> {
        return DefaultsKey<PHIPGWStatus?>("\(prefix)_last_ipgw_status")
    }

    // MARK: PKU Hole

    static var hasAgreedPKUHoleTerms: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_has_agreed_PKUHole_terms", defaultValue: false)
    }

    static var pkuHoleDefaultShowRelativeDate: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_PKUHole_default_show_relative_date", defaultValue: true)
    }

    static var pkuHoleHiddenPidsList: DefaultsKey<[Int]> {
        return DefaultsKey<[Int]>("\(prefix)_PKUHole_hidden_pids_list", defaultValue: [])
    }

    static var pkuHoleHiddenCidsList: DefaultsKey<[Int]> {
        return DefaultsKey<[Int]>("\(prefix)_PKUHole_hidden_cids_list", defaultValue: [])
    }

    static var pkuHolePostMemo: DefaultsKey<PHPostMemo?> {
        return DefaultsKey<PHPostMemo?>("\(prefix)_PKUHole_post_memo")
    }

    // MARK: Course Table

    static var standardSemesterBeginning: DefaultsKey<Date?> {
        return DefaultsKey<Date?>("\(prefix)_standard_semester_beginning")
    }

    static var customSemesterBeginning: DefaultsKey<Date?> {
        return DefaultsKey<Date?>("\(prefix)_custom_semester_beginning")
    }

    static var useCustomSemesterBeginning: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_use_custom_semester_beginning", defaultValue: false)
    }

    static var courseTableDefaultExpandedWeekdayHeader: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_course_table_default_expanded_weekday_header", defaultValue: true)
    }

    static var courseTableDefaultExpandedSideColumn: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_course_table_default_expanded_side_column", defaultValue: false)
    }

    static var courseTableCourseColumnExpandable: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_course_table_course_column_expandable", defaultValue: true)
    }

    static var courseTableDefaultExpandedTodaysCourseColumn: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_course_table_default_expanded_todays_course_column", defaultValue: true)
    }

    static var courseTableCellTextColor: DefaultsKey<UIColor?> {
        return DefaultsKey<UIColor?>("\(prefix)_course_table_cell_text_color")
    }

    static var courseTableColorPool: DefaultsKey<[UIColor]> {
        return DefaultsKey<[UIColor]>("\(prefix)_course_table_color_pool", defaultValue: [])
    }

    static var courseTableDisableColorPoolSizeAlert: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_course_table_disable_color_pool_size_alert", defaultValue: false)
    }

    static var courseTableHideOtherWeeksClasses: DefaultsKey<Bool> {
        return DefaultsKey<Bool>("\(prefix)_course_table_hide_other_weeks_classes", defaultValue: false)
    }

    static var courseTableColorForOtherWeeksClasses: DefaultsKey<UIColor?> {
        return DefaultsKey<UIColor?>("\(prefix)_course_table_color_for_other_weeks_classes")
    }

    static var courseTableUserRandomSeed: DefaultsKey<Double> {
        return DefaultsKey<Double>("\(prefix)_course_table_user_random_seed", defaultValue: 0.0)
    }

    static var courseTableCalendarIdentifier: DefaultsKey<String?> {
        return DefaultsKey<String?>("\(prefix)_course_table_calendar_identifier")
    }

    static var courseTableCourses: DefaultsKey<[PHCourse]> {
        return DefaultsKey<[PHCourse]>("\(prefix)_course_table_courses", defaultValue: [])
    }

    // MARK: Score

    static var lastFetchScore: DefaultsKey<TimeInterval?> {
        return DefaultsKey<TimeInterval?>("\(prefix)_last_fetch_score")
    }
}

extension DefaultsKeys {

    fileprivate static let prefixForNullUser = "PH_USER_NULL"
    fileprivate(set) static var prefix: String = prefixForNullUser

    static func updatePrefix() {
        guard let user = Defaults[.user] else {
            prefix = prefixForNullUser
            return
        }
        let salt = PHGlobal.secret.userDefaultsPrefixSalt
        let id = "\(salt)\(user.uid)\(salt)".sha1()
        prefix = "PH_USER_\(id)"
        print("UserDefaults prefix: \(prefix)")
    }
}
