//
//  PHIPGWMainStatusView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftDate

protocol PHIPGWMainStatusViewDelegate: AnyObject {

    func statusView(_ view: PHIPGWMainStatusView, didFireConnectionsRefresh refresher: UIRefreshControl)
    func statusView(_ view: PHIPGWMainStatusView, didCommitDeleteConnection connection: PHIPGWConnection)
}

extension PHIPGWMainStatusViewDelegate {

    func statusView(_ view: PHIPGWMainStatusView, didFireConnectionsRefresh refresher: UIRefreshControl) {}
    func statusView(_ view: PHIPGWMainStatusView, didCommitDeleteConnection connection: PHIPGWConnection) {}
}

class PHIPGWMainStatusView: UIView {

    weak var delegate: PHIPGWMainStatusViewDelegate?

    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Status", "Connections"])
        control.backgroundColor = .white
        control.tintColor = .blue
        return control
    }()

    let containterScrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.isDirectionalLockEnabled = true
        view.bounces = false

        // disable scroll to avoid gestures conflict :(
        view.isScrollEnabled = false

        return view
    }()

    let statusTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(PHIPGWStatusTableViewCell.self, forCellReuseIdentifier: PHIPGWStatusTableViewCell.identifier)

        view.bounces = false
        view.allowsSelection = false
        view.allowsMultipleSelection = false

//        view.separatorStyle = .singleLine
        view.separatorStyle = .none
        return view
    }()

    let connectionsTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(PHIPGWConnectionTableViewCell.self, forCellReuseIdentifier: PHIPGWConnectionTableViewCell.identifier)

        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = false

        view.allowsSelection = false
        view.allowsMultipleSelection = false

//        view.separatorStyle = .singleLine
        view.separatorStyle = .none

        return view
    }()

    let connectionsTableViewRefresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = .lightGray
        return refresher
    }()

    fileprivate var statusDataSource: [StatusCellModel] = []
    fileprivate var connectionsDataSource: [PHIPGWConnection] = []

    // cache original status for connection cell
    fileprivate var currentStatus: PHIPGWStatus = PHIPGWStatus.dummy

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        containterScrollView.delegate = self

        statusTableView.dataSource = self
        statusTableView.delegate = self
        connectionsTableView.dataSource = self
        connectionsTableView.delegate = self

        connectionsTableView.refreshControl = connectionsTableViewRefresher

        self.addSubviews([segmentedControl, containterScrollView])
        containterScrollView.addSubviews([statusTableView, connectionsTableView])

        let segmentedControlHeight = PHGlobal.font.regular.pointSize * 2
        let viewSpacing = PHIPGWMainViewController.viewSpacing

        segmentedControl.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(segmentedControlHeight)
        }

        containterScrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(segmentedControl.snp.bottom).offset(viewSpacing)
        }

        segmentedControl.selectedSegmentIndex = 0

        segmentedControl.addTarget(self, action: #selector(handleSegmentedControl(_:)), for: .valueChanged)
        connectionsTableViewRefresher.addTarget(self, action: #selector(handleConnectionsRefresher(_:)), for: .valueChanged)
    }

    @objc func handleSegmentedControl(_ control: UISegmentedControl) {
        let toPage = control.selectedSegmentIndex
        guard toPage != containterScrollView.currentPage else { return }
        containterScrollView.scrollTo(horizontalPage: toPage)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containterScrollView.contentSize = CGSize(width: frame.width * 2, height: frame.height)

        statusTableView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        connectionsTableView.frame = CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height)
    }

    @objc func handleConnectionsRefresher(_ refresher: UIRefreshControl) {
        delegate?.statusView(self, didFireConnectionsRefresh: refresher)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PHIPGWMainStatusView: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !scrollView.isKind(of: UITableView.self) else { return }
        // As containterScrollView.isScrollEnabled = false, this line will impossible to be run
        segmentedControl.selectedSegmentIndex = scrollView.currentPage
    }
}

