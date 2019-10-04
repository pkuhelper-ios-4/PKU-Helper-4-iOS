//
//  PHHoleDetailViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import PopMenu
import Lightbox
import SafariServices

class PHHoleDetailViewController: PHBaseViewController {

    let tableView: UITableView = {
        let view = UITableView(frame: .null, style: .grouped)
        view.register(PHHolePostTableViewCell.self, forCellReuseIdentifier: PHHolePostTableViewCell.identifier)
        view.register(PHHoleCommentTableViewCell.self, forCellReuseIdentifier: PHHoleCommentTableViewCell.identifier)
        view.register(PHHoleHiddenTableViewCell.self, forCellReuseIdentifier: PHHoleHiddenTableViewCell.identifier)
        view.register(PHHoleDetailTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: PHHoleDetailTableViewHeaderView.identifier)
        view.separatorStyle = .none
        view.allowsSelection = false
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = PHGlobal.font.largest.pointSize * 5
        return view
    }()

    let refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = .lightGray
        return refresher
    }()

    var post: PHHolePost? {
        didSet {
            guard let post = self.post else { return }
            post.comments?.sortByTimestamp(ascending: !isReverseComments)
            tableView.reloadData()
        }
    }

    var hasInitedFetchPost: Bool = false

    static var hiddenCids: Set<Int> = Set<Int>(Defaults[.pkuHoleHiddenCidsList]) {
        didSet {
            Defaults[.pkuHoleHiddenCidsList] = Array<Int>(hiddenCids)
        }
    }

    //
    // if reverse comments, the latest comment will be the first one
    //
    var isReverseComments: Bool = false {
        didSet {
            guard let post = self.post else { return }
            post.comments?.sortByTimestamp(ascending: !isReverseComments)
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = (post != nil) ? "Hole #\(post!.pid)" : "PKU Hole"

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.navbar.menu(), style: .plain, target: self, action: #selector(navBarMenuButtonTapped(_:)))

        tableView.dataSource = self
        tableView.delegate = self

        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(handleRefresher(_:)), for: .valueChanged)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if !hasInitedFetchPost {
            hasInitedFetchPost = true
            fetchPost()
        }
    }

    @objc func handleRefresher(_ refresher: UIRefreshControl) {
        guard let user = PHUser.default else {
            refresher.endRefreshing()
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        guard let post = self.post else { return }
        PHBackendAPI.request(
            PHBackendAPI.PKUHole.getPost(pid: post.pid, utoken: user.utoken),
            on: self,
            errorHandler: { [weak self] error in
                refresher.endRefreshing()
                PHAlert(on: self)?.backendError(error)
            },
            detailHandler: { [weak self] (detail: PHV2PKUHolePostOne) in
                refresher.endRefreshing()
                if detail.post == nil {
                    PHAlert(on: self)?.infoPostNotFound()
                } else {
                    self?.post = detail.post
                }
            }
        )
    }
}

extension PHHoleDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1 : post?.comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PHHolePostTableViewCell.identifier, for: indexPath) as! PHHolePostTableViewCell
            cell.post = post
            cell.delegate = self
            return cell
        } else {
            guard let comment = post?.comments?[indexPath.row] else { return UITableViewCell() }
            if !isHiddenComment(comment.cid) {
                let cell = tableView.dequeueReusableCell(withIdentifier: PHHoleCommentTableViewCell.identifier, for: indexPath) as! PHHoleCommentTableViewCell
                cell.comment = comment
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: PHHoleHiddenTableViewCell.identifier, for: indexPath) as! PHHoleHiddenTableViewCell
                cell.model = PHHoleHiddenTableViewCell.Model(fromComment: comment)
                cell.delegate = self
                return cell
            }
        }
    }
}

extension PHHoleDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
//            return "POST"
            return nil
        case 1:
            guard let count = post?.comments?.count, count > 0 else { return nil }
            return "COMMENTS"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 0.0 : PHGlobal.font.regular.pointSize * 2.5
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PHHoleDetailTableViewHeaderView.identifier) as! PHHoleDetailTableViewHeaderView
        return header
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? PHHoleDetailTableViewHeaderView else { return }
        header.titleLabel.text = header.textLabel?.text
        header.textLabel?.text = nil
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        guard let cell = cell as? PHHolePostTableViewCell else { return }
        cell.hidePostButton.isHidden = true
    }
}

extension PHHoleDetailViewController {

