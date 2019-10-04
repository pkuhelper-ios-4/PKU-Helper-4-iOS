//
//  PHHolePostListBaseViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Lightbox
import Kingfisher
import SafariServices

class PHHolePostListBaseViewController: PHBaseViewController {

    let tableView: UITableView = {
        let view = UITableView(frame: .null, style: .plain)
        view.register(PHHolePostTableViewCell.self, forCellReuseIdentifier: PHHolePostTableViewCell.identifier)
        view.register(PHHoleHiddenTableViewCell.self, forCellReuseIdentifier: PHHoleHiddenTableViewCell.identifier)
        view.backgroundColor = .groupTableViewBackground
        view.separatorStyle = .none
        view.allowsSelection = false
        view.estimatedRowHeight = 165
        return view
    }()

    private(set) var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = .lightGray
        return refresher
    }()

    var posts: [PHHolePost]? {
        didSet {
            guard let posts = self.posts, posts.count > 0 else { return }
            tableView.reloadData()
            if !hasSetupRefreshFooter {
                setupRefreshFooter()
                hasSetupRefreshFooter = true
            }
        }
    }

    static var hiddenPids: Set<Int> = Set<Int>(Defaults[.pkuHoleHiddenPidsList]) {
        didSet {
            Defaults[.pkuHoleHiddenPidsList] = Array<Int>(hiddenPids)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    //
    // If the derived view controller has refresh footer,
    // you can override this methods to setup it.
    //
    // The footer will not be setup until self.posts != nil.
    //
    fileprivate var hasSetupRefreshFooter: Bool = false

    func setupRefreshFooter() {}

    func setNeedsResetRefreshFooter() {
        hasSetupRefreshFooter = false
    }

    static func createDefaultRefreshFooter() -> PHRefreshFooter {
        let footer = PHRefreshFooter()
        footer.refreshMode = .scroll
        footer.footerHeightForFooter = 60.0
        footer.tintColor = .gray
        return footer
    }
}

extension PHHolePostListBaseViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let post = posts?[indexPath.row] else { return UITableViewCell() }
        if !isHiddenPost(post.pid) {
            let cell = tableView.dequeueReusableCell(withIdentifier: PHHolePostTableViewCell.identifier, for: indexPath) as! PHHolePostTableViewCell
            cell.post = post
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PHHoleHiddenTableViewCell.identifier, for: indexPath) as! PHHoleHiddenTableViewCell
            cell.model = PHHoleHiddenTableViewCell.Model(fromPost: post)
            cell.delegate = self
            return cell
        }
    }
}

extension PHHolePostListBaseViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { posts?[$0.row].image?.url }
        ImagePrefetcher(urls: urls).start()
    }
}

extension PHHolePostListBaseViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PHHoleBaseTableViewCell else { return }
        cell.contentImageView.kf.cancelDownloadTask()
    }
}

extension PHHolePostListBaseViewController: PHHolePostTableViewCellDelegate {

    func cell(_ cell: PHHoleBaseTableViewCell, didPressHeaderView headerView: UIView) {
        postCellTapped(cell: cell as! PHHolePostTableViewCell)
    }

    func cell(_ cell: PHHoleBaseTableViewCell, didPressIdLabel label: UILabel) {
        postCellTapped(cell: cell as! PHHolePostTableViewCell)
    }

    func cell(_ cell: PHHoleBaseTableViewCell, didPressTagLabel label: UILabel) {
        postCellTapped(cell: cell as! PHHolePostTableViewCell)
    }

    func cell(_ cell: PHHoleBaseTableViewCell, didPressContentTextView textView: UITextView) {
        postCellTapped(cell: cell as! PHHolePostTableViewCell)
    }

    func cell(_ cell: PHHoleBaseTableViewCell, didPressContentImageView imageView: UIImageView) {
        guard let image = imageView.image else { return }

        LightboxConfig.DeleteButton.enabled = false
        LightboxConfig.hideStatusBar = false
        LightboxConfig.InfoLabel.enabled = false
        LightboxConfig.PageIndicator.enabled = false

        let images = [
            LightboxImage(image: image)
        ]
        let controller = LightboxController(images: images)

        controller.dynamicBackground = true

        present(controller, animated: true, completion: nil)
    }

    func cell(_ cell: PHHolePostTableViewCell, didPressReportedButton button: UIButton) {
        postCellTapped(cell: cell)
    }

