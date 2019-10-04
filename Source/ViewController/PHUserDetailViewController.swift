//
//  PHUserDetailViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/13.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import PopupDialog
import SafariServices

class PHUserDetailViewController: PHBaseViewController {

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(PHUserDetailInfoRowTableViewCell.self, forCellReuseIdentifier: PHUserDetailInfoRowTableViewCell.identifier)
        view.register(PHUserIAAAAcountRowTableViewCell.self, forCellReuseIdentifier: PHUserIAAAAcountRowTableViewCell.identifier)
        view.register(PHUserButtonRowTableViewCell.self, forCellReuseIdentifier: PHUserButtonRowTableViewCell.identifier)

        view.allowsSelection = true
        view.allowsMultipleSelection = false

        view.separatorStyle = .singleLine

        return view
    }()

    var user: PHUser! {
        didSet {
            dataSource = TableKeys.populate(user: user)
        }
    }

    fileprivate var dataSource: [[String: Any]]! {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Account"

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PHUserDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getRows(at: section).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = getRowModel(at: indexPath)

        switch indexPath.section {
        case tableView.lastSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: PHUserButtonRowTableViewCell.identifier, for: indexPath) as! PHUserButtonRowTableViewCell
            cell.textLabel?.text = model[TableKeys.Title]
            bindTapGesture(cell, model: model)
            switch indexPath.row {
            case 0: // Logout
                cell.textLabel?.textColor = .red
            default:
                cell.textLabel?.textColor = .black
            }
            return cell
        case (tableView.lastSection ?? 0) - 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PHUserIAAAAcountRowTableViewCell.identifier, for: indexPath) as! PHUserIAAAAcountRowTableViewCell
            cell.textLabel?.text = model[TableKeys.Title]
            bindTapGesture(cell, model: model)
            cell.hasPasswordStored = (PHKeychain.iaaaPassword != nil)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: PHUserDetailInfoRowTableViewCell.identifier, for: indexPath) as! PHUserDetailInfoRowTableViewCell
            cell.textLabel?.text = model[TableKeys.Title]
            cell.detailTextLabel?.text = model[TableKeys.Detail]
            bindTapGesture(cell, model: model)
            return cell
        }
    }
}

extension PHUserDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PHUserDetailViewController {

    @objc func cellIAAAAcountTapped() {
        if PHKeychain.iaaaPassword == nil {
            if Defaults[.hasReadPrivacyPolicy] {
                let viewController = PHUserIAAAAccountViewController()
                viewController.delegate = self
                navigationController?.pushViewController(viewController, animated: true)
            } else {
                let popup = PopupDialog(title: "Read Privacy Policy First",
                                        message: "Before set your IAAA accout, You need to read our privacy policy first to know how your IAAA account will be used by PKU Helper.",
                                        image: PHAlert.infoHeaderImage,
                                        buttonAlignment: .horizontal,
                                        transitionStyle: .fadeIn)

                let cancelButton = CancelButton(title: "LATER", action: nil)

                let privatePolicyButton = DefaultButton(title: "PRIVACY POLICY") { [weak self] in
                    let safari = SFSafariViewController(url: PHURL.privacyPolicyURL)
                    safari.delegate = self
                    self?.present(safari, animated: true) {
                        Defaults[.hasReadPrivacyPolicy] = true
                    }
                }

                popup.addButtons([privatePolicyButton, cancelButton])
                present(popup, animated: true, completion: nil)
            }

        } else {
            let popup = PopupDialog(title: "Reset IAAA Password",
                                    message: "Do you really want to reset your IAAA password stored by PKU Helper? The old password will be cleared immediately.",
                                    image: PHAlert.infoHeaderImage,
                                    buttonAlignment: .horizontal,
                                    transitionStyle: .fadeIn)

            let cancelButton = CancelButton(title: "NO", action: nil)
            let okButton = DefaultButton(title: "YES") { [weak self] in
                let viewController = PHUserIAAAAccountViewController()
                viewController.delegate = self
                self?.navigationController?.pushViewController(viewController) { [weak self] in
                    PHKeychain.iaaaPassword = nil
                    self?.tableView.reloadData() // immediately reload
                }
            }

            popup.addButtons([okButton, cancelButton])
            present(popup, animated: true, completion: nil)
        }
    }

    @objc func cellLogoutTapped() {
        let popup = PopupDialog(title: "Confirm",
                                message: "You're ready to logout current account \(user.name) \(user.uid)",
                                image: PHAlert.warningHeaderImage,
                                buttonAlignment: .horizontal,
                                transitionStyle: .fadeIn)

        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        let logoutButton = DestructiveButton(title: "LOGOUT") { [weak self] in
            Defaults[.user] = nil
            NotificationCenter.default.post(name: .PHUserDidLogout, object: nil)
            self?.navigationController?.popViewController(animated: true)
        }

        popup.addButtons([logoutButton, cancelButton])
        present(popup, animated: true, completion: nil)
    }
}

extension PHUserDetailViewController: PHUserIAAAAccountViewControllerDelegate {

    func iaaaAcount(_ viewController: PHUserIAAAAccountViewController, didPressSaveButton button: UIButton) {
        PHKeychain.iaaaPassword = viewController.iaaaPassword
        dataSource = TableKeys.populate(user: user)
        navigationController?.popViewController(animated: true) // immediately pop
    }
}

extension PHUserDetailViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

fileprivate extension PHUserDetailViewController {

    typealias RowModel = [String: String]

    func getRows(at section: Int) -> [Any] {
        return dataSource[section][TableKeys.Rows] as! [Any]
    }

    func getRowModel(at indexPath: IndexPath) -> RowModel {
        return getRows(at: indexPath.section)[indexPath.row] as! RowModel
    }

    func bindTapGesture(_ cell: UITableViewCell, model: RowModel) {
        if let selector = model[TableKeys.Selector] {
            cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector(selector)))
        }
    }

    private struct TableKeys {

        static let Rows = "rows"
        static let Title = "title"
        static let Detail = "detail"
        static let Selector = "selector"

        static let Logout = "Logout"

        static func populate(user: PHUser) -> [[String: Any]] {
            return [
                [
                    TableKeys.Rows: [
                        [
                            TableKeys.Title: "User ID",
                            TableKeys.Detail: user.uid,
                        ],
                        [
                            TableKeys.Title: "Name",
                            TableKeys.Detail: user.name,
                        ],
                        [
                            TableKeys.Title: "Gender",
                            TableKeys.Detail: user.gender.rawValue,
                        ],
                        [
                            TableKeys.Title: "Department",
                            TableKeys.Detail: user.department,
                        ]
                    ]
                ],
                [
                    TableKeys.Rows: [
                        [
                            TableKeys.Title: "IAAA Acount",
                            TableKeys.Selector: "cellIAAAAcountTapped",
                        ]
                    ]
                ],
                [
                    TableKeys.Rows: [
                        [
                            TableKeys.Title: TableKeys.Logout,
                            TableKeys.Selector: "cellLogoutTapped",
                        ]
                    ]
                ]
            ]
        }
    }
}
