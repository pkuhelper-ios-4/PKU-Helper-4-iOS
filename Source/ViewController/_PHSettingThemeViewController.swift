//
//  PHSettingThemeViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHSettingThemeViewController: PHBaseViewController {

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(PHSettingThemeTableViewCell.self, forCellReuseIdentifier: PHSettingThemeTableViewCell.identifier)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Theme (in development)"

        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PHSettingThemeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PHTheme.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PHSettingThemeTableViewCell.identifier, for: indexPath) as! PHSettingThemeTableViewCell
        cell.theme = PHTheme.allCases[indexPath.row]
        return cell
    }
}

extension PHSettingThemeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        PHThemeManager.theme = PHTheme.allCases[indexPath.row]
    }
}
