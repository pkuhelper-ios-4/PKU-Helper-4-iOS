//
//  PHScoreDetailViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHScoreDetailViewController: PHBaseViewController {

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(PHScoreDetailTableViewCell.self, forCellReuseIdentifier: PHScoreDetailTableViewCell.identifier)
        view.separatorStyle = .singleLine
        view.allowsSelection = false
        view.bounces = false
        return view
    }()
    
    var score: PHCourseScore! {
        didSet {
            self.dataSource = [
                ("Course", score.course),
                ("Score", score.score),
                ("GPA", score.gpa?.format("%.2f") ?? PHScoreTableViewCell.nullField),
                ("Credit", score.credit.format("%g")),
                ("Type", score.type),
            ]
            tableView.reloadData()
        }
    }
    
    var dataSource: [PHScoreDetailTableViewCell.RowEntry]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Score Detail"

        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showTabBar(animated: animated)
    }
}

extension PHScoreDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PHScoreDetailTableViewCell.identifier, for: indexPath) as! PHScoreDetailTableViewCell
        cell.entry = dataSource?[indexPath.row]
        return cell
    }
}

extension PHScoreDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PHGlobal.font.regular.pointSize * 3 // Refer to PHScoreDetailTableViewCell.textLabel.font
    }
}
