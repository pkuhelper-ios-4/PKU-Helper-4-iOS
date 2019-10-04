//
//  PHHoleMainViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import PullToRefreshKit

class PHHoleMainViewController: PHHolePostListBaseViewController {

    static let shared = PHHoleMainViewController()

    let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = true
        controller.searchBar.searchBarStyle = .prominent
        controller.searchBar.placeholder = "Enter post ID or keywords"
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "PKU Hole"

        let itemBack = navigationItem.leftBarButtonItem ?? UIBarButtonItem(image: R.image.navbar.back(), style: .plain, target: self, action: #selector(navBarBackButtonTapped(_:)))
        let itemFavorites = UIBarButtonItem(image: R.image.navbar.favorites(), style: .plain, target: self, action: #selector(navBarFavoritesButtonTapped(_:)))
        let itemSearch = UIBarButtonItem(image: R.image.navbar.search(), style: .plain, target: self, action: #selector(navBarSearchButtonTapped(_:)))
        let itemNewPost = UIBarButtonItem(image: R.image.navbar.create_new(), style: .plain, target: self, action: #selector(navBarNewPostButtonTapped(_:)))

        navigationItem.leftBarButtonItems = [itemBack, itemFavorites]
        navigationItem.rightBarButtonItems = [itemNewPost, itemSearch]

        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(handleRefresher(_:)), for: .valueChanged)

        searchController.searchBar.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUserLogout(_:)), name: .PHUserDidLogout, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func fetchLatestPostList(successHandler: (() -> Void)? = nil) {
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(
            PHBackendAPI.PKUHole.listPostByEndPid(pid: nil, utoken: user.utoken),
            on: self)
        {
            [weak self] (detail: PHV2PKUHolePostList) in
            self?.addPosts(detail.posts)
            successHandler?()
        }
    }

    @objc func handleRefresher(_ refresher: UIRefreshControl) {
        guard let user = PHUser.default else {
            refresher.endRefreshing()
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(
            PHBackendAPI.PKUHole.listPostByEndPid(pid: nil, utoken: user.utoken),
            on: self,
            errorHandler: { [weak self] error in
                refresher.endRefreshing()
                PHAlert(on: self)?.backendError(error)
            },
            detailHandler: { [weak self] (detail: PHV2PKUHolePostList) in
                refresher.endRefreshing()
                // reset the whole list
                self?.setNeedsResetRefreshFooter()
                self?.posts = detail.posts
            }
        )
    }

//    private var isLockFooterRefresher: Bool = false
//    private var isNoMoreData: Bool = false
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("\(scrollView.isScrolledToBottom) \(isLockFooterRefresher)")
//        if !isLockFooterRefresher
//            && !isNoMoreData
//            && scrollView.isScrolledToBottom,
//            let posts = self.posts
//        {
//            isLockFooterRefresher = true // require lock
//            guard let user = PHUser.default else {
//                isLockFooterRefresher = true // footer refresher will be disabled
//                PHAlert(on: self)?.infoLoginRequired()
//                return
//            }
//            PHBackendAPI.request(
//                PHBackendAPI.PKUHole.listPostByStartPid(pid: posts.minPid(), utoken: user.utoken),
//                on: self,
//                errorHandler: { [weak self] error in
//                    PHAlert(on: self)?.backendError(error) { [weak self] in
//                        self?.isLockFooterRefresher = false
//                    }
//                },
//                detailHandler: { [weak self] (detail: PHV2PKUHolePostList) in
//                    if detail.posts.isEmpty {
//                        self?.isNoMoreData = true
//                    } else {
//                        self?.addPosts(detail.posts)
//                    }
//                    self?.isLockFooterRefresher = false
//                }
//            )
//        }
//    }

    override func setupRefreshFooter() {
        let footer = PHHolePostListBaseViewController.createDefaultRefreshFooter()
        tableView.configRefreshFooter(with: footer, container: self) { [weak self] in
            guard let user = PHUser.default else {
                PHAlert(on: self)?.infoLoginRequired()
                self?.tableView.switchRefreshFooter(to: .normal)
                return
            }
            guard let posts = self?.posts, let minPid = posts.minPid() else {
                self?.tableView.switchRefreshFooter(to: .normal)
                return
            }
            PHBackendAPI.request(
                PHBackendAPI.PKUHole.listPostByStartPid(pid: minPid, utoken: user.utoken),
                on: self,
                errorHandler: { [weak self] error in
                    PHAlert(on: self)?.backendError(error)
                    self?.tableView.switchRefreshFooter(to: .normal)
                },
                detailHandler: { [weak self] (detail: PHV2PKUHolePostList) in
                    if detail.posts.isEmpty {
                        self?.tableView.switchRefreshFooter(to: .noMoreData)
                    } else {
                        self?.addPosts(detail.posts)
                        self?.tableView.switchRefreshFooter(to: .normal)
                    }
                }
            )
        }
    }

    func reset() {
        posts = nil
        fetchLatestPostList() { [weak self] in
            let indexPath = IndexPath(row: 0, section: 0)
            self?.tableView.safeScrollToRow(at: indexPath, at: .top, animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // check user every time the view appears
        guard let _ = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired() { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }

        // release footer refresher lock
//        isLockFooterRefresher = false

        // init here
        if posts == nil {
            fetchLatestPostList()
            return
        }

        if shouldReset {
            reset()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let topViewController = navigationController?.topViewController, topViewController != self { return }
        lastDisappearTime = PHUtil.now()
        refresher.endRefreshing()
    }

    var timeIntervalForTriggerReset: TimeInterval = 300.0

    private var lastDisappearTime: TimeInterval?

    private var shouldReset: Bool {
        guard let lastTime = lastDisappearTime else { return false }
        return PHUtil.now() - lastTime > timeIntervalForTriggerReset
    }

    @objc func appDidBecomeActive(_ notification: Notification) {
        if shouldReset {
            reset()
        }
    }

    @objc func appWillResignActive(_ notification: Notification) {
        if let topViewController = navigationController?.topViewController, topViewController != self { return }
        lastDisappearTime = PHUtil.now()
    }

    @objc func didUserLogout(_ notification: Notification) {
        lastDisappearTime = PHUtil.now() - timeIntervalForTriggerReset // lazy reset
    }
}

extension PHHoleMainViewController {

    @objc func navBarBackButtonTapped(_ item: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @objc func navBarFavoritesButtonTapped(_ item: UIBarButtonItem) {
        let viewController = PHHoleAttentionViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func navBarSearchButtonTapped(_ item: UIBarButtonItem) {
        present(searchController, animated: true, completion: nil)
    }

    @objc func navBarNewPostButtonTapped(_ item: UIBarButtonItem) {
        let viewController = PHHoleWritePostViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension PHHoleMainViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keywords = searchBar.text?.trimmed.empty2Nil() else { return }
        searchController.dismiss(animated: false, completion: nil)
        let viewController = PHHoleSearchResultViewController()
        viewController.keywords = keywords
        navigationController?.pushViewController(viewController, animated: true)
    }
}
