//
//  PHHoleAttentionViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHHoleAttentionViewController: PHHolePostListBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Attention"

        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(handleRefresher(_:)), for: .valueChanged)

        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(PHBackendAPI.PKUHole.listAttention(startPid: nil, utoken: user.utoken), on: self) {
            [weak self] (detail: PHV2PKUHolePostList) in
            self?.posts = detail.posts
        }
    }

    @objc func handleRefresher(_ refresher: UIRefreshControl) {
        guard let user = PHUser.default else {
            refresher.endRefreshing()
            PHAlert(on: self)?.infoLoginRequired()
            return
        }
        PHBackendAPI.request(
            PHBackendAPI.PKUHole.listAttention(startPid: nil, utoken: user.utoken),
            on: self,
            errorHandler: { [weak self] error in
                refresher.endRefreshing()
                PHAlert(on: self)?.backendError(error)
            },
            detailHandler: { [weak self] (detail: PHV2PKUHolePostList) in
                refresher.endRefreshing()
                // reset the whole list
                self?.posts = detail.posts
            }
        )
    }

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
                PHBackendAPI.PKUHole.listAttention(startPid: minPid, utoken: user.utoken),
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
}
