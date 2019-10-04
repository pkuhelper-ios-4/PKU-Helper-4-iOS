//
//  PHSettingMainViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import MessageUI
import SafariServices

class PHSettingMainViewController: PHBaseViewController {

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(PHSettingDualRowTableViewCell.self, forCellReuseIdentifier: PHSettingDualRowTableViewCell.identifier)
        view.register(PHSettingSingleRowTableViewCell.self, forCellReuseIdentifier: PHSettingSingleRowTableViewCell.identifier)

        view.allowsSelection = false
        view.allowsMultipleSelection = false

        view.separatorStyle = .singleLine

        return view
    }()

    fileprivate var dataSource: [[String: Any]]!

    fileprivate var isDeveloperMode: Bool = Defaults[.isDeveloperMode] {
        didSet {
            guard oldValue != isDeveloperMode else { return }
            Defaults[.isDeveloperMode] = isDeveloperMode
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Setting"

        dataSource = TableKeys.populate()

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PHSettingMainViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count + (isDeveloperMode ? 0 : -1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getRows(at: section).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getHeader(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = getRowModel(at: indexPath)

        guard let title = model[TableKeys.Title] else { return UITableViewCell() }

        if let subtitle = model[TableKeys.SubTitle] {
            let cell = tableView.dequeueReusableCell(withIdentifier: PHSettingDualRowTableViewCell.identifier, for: indexPath) as! PHSettingDualRowTableViewCell
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = subtitle
            cell.imageView?.image = getIconImage(model: model)
            bindTapGesture(cell, model: model)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PHSettingSingleRowTableViewCell.identifier, for: indexPath) as! PHSettingSingleRowTableViewCell
            cell.textLabel?.text = title
            cell.imageView?.image = getIconImage(model: model)
            bindTapGesture(cell, model: model)
            return cell
        }
    }
}

extension PHSettingMainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = PHGlobal.font.small
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footer = view as? UITableViewHeaderFooterView else { return }
        footer.textLabel?.font = PHGlobal.font.small
    }
}

extension PHSettingMainViewController {

