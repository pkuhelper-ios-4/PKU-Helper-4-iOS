//
//  PHIPGWMainViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import PopupDialog

class PHIPGWMainViewController: PHBaseViewController {

    static let sideSpacing = PHGlobal.sideSpacing
    static let viewSpacing = PHGlobal.font.regular.pointSize * 2

    let statusView = PHIPGWMainStatusView()
    let buttonsView = PHIPGWMainButtonGroupView()

    var currentStatus: PHIPGWStatus = PHIPGWStatus.dummy {
        didSet {
            statusView.setCurrentStatus(currentStatus)
            guard !currentStatus.isDummy() else { return }
            Defaults[.lastIPGWStatus] = currentStatus
        }
    }

    var connections: [PHIPGWConnection] = [] {
        didSet {
            statusView.setConnections(connections)
        }
    }

    fileprivate var hasFetchedConnections: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "PKU IPGW"

        statusView.delegate = self
        buttonsView.delegate = self

        if let status = Defaults[.lastIPGWStatus] {
            currentStatus = status
        }

        view.backgroundColor = UIColor.groupTableViewBackground

        view.addSubviews([statusView, buttonsView])

//        let viewSpacing = PHIPGWMainViewController.viewSpacing

        statusView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(PHGlobal.topBarsHeight)
            make.height.equalTo(PHGlobal.screenHeight * 0.50) // TODO: Is there any better way to get a suitable height ?
        }

        buttonsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(statusView.snp.bottom) //.offset(viewSpacing)
        }

        fetchConnections(background: true)
    }
}

extension PHIPGWMainViewController {

    func getUserAccount() -> (uid: String, password: String)? {
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            navigationController?.popViewController(animated: true)
            return nil
        }
        guard let password = PHKeychain.iaaaPassword else {
            let popup = PopupDialog(title: "Need your IAAA Account",
                                    message: "You should set up your IAAA account first before using IPGW service.",
                                    image: PHAlert.infoHeaderImage,
                                    buttonAlignment: .vertical,
                                    transitionStyle: .fadeIn)

            let cancelButton = CancelButton(title: "CANCEL", action: nil)

            let useNetPortalButton = DefaultButton(title: "USE ITS NETPORTAL (in development)", action: nil)

            let goToSetupIAAAButton = DefaultButton(title: "SET UP IAAA ACCOUNT") { [weak self] in
                let viewController = PHUserDetailViewController()
                viewController.user = user
                self?.navigationController?.pushViewController(viewController, animated: true)
            }

            popup.addButtons([useNetPortalButton, goToSetupIAAAButton, cancelButton])
            present(popup, animated: true, completion: nil)
            return nil
        }
        return (uid: user.uid, password: password)
    }

    func getCurrentIP() -> String? {
        guard let ip = PHUtil.ipAddress(version: .ipv4) else {
            PHAlert(on: self)?.warning(title: "Unable to get IP",
                                       message: "IPGW can't get your current IPv4 address.")
            return nil
        }
        return ip
    }
}

extension PHIPGWMainViewController: PHIPGWMainStatusViewDelegate {

    func statusView(_ view: PHIPGWMainStatusView, didFireConnectionsRefresh refresher: UIRefreshControl) {
        fetchConnections(background: false) {
            refresher.endRefreshing()
        }
    }

    func statusView(_ view: PHIPGWMainStatusView, didCommitDeleteConnection connection: PHIPGWConnection) {
        guard let (uid, password) = getUserAccount() else { return }
        PHIPGWAPI.request(
            PHIPGWRouter.disconnect(username: uid, password: password, ip: connection.ip),
            on: self,
            errorHandler: { [weak self] error in
                PHAlert(on: self)?.ipgwError(error)
            },
            successHandler: { [weak self] (_: PHIPGWSuccResponse) in
                guard let strongSelf = self else { return }
                strongSelf.statusView.removeConnection(connection)
            }
        )
    }
}

extension PHIPGWMainViewController: PHIPGWMainButtonGroupViewDelegate {

    func buttonGroups(_ view: PHIPGWMainButtonGroupView, didPressConnectButton button: UIButton) {
        guard let ip = getCurrentIP() else { return }
        guard let (uid, password) = getUserAccount() else { return }
        PHIPGWAPI.request(
            PHIPGWRouter.open(username: uid, password: password, ip: ip),
            on: self,
            errorHandler: { [weak self] error in
                PHAlert(on: self)?.ipgwError(error)
            },
            successHandler: { [weak self] (response: PHIPGWOpen) in
                guard let strongSelf = self else { return }
                strongSelf.currentStatus = PHIPGWStatus(from: response) // setup current status
                strongSelf.fetchConnections(background: true) // auto refresh current connections
            }
        )
    }

    func buttonGroups(_ view: PHIPGWMainButtonGroupView, didPressDisconnectButton button: UIButton) {
        PHIPGWAPI.request(
            PHIPGWRouter.close,
            on: self,
            errorHandler: { [weak self] error in
                PHAlert(on: self)?.ipgwError(error)
            },
            successHandler: { [weak self] (_: PHIPGWSuccResponse) in
                guard let strongSelf = self else { return }
                // reset to dummy status, the corresponding connection will automatically be removed
                strongSelf.currentStatus = PHIPGWStatus.dummy
            }
        )
    }

    func buttonGroups(_ view: PHIPGWMainButtonGroupView, didPressDisconnectAllButton button: UIButton) {
        guard let (uid, password) = getUserAccount() else { return }
        PHIPGWAPI.request(
            PHIPGWRouter.closeAll(username: uid, password: password),
            on: self,
            errorHandler: { [weak self] error in
                PHAlert(on: self)?.ipgwError(error)
            },
            successHandler: { [weak self] (_: PHIPGWSuccResponse) in
                self?.connections.removeAll() // clear all connections
                self?.currentStatus = PHIPGWStatus.dummy // reset to dummy status
            }
        )
    }
}

extension PHIPGWMainViewController {

    func fetchConnections(background: Bool = true, completion: (() -> Void)? = nil) {
        if background {
            guard let user = PHUser.default else { return }
            guard let password = PHKeychain.iaaaPassword else { return }
            PHIPGWAPI.request(
                PHIPGWRouter.getConnections(username: user.uid, password: password),
                on: self,
                errorHandler: { error in
                    debugPrint(error) // ignore any error
                    completion?()
                },
                successHandler: { [weak self] (response: PHIPGWGetConnections) in
                    self?.connections = response.connections
                    completion?()
                }
            )
        } else {
            guard let (uid, password) = getUserAccount() else { return }
            PHIPGWAPI.request(
                PHIPGWRouter.getConnections(username: uid, password: password),
                on: self,
                errorHandler: { [weak self] error in
                    PHAlert(on: self)?.ipgwError(error)
                    completion?()
                },
                successHandler: { [weak self] (response: PHIPGWGetConnections) in
                    self?.connections = response.connections
                    completion?()
                }
            )
        }
    }
}
