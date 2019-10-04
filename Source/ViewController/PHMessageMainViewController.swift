//
//  PHMessageMainViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import PopupDialog
import PullToRefreshKit

class PHMessageMainViewController: PHBaseViewController {

    static let sender = "PKU Helper"
    static let avater = R.image.user_male()!

    fileprivate lazy var rightBarButtonItemsNormal: [UIBarButtonItem] = {
        let itemEdit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(navBarEditButtonTapped(_:)))
        return [itemEdit]
    }()

    fileprivate lazy var rightBarButtonItemOnEditing: [UIBarButtonItem] = {
        let itemDeleteAllSelected = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(navBarDeleteAllSelectedMessagesButtonTapped(_:)))
        let itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(navBarDoneButtonTapped(_:)))
        return [itemDone, itemDeleteAllSelected]
    }()

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(PHMessageTableViewCell.self, forCellReuseIdentifier: PHMessageTableViewCell.identifier)

        view.allowsSelection = true
        view.allowsMultipleSelection = false
        view.allowsMultipleSelectionDuringEditing = true

        view.separatorStyle = .singleLine
        view.separatorInset = .zero

        return view
    }()

    private(set) var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = .lightGray
        return refresher
    }()

    let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = true
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.searchBarStyle = .prominent
        controller.searchBar.sizeToFit()
        return controller
    }()

    fileprivate var messages: [PHMessage] = []

    fileprivate var hitMessages: [PHMessage] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    fileprivate var hasSetupRefreshFooter: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = rightBarButtonItemsNormal

        title = "Message"

        view.backgroundColor = .white

        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(handleRefresher(_:)), for: .valueChanged)

//        tableView.tableHeaderView = searchController.searchBar
//        searchController.searchResultsUpdater = self

        tableView.dataSource = self
        tableView.delegate = self

        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressTableView(_:))))

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        fetchLatestMessageList()
    }
}

extension PHMessageMainViewController {

    @objc func handleLongPressTableView(_ gesture: UILongPressGestureRecognizer) {
        guard !tableView.isEditing else { return }
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        if gesture.state == .recognized {
            tableView.setEditing(true, animated: true)
            navigationItem.setRightBarButtonItems(rightBarButtonItemOnEditing, animated: true)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }

    @objc func navBarEditButtonTapped(_ item: UIBarButtonItem) {
        guard !tableView.isEditing else { return }
        tableView.setEditing(true, animated: true)
        navigationItem.setRightBarButtonItems(rightBarButtonItemOnEditing, animated: true)
    }

    @objc func navBarDeleteAllSelectedMessagesButtonTapped(_ item: UIBarButtonItem) {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        let selectedMessages = indexPaths.map { messages[$0.row] }

        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }

        selectedMessages.forEach { message in
            PHBackendAPI.request(
                PHBackendAPI.Message.personDelete(mid: message.mid, utoken: user.utoken),
                on: self,
                errorHandler:{ [weak self] error in
                    PHAlert(on: self)?.backendError(error)
                },
                detailHandler: { (detail: PHV2NullDetail) in

                }
            )
        }

        messages.removeAll(selectedMessages)
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPaths, with: .middle)
        tableView.endUpdates()
    }

    @objc func navBarDoneButtonTapped(_ item: UIBarButtonItem) {
        guard tableView.isEditing else { return }
        tableView.setEditing(false, animated: true)
        navigationItem.setRightBarButtonItems(rightBarButtonItemsNormal, animated: true)
    }
}

extension PHMessageMainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? hitMessages.count : messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PHMessageTableViewCell.identifier, for: indexPath) as! PHMessageTableViewCell
        cell.message = searchController.isActive ? hitMessages[indexPath.row] : messages[indexPath.row]
        return cell
    }
}