    @objc func cellMessageTapped() {
        let viewController = PHSettingMessageViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func cellCourseTableTapped() {
        let viewController = PHSettingCourseTableViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func cellScoreTapped() {
        let viewController = PHSettingScoreViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func cellPKUHoleTapped() {
        let viewController = PHSettingPKUHoleViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func cellThemeTapped() {
        let viewController = PHSettingThemeViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func cellHoleTermTapped() {
        let safari = SFSafariViewController(url: PHURL.pkuHoleRulesURL)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
//        let viewController = PHWebBrowserViewController(title: "Terms of PKU Hole",
//                                                        url: PHBackendAPI.baseURL.appendingPathComponent("/pkuhole/rules.html"))
//        navigationController?.pushViewController(safari, animated: true)
    }

    @objc func cellPrivacyPolicyTapped() {
        let safari = SFSafariViewController(url: PHURL.privacyPolicyURL)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
    }

    @objc func cellFAQTapped() {
        debugPrint("FAQ tapped")
    }

    @objc func cellAboutUsTapped() {
        let viewController = PHSettingAboutUsViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func cellFeedbackTapped() {
        let email = TableKeys.feedbackEmail
        let subject = "[PKU Helper 4] Feedback"
        let bodyText = createEmailBody()
        presentSendEmail(email: email, subject: subject, bodyText: bodyText)
    }

    @objc func cellContactUsTapped() {
        let email = TableKeys.contactUsEmail
        let subject = "[PKU Helper 4] Contact Us"
        let bodyText = createEmailBody()
        presentSendEmail(email: email, subject: subject, bodyText: bodyText)
    }

    @objc func cellVersionMultiTapped() {
        isDeveloperMode.toggle()
    }

    @objc func cellDeveloperOptionsTapped() {
        let viewController = PHSettingDeveloperOptionsViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension PHSettingMainViewController {

    func createEmailBody() -> String {
        let deviceName = PHGlobal.device.hardware()
        let deviceCode = PHGlobal.device.hardwareString()
        let device = "\(deviceName) (\(deviceCode))"
        let version = PHGlobal.version
        return """
        ------------------------
        > App: PKU Helper 4
        > Version: \(version)
        > Device: \(device)
        ------------------------

        """
    }

    //
    // https://stackoverflow.com/questions/25981422/how-to-open-mail-app-from-swift
    //
    func presentSendEmail(email: String, subject: String, bodyText: String) {

        // https://developer.apple.com/documentation/messageui/mfmailcomposeviewcontroller
        if MFMailComposeViewController.canSendMail() {

            let mail = MFMailComposeViewController()

            mail.mailComposeDelegate = self

            mail.setToRecipients([email])
            mail.setSubject(subject)
            mail.setMessageBody(bodyText, isHTML: false)

            self.present(mail, animated: true, completion: nil)

        } else {
            print("Device not configured to send emails, trying with share ...")

            guard let mailto = "mailto:\(email)?subject=\(subject)&body=\(bodyText)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }

            guard let emailURL = URL(string: mailto) else { return }

            if #available(iOS 10.0, *) {
                guard UIApplication.shared.canOpenURL(emailURL) else {
                    print("cannot open email url")
                    return
                }
                UIApplication.shared.open(emailURL, options: [:]) { result in
                    if !result {
                        print("Unable to send email.")
                    }
                }
            } else {
                UIApplication.shared.openURL(emailURL)
            }
        }
    }
}

extension PHSettingMainViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension PHSettingMainViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled, .saved, .sent:
            controller.dismiss(animated: true, completion: nil)
        case .failed:
//            guard let error = error else { return }
//            PHAlert(on: self)?.error(error: error)
            controller.dismiss(animated: true, completion: nil)
        @unknown default:
            controller.dismiss(animated: true, completion: nil)
            break
        }
    }
}

private extension PHSettingMainViewController {

    typealias RowModel = [String: String]

    func getRows(at section: Int) -> [Any] {
        return dataSource[section][TableKeys.Rows] as! [Any]
    }

    func getHeader(at section: Int) -> String? {
        return dataSource[section][TableKeys.Header] as? String
    }

    func getRowModel(at indexPath: IndexPath) -> RowModel {
        return getRows(at: indexPath.section)[indexPath.row] as! RowModel
    }

    func getIconImage(model: RowModel) -> UIImage? {
        guard let iconName = model[TableKeys.Icon] else { return nil }
        guard let iconImage = UIImage(named: iconName) else { return nil }
        return iconImage.scaled(toHeight: PHGlobal.font.regular.pointSize * 1.6)
    }

    func bindTapGesture(_ cell: UITableViewCell, model: RowModel) {
        if let selector = model[TableKeys.Selector] {
            let tap = UITapGestureRecognizer(target: self, action: Selector(selector))
            if model[TableKeys.Title] == TableKeys.VersionTitle {
                tap.numberOfTapsRequired = 20
            }
            cell.contentView.addGestureRecognizer(tap)
        }
    }

    struct TableKeys {

        static let Header = "header"
        static let Footer = "footer"
        static let Rows = "rows"
        static let Icon = "icon"
        static let Title = "title"
        static let SubTitle = "subtitle"
        static let Selector = "selector"

        static let feedbackEmail = PHURL.developerEmail
        static let contactUsEmail = PHURL.pkuhelperEmail
        static let VersionTitle = "Version"

        static func populate() -> [[String: Any]] {
            return [
                [
                    TableKeys.Header: "MODULES",
                    TableKeys.Rows: [
                        [
                            TableKeys.Icon: R.image.course.name,
                            TableKeys.Title: "Course Table",
                            TableKeys.Selector: "cellCourseTableTapped",
                        ],
                        [
                            TableKeys.Icon: R.image.graduation_cap.name,
                            TableKeys.Title: "Score",
                            TableKeys.Selector: "cellScoreTapped",
                        ],
                        [
                            TableKeys.Icon: R.image.chat.name,
                            TableKeys.Title: "PKU Hole",
                            TableKeys.Selector: "cellPKUHoleTapped",
                        ],
                        [
                            TableKeys.Icon: R.image.message.name,
                            TableKeys.Title: "Message",
                            TableKeys.Selector: "cellMessageTapped",
                        ],
//                        [
//                            TableKeys.Icon: R.image.settings.name,
//                            TableKeys.Title: "Theme",
//                            TableKeys.Selector: "cellThemeTapped",
//                        ]
                    ]
                ],
                [
                    TableKeys.Header: "SOFTWARE INFORMATION & SUPPORT",
                    TableKeys.Rows: [
                        [
                            TableKeys.Icon: R.image.order.name,
                            TableKeys.Title: "Terms of PKU Hole",
                            TableKeys.Selector: "cellHoleTermTapped",
                        ],
                        [
                            TableKeys.Icon: R.image.user_shield.name,
                            TableKeys.Title: "Privacy Policy",
                            TableKeys.Selector: "cellPrivacyPolicyTapped",
                        ],
                        [
                            TableKeys.Icon: R.image.help.name,
                            TableKeys.Title: "FAQ",
                            TableKeys.Selector: "cellFAQTapped",
                        ],
                        [
                            TableKeys.Icon: R.image.about.name,
                            TableKeys.Title: "About Us",
                            TableKeys.Selector: "cellAboutUsTapped",
                        ],
                        [
                            TableKeys.Icon: R.image.paper_plane.name,
                            TableKeys.Title: "Feedback",
                            TableKeys.SubTitle: TableKeys.feedbackEmail,
                            TableKeys.Selector: "cellFeedbackTapped",
                        ],
                        [
                            TableKeys.Icon: R.image.online_support.name,
                            TableKeys.Title: "Contact Us",
                            TableKeys.SubTitle: TableKeys.contactUsEmail,
                            TableKeys.Selector: "cellContactUsTapped",
                        ],
                        [
                            TableKeys.Icon: R.image.versions.name,
                            TableKeys.Title: TableKeys.VersionTitle,
                            TableKeys.SubTitle: PHGlobal.version,
                            TableKeys.Selector: "cellVersionMultiTapped",
                        ],

                    ]
                ],
                [
                    TableKeys.Header: "DEVELOPER MODE",
                    TableKeys.Rows: [
                        [
                            TableKeys.Icon: R.image.support.name,
                            TableKeys.Title: "Developer Options",
                            TableKeys.Selector: "cellDeveloperOptionsTapped",
                        ]
                    ]
                ]
            ]
        }
    }
}