extension PHIPGWMainStatusView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case statusTableView:
            return statusDataSource.count
        case connectionsTableView:
            return connectionsDataSource.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case statusTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: PHIPGWStatusTableViewCell.identifier, for: indexPath) as! PHIPGWStatusTableViewCell
            cell.model = statusDataSource[indexPath.row]
            return cell
        case connectionsTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: PHIPGWConnectionTableViewCell.identifier, for: indexPath) as! PHIPGWConnectionTableViewCell
            cell.currentStatus = currentStatus
            cell.connection = connectionsDataSource[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension PHIPGWMainStatusView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch tableView {
        case connectionsTableView:
            return true
        default:
            return false
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch tableView {
        case connectionsTableView:
            let disconnectAction = UITableViewRowAction(style: .destructive, title: "Disconnect") {
                [weak self] (action, indexPath) in
                guard let strongSelf = self else { return }
                guard let cell = tableView.cellForRow(at: indexPath) as? PHIPGWConnectionTableViewCell else { return }
                guard let connection = cell.connection else { return }
                strongSelf.delegate?.statusView(strongSelf, didCommitDeleteConnection: connection)
            }
            return [disconnectAction]
        default:
            return nil
        }
    }
}

extension PHIPGWMainStatusView {

    typealias StatusCellModel = PHIPGWStatusTableViewCell.Model

    func setCurrentStatus(_ status: PHIPGWStatus) {
        let oldStatus = currentStatus
        currentStatus = status

        let ip = status.isDummy() ? "-" : status.ip
        let connections = status.isDummy() ? "-" : "\(status.connections)"
        let balance = status.isDummy() ? "-" : status.balance.format("%.1f")
        let time = status.isDummy() ? "-" : status.timestamp.formatTimestamp()

        statusDataSource = [
            StatusCellModel(title: "IP", description: ip),
            StatusCellModel(title: "Connections", description: connections),
            StatusCellModel(title: "Balance", description: balance),
            StatusCellModel(title: "Connection Time", description: time),
        ]
        statusTableView.reloadData()

        if status.isDummy() {
            // auto remove the corresponding connection
            if let connection = connectionsDataSource.first(where: { $0.ip == oldStatus.ip }) {
                removeConnection(connection)
            }
        }
    }

    func setConnections(_ connections: [PHIPGWConnection]) {
        connectionsDataSource = connections
        connectionsTableView.reloadData()
    }

    func removeConnection(_ connection: PHIPGWConnection) {
        guard let row = connectionsDataSource.firstIndex(where: { $0 === connection }) else { return }
        let indexPath = IndexPath(row: row, section: 0)
        connectionsDataSource.remove(at: row)

        connectionsTableView.beginUpdates()
        connectionsTableView.deleteRows(at: [indexPath], with: .middle)
        connectionsTableView.endUpdates()

        // auto reset current status if needed
        if connection.ip == currentStatus.ip {
            setCurrentStatus(PHIPGWStatus.dummy)
        }
    }
}

//
//fileprivate class PHIPGWMainStatusContainerScrollView: UIScrollView {
//
//    var leftTableView: UITableView! {
//        didSet {
//            if let oldTableView = oldValue {
//                oldTableView.removeFromSuperview()
//            }
//            addSubview(leftTableView)
//        }
//    }
//
//    var rightTableView: UITableView! {
//        didSet {
//            if let oldTableView = oldValue {
//                oldTableView.removeFromSuperview()
//            }
//            addSubview(rightTableView)
//        }
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        contentSize = CGSize(width: frame.width * 2, height: frame.height)
//
//        leftTableView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
//        rightTableView.frame = CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height)
//    }
//}

//
// https://stackoverflow.com/questions/11379989/swipe-to-delete-in-a-uitableview-which-is-embeded-in-a-uiscrollview
//
//extension PHIPGWMainStatusContainerScrollView: UIGestureRecognizerDelegate {
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        debugPrint("container scrollview shouldRequireFailureOf")
//        debugPrint(otherGestureRecognizer.view as Any)
//        debugPrint(otherGestureRecognizer.view?.superview as Any)
//        if let tableView = otherGestureRecognizer.view?.superview as? UITableView {
////            debugPrint(tableView)
//            return tableView === rightTableView
//        }
//        return false
//    }
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        debugPrint("container scrollview shouldRecognizeSimultaneouslyWith")
//        if let tableView = otherGestureRecognizer.view?.superview as? UITableView {
//            if tableView === leftTableView {
//                return false
//            }
//            if tableView === rightTableView {
//                return gestureRecognizer.state != .possible
//            }
//        }
//
//        if gestureRecognizer.state != .possible {
//            return true
//        }
//        return false
//    }
//}