    @objc func navBarMenuButtonTapped(_ item: UINavigationItem) {
        let manager = PopMenuManager()

        manager.actions = [

            PopMenuDefaultAction(title: (post?.starred ?? false) ? "Unstar" : "Star",
                                 image: R.image.star_unfilled(),
                                 color: (post?.starred ?? false) ? .blue : nil),
            PopMenuDefaultAction(title: "Comment",
                                 image: R.image.comment()),
            PopMenuDefaultAction(title: (post?.reported ?? false) ? "Reported" : "Report",
                                 image: R.image.attention(),
                                 color: (post?.reported ?? false) ? .red : nil),
            PopMenuDefaultAction(title: "Reverse comments",
                                 image: isReverseComments ? R.image.ascending() : R.image.descending(),
                                 color: isReverseComments ? .blue : nil),
        ]
        manager.popMenuAppearance.popMenuBackgroundStyle = .dimmed(color: .black, opacity: 0.6)
        manager.popMenuAppearance.popMenuColor.backgroundColor = .solid(fill: .darkGray)
        manager.popMenuAppearance.popMenuColor.actionColor = .tint(.white)
        manager.popMenuAppearance.popMenuCornerRadius = 0
        manager.popMenuAppearance.popMenuFont = PHGlobal.font.regularBold
        manager.popMenuAppearance.popMenuActionCountForScrollable = 10

        manager.popMenuDelegate = self
        manager.present(navItem: item, on: self, animated: true, completion: nil)
    }

    func presentReportReasonWritingViewController() {
        let controller = PHHoleWriteReportReasonViewController()
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
}

extension PHHoleDetailViewController: PHHoleBaseTableViewCellDelegate {

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

extension PHHoleDetailViewController: PHHolePostTableViewCellDelegate {

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
}

extension PHHoleDetailViewController: PHHoleCommentTableViewCellDelegate {

    func cell(_ cell: PHHoleCommentTableViewCell, didPressCommentButton button: UIButton) {
        let controller = PHHoleWriteCommentViewController.shared
        controller.delegate = self
        controller.replayName = cell.comment?.name
        present(controller, animated: true, completion: nil)
    }

    func cell(_ cell: PHHoleCommentTableViewCell, didPressHideCommentButton button: UIButton) {
        guard let cid = cell.comment?.cid else { return }
        setCommentHidden(cid)
    }
}

extension PHHoleDetailViewController: PHHoleHiddenTableViewCellDelegate {

    func cell(_ cell: PHHoleHiddenTableViewCell, didPressDisplayButton button: UIButton) {
        guard let cid = cell.model?.cid else { return }
        setCommentDisplayed(cid)
    }
}

extension PHHoleDetailViewController {

    func isHiddenComment(_ cid: Int) -> Bool {
        return PHHoleDetailViewController.hiddenCids.contains(cid)
    }

    func setCommentHidden(_ cid: Int) {
        PHHoleDetailViewController.hiddenCids.insert(cid)
        reloadRowAt(cid: cid, animated: true, with: .fade)
    }

    func setCommentDisplayed(_ cid: Int) {
        PHHoleDetailViewController.hiddenCids.remove(cid)
        reloadRowAt(cid: cid, animated: true, with: .fade)
    }

    func reloadRowAt(cid: Int,
                     animated: Bool = false,
                     with animation: UITableView.RowAnimation = .middle)
    {
        guard let cell = tableView.visibleCells.first(where: { cell in
            switch cell {
            case let cell as PHHoleCommentTableViewCell:
                return cell.comment?.cid == cid
            case let cell as PHHoleHiddenTableViewCell:
                return cell.model?.cid == cid
            default:
                return false
            }
        }) else { return }
        tableView.reloadCell(cell, animated: animated, with: animation)
    }
}

extension PHHoleDetailViewController: PHHoleTranslucentWritingViewControllerDelegate {

    func writingViewWillAppear(_ writingViewController: PHHoleTranslucentWritingBaseViewController) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        hideTabBar(animated: true)
    }

    func writingViewDidDisappear(_ writingViewController: PHHoleTranslucentWritingBaseViewController) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        showTabBar(animated: true)
    }

    func writingViewHeader(_ writingViewController: PHHoleTranslucentWritingBaseViewController, didPressCancelButton button: UIButton) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        showTabBar(animated: true)
        writingViewController.dismiss(animated: true) { [weak writingViewController] in
            writingViewController?.reset()
        }
    }

    func writingViewHeader(_ writingViewController: PHHoleTranslucentWritingBaseViewController, didPressConfirmButton button: UIButton) {
        switch writingViewController {
        case let commentViewController as PHHoleWriteCommentViewController:
            submitComment(text: commentViewController.content)
        case let reportReasonViewController as PHHoleWriteReportReasonViewController:
            submitReport(reason: reportReasonViewController.content)
        default:
            break
        }
    }
}

extension PHHoleDetailViewController: PopMenuViewControllerDelegate {

    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        guard let post = self.post else { return }
        switch index {
        // Star/Attention
        case 0:
            toggleStar()
        // Comment
        case 1:
            popMenuViewController.dismiss(animated: true) { [weak self] in
                guard let strongSelf = self else { return }
                let controller = PHHoleWriteCommentViewController.shared
                controller.delegate = strongSelf
                strongSelf.present(controller, animated: true, completion: nil)
            }
        // Report
        case 2:
            guard !post.reported else {
                PHAlert(on: self)?.info(message: "You have already reported this post.")
                return
            }
            popMenuViewController.dismiss(animated: true) { [weak self] in
                guard let strongSelf = self else { return }
                let controller = PHHoleWriteReportReasonViewController.shared
                controller.delegate = strongSelf
                strongSelf.present(controller, animated: true, completion: nil)
            }
        // Reverse comments
        case 3:
            isReverseComments = !isReverseComments
        default:
            break
        }
    }
}