    func cell(_ cell: PHHolePostTableViewCell, didPressHidePostButton button: UIButton) {
        guard let pid = cell.post?.pid else { return }
        self.navigationController?.viewControllers.forEach { viewController in
            guard let holeViewController = viewController as? PHHolePostListBaseViewController else { return }
            holeViewController.setPostHidden(pid)
        }
    }

    func cell(_ cell: PHHolePostTableViewCell, diePressStarButton button: UIButton) {
        postCellTapped(cell: cell)
    }

    func cell(_ cell: PHHolePostTableViewCell, didPressCommentButton button: UIButton) {
        postCellTapped(cell: cell)
    }

    func cell(_ cell: PHHoleBaseTableViewCell, didPressURLInContent url: URL) {
        let safari = SFSafariViewController(url: url)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
    }

    func cell(_ cell: PHHoleBaseTableViewCell, didPressPIDInContent pid: Int) {
        fetchPost(pid: pid) { [weak self] post in
            guard let strongSelf = self else { return }
            let controller = PHHoleDetailViewController()
            controller.post = post
            controller.hasInitedFetchPost = true
            strongSelf.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension PHHolePostListBaseViewController: PHHoleHiddenTableViewCellDelegate {

    func cell(_ cell: PHHoleHiddenTableViewCell, didPressDisplayButton button: UIButton) {
        guard let pid = cell.model?.pid else { return }
        self.navigationController?.viewControllers.forEach { viewController in
            guard let holeViewController = viewController as? PHHolePostListBaseViewController else { return }
            holeViewController.setPostDisplayed(pid)
        }
    }
}

extension PHHolePostListBaseViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension PHHolePostListBaseViewController {

    func postCellTapped(cell: PHHolePostTableViewCell) {
        let controller = PHHoleDetailViewController()
        controller.post = cell.post
        navigationController?.pushViewController(controller, animated: true)
    }

    func isHiddenPost(_ pid: Int) -> Bool {
        return PHHolePostListBaseViewController.hiddenPids.contains(pid)
    }

    func setPostHidden(_ pid: Int) {
        PHHolePostListBaseViewController.hiddenPids.insert(pid)
        reloadRowAt(pid: pid, animated: true, with: .fade)
    }

    func setPostDisplayed(_ pid: Int) {
        PHHolePostListBaseViewController.hiddenPids.remove(pid)
        reloadRowAt(pid: pid, animated: true, with: .fade)
    }

    func addPosts(_ newPosts: [PHHolePost]) {
        var _posts: [PHHolePost] = newPosts
        if let oldPosts = posts {
            _posts += oldPosts
            _posts.removeDuplicates()
        }
        posts = _posts.sortedByTimestamp(ascending: false)
    }

    func switchPostStar(to state: Bool, pid: Int) {
        posts?.get(pid)?.switchStar(to: state)
        reloadRowAt(pid: pid)
    }

    func setPostReported(_ pid: Int) {
        posts?.get(pid)?.reported = true
        reloadRowAt(pid: pid)
    }

    func setPostUnreported(_ pid: Int) {
        posts?.get(pid)?.reported = false
        reloadRowAt(pid: pid)
    }

    func increasePostCommentCount(_ pid: Int) {
        posts?.get(pid)?.commentCount += 1
        reloadRowAt(pid: pid)
    }

    func reloadRowAt(pid: Int,
                     animated: Bool = false,
                     with animation: UITableView.RowAnimation = .middle)
    {
        guard let cell = tableView.visibleCells.first(where: { cell in
            switch cell {
            case let cell as PHHolePostTableViewCell:
                return cell.post?.pid == pid
            case let cell as PHHoleHiddenTableViewCell:
                return cell.model?.pid == pid
            default:
                return false
            }
        }) else { return }

        tableView.reloadCell(cell, animated: animated, with: animation)
    }
}

extension PHHolePostListBaseViewController {

    func fetchPost(pid: Int, successHandler: ((PHHolePost) -> Void)? = nil) {
        guard let user = PHUser.default else { return }
        PHBackendAPI.request(
            PHBackendAPI.PKUHole.getPost(pid: pid, utoken: user.utoken),
            on: self,
            errorHandler: { error in
                return
            },
            detailHandler: { (detail: PHV2PKUHolePostOne) in
                guard let post = detail.post else { return }
                successHandler?(post)
            }
        )
    }
}

