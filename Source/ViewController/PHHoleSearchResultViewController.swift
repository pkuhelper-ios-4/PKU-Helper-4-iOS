//
//  PHHoleSearchResultViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import PopMenu

class PHHoleSearchResultViewController: PHHolePostListBaseViewController {

    var keywords: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search Result of `\(keywords!)`"

        guard let user = PHUser.default else { return }
        PHBackendAPI.request(PHBackendAPI.PKUHole.searchPost(keywords: keywords, startPid: nil, utoken: user.utoken), on: self) {
            [weak self] (detail: PHV2PKUHolePostList) in
            self?.addPosts(detail.posts)
        }
    }

    override func setupRefreshFooter() {
        let footer = PHHolePostListBaseViewController.createDefaultRefreshFooter()
        tableView.configRefreshFooter(with: footer, container: self) { [weak self] in
            guard let keywords = self?.keywords else { return }
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
                PHBackendAPI.PKUHole.searchPost(keywords: keywords, startPid: minPid, utoken: user.utoken),
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