extension PHHoleDetailViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension PHHoleDetailViewController {

    func fetchPost() {
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        guard let post = self.post else { return }
        PHBackendAPI.request(PHBackendAPI.PKUHole.getPost(pid: post.pid, utoken: user.utoken), on: self) {
            [weak self] (detail: PHV2PKUHolePostOne) in
            if detail.post == nil {
                PHAlert(on: self)?.infoPostNotFound()
            } else {
                self?.post = detail.post
            }
        }
    }

    //
    // silent. the same as PHHolePostListBaseViewController.fetchPost
    //
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

    func toggleStar() {
        guard let post = self.post else { return }
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(
            PHBackendAPI.PKUHole.switchPostAttention(pid: post.pid, state: !post.starred, utoken: user.utoken),
            on: self,
            errorHandler: { [weak self] (error) in
                switch error {
                case let .v2Errcode(code, _, _):
                    guard let errcode = PHBackendError.Errcode(rawValue: code) else {
                        PHAlert(on: self)?.backendError(error)
                        return
                    }
                    switch errcode {
                    case .pkuHolePostNotFound:
                        PHAlert(on: self)?.infoPostNotFound()
                    case .pkuHolePostNotStarred:
                        PHAlert(on: self)?.warningOperationFailed(message: "You have not yet starred this post.")
                    case .pkuHolePostAlreadyStarred:
                        PHAlert(on: self)?.warningOperationFailed(message: "You have already starred this post.")
                    default:
                        PHAlert(on: self)?.backendError(error)
                    }
                default:
                    PHAlert(on: self)?.backendError(error)
                }
            },
            detailHandler: { [weak self] (_: PHV2NullDetail) in
                self?.navigationController?.viewControllers.forEach { viewController in
                    guard let holeViewController = viewController as? PHHolePostListBaseViewController else { return }
                    holeViewController.switchPostStar(to: !post.starred, pid: post.pid)
                }
                post.switchStar(to: !post.starred)
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
        )
    }

    func submitComment(text: String?) {
        guard let text = text else { return }
        guard let post = self.post else { return }
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(
            PHBackendAPI.PKUHole.submitComment(pid: post.pid, text: text, utoken: user.utoken),
            on: self,
            errorHandler: { [weak self] errcode, error in
                switch errcode {
                case .pkuHolePostNotFound:
                    PHAlert(on: self)?.infoPostNotFound()
                case .pkuHoleUserBeBanned:
                    PHAlert(on: self)?.infoUserBeBanned()
                case .pkuHoleContainsSensitiveWords:
                    PHAlert(on: self)?.infoContainSensitiveWords()
                case .operationNotAllowed:
                    PHAlert(on: self)?.warningOperationNotAllowed()
                default:
                    PHAlert(on: self)?.backendError(error)
                }
            },
            detailHandler: { [weak self] (_: PHV2NullDetail) in
                self?.navigationController?.viewControllers.forEach { viewController in
                    guard let holeViewController = viewController as? PHHolePostListBaseViewController else { return }
                    holeViewController.increasePostCommentCount(post.pid)
                }
                post.commentCount += 1
                self?.fetchPost()
                guard let viewController = self?.presentedViewController as? PHHoleWriteCommentViewController else { return }
                viewController.dismiss(animated: true) { [weak viewController] in
                    viewController?.reset()
                }
            }
        )
    }

    func submitReport(reason: String?) {
        guard let reason = reason else { return }
        guard let post = self.post else { return }
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(
            PHBackendAPI.PKUHole.submitReport(pid: post.pid, reason: reason, utoken: user.utoken),
            on: self,
            errorHandler: { [weak self] errcode, error in
                switch errcode {
                case .pkuHolePostNotFound:
                    PHAlert(on: self)?.infoPostNotFound()
                case .pkuHolePostAlreadyReported:
                    PHAlert(on: self)?.warningOperationFailed(message: "You have already reported this post")
                case .operationNotAllowed:
                    PHAlert(on: self)?.warningOperationNotAllowed()
                default:
                    PHAlert(on: self)?.backendError(error)
                }
            },
            detailHandler: { [weak self] (_: PHV2NullDetail) in
                self?.navigationController?.viewControllers.forEach { viewController in
                    guard let holeViewController = viewController as? PHHolePostListBaseViewController else { return }
                    holeViewController.setPostReported(post.pid)
                    holeViewController.setPostHidden(post.pid) // immediately hide this post
                }
                post.reported = true
                self?.fetchPost()
                guard let viewController = self?.presentedViewController as? PHHoleWriteReportReasonViewController else { return }
                viewController.dismiss(animated: true) { [weak viewController] in
                    viewController?.reset()
                }
            }
        )
    }
}