extension PHMessageMainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else { return }
        tableView.deselectRow(at: indexPath, animated: true)

        let message = messages[indexPath.row]

        let viewController = PHMessageDetailViewController()
        viewController.message = message

        navigationController?.pushViewController(viewController) { [weak self] in
            guard let user = PHUser.default else { return }
            PHBackendAPI.request(
                PHBackendAPI.Message.personSetHasread(mid: message.mid, utoken: user.utoken),
                on: self,
                errorHandler: { error in
                    debugPrint(error)
                },
                detailHandler: { [weak self] (_: PHV2NullDetail) in
                    guard let strongSelf = self else { return }
                    message.hasread = true
                    strongSelf.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            )
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !searchController.isActive
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let popup = PopupDialog(title: "Delete Message",
                                    message: "Do you want to permanently delete this message?",
                                    image: PHAlert.infoHeaderImage,
                                    buttonAlignment: .horizontal,
                                    transitionStyle: .fadeIn)

            let cancelButton = CancelButton(title: "CANCEL", action: nil)
            let okButton = DefaultButton(title: "OK") { [weak self] in
                guard let strongSelf = self else { return }
                guard let user = PHUser.default else {
                    PHAlert(on: self)?.infoLoginRequired()
                    return
                }
                let message = strongSelf.messages[indexPath.row]
                PHBackendAPI.request(
                    PHBackendAPI.Message.personDelete(mid: message.mid, utoken: user.utoken),
                    on: self)
                {
                    [weak self] (_: PHV2NullDetail) in
                    guard let strongSelf = self else { return }
                    strongSelf.messages.remove(at: indexPath.row)
                    strongSelf.tableView.beginUpdates()
                    strongSelf.tableView.deleteRows(at: [indexPath], with: .middle)
                    strongSelf.tableView.endUpdates()
                }
            }

            popup.addButtons([okButton, cancelButton])
            present(popup, animated: true, completion: nil)
        default:
            break
        }
    }

//    @available(iOS 11.0, *)
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
//            completionHandler(true)
//        }
//        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
//        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
//        return swipeAction
//    }
}

extension PHMessageMainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        hitMessages = messages.filter { $0.content.contains(searchText) }
    }
}

extension PHMessageMainViewController {

    @objc func handleSegmentedControl(_ control: UISegmentedControl) {

    }

    @objc func handleRefresher(_ refresher: UIRefreshControl) {
        guard let user = PHUser.default else {
            refresher.endRefreshing()
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(
            PHBackendAPI.Message.personListByStartMid(mid: nil, utoken: user.utoken),
            on: self,
            errorHandler: { [weak self] error in
                refresher.endRefreshing()
                PHAlert(on: self)?.backendError(error)
            },
            detailHandler: { [weak self] (detail: PHV2MessageList) in
                refresher.endRefreshing()
                self?.hasSetupRefreshFooter = false // needs reset
                self?.setMessages(detail.messages)
            }
        )
    }

    func setupRefreshFooterIfNeeded() {

        guard !hasSetupRefreshFooter else { return }
        guard messages.count > 0 else { return }
        hasSetupRefreshFooter = true

        let footer = PHRefreshFooter()
        footer.refreshMode = .scroll
        footer.footerHeightForFooter = 60.0
        footer.tintColor = .gray

        tableView.configRefreshFooter(with: footer, container: self) { [weak self] in
            guard let user = PHUser.default else {
                PHAlert(on: self)?.infoLoginRequired()
                self?.tableView.switchRefreshFooter(to: .normal)
                return
            }
            guard let minMid = self?.messages.minMin() else {
                self?.tableView.switchRefreshFooter(to: .normal)
                return
            }
            PHBackendAPI.request(
                PHBackendAPI.Message.personListByStartMid(mid: minMid, utoken: user.utoken),
                on: self,
                errorHandler: { [weak self] error in
                    PHAlert(on: self)?.backendError(error)
                    self?.tableView.switchRefreshFooter(to: .normal)
                },
                detailHandler: { [weak self] (detail: PHV2MessageList) in
                    if detail.messages.isEmpty {
                        self?.tableView.switchRefreshFooter(to: .noMoreData)
                    } else {
                        self?.addMessages(detail.messages)
                        self?.tableView.switchRefreshFooter(to: .normal)
                    }
                }
            )
        }
    }
}

extension PHMessageMainViewController {

    func addMessages(_ newMessages: [PHMessage]) {
        guard newMessages.count > 0 else { return }
        var _messages = newMessages + messages
        messages = _messages.removeDuplicates().sortedByHasreadAndTime()
        tableView.reloadData()
        setupRefreshFooterIfNeeded()
    }

    func setMessages(_ newMessages: [PHMessage]) {
        guard messages != newMessages else { return }
        messages = newMessages.sortedByHasreadAndTime()
        tableView.reloadData()
        setupRefreshFooterIfNeeded()
    }
}

extension PHMessageMainViewController {

    func fetchLatestMessageList() {
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(
            PHBackendAPI.Message.personListByStartMid(mid: nil, utoken: user.utoken),
            on: self)
        {
            [weak self] (detail: PHV2MessageList) in
            self?.setMessages(detail.messages)
        }
    }
}
