//
//  PHTestPKUHoleViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/16.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit
import Alamofire

class PHTestPKUHoleViewController: PHBaseViewController {

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "PKUHole"

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

extension PHTestPKUHoleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "post list by start pid"
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellPostListByStartPidTapped)))
        case 1:
            cell.textLabel?.text = "multipart-form data"
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellMultipartFormDataTapped)))
        default:
            break
        }
        return cell
    }
}

extension PHTestPKUHoleViewController {

    @objc func cellPostListByStartPidTapped() {
        guard let user = PHUser.default else { return }
        PHBackendAPI.request(PHBackendAPI.PKUHole.listPostByStartPid(pid: nil, utoken: user.utoken), on: self) {
            (detail: PHV2PKUHolePostList) in
            debugPrint(detail)
        }
    }

    @objc func cellMultipartFormDataTapped() {

    }
}

extension PHTestPKUHoleViewController: UITableViewDelegate {

}
**/
