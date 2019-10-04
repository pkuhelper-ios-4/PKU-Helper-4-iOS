//
//  PHSettingBaseSubSettingViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/6.
//  Copyright © 2019 PKUHelper. All rights reserved.
//


import UIKit
import SwiftyUserDefaults

class PHSettingBaseSubSettingViewController: PHBaseViewController {

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(PHSettingSingleRowTableViewCell.self, forCellReuseIdentifier: PHSettingSingleRowTableViewCell.identifier)

        view.allowsSelection = false
        view.allowsMultipleSelection = false

        view.separatorStyle = .singleLine

        return view
    }()

    fileprivate(set) var dataSource: TableKeys.DataSourceModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        dataSource = populateDataSource()
        setupControls()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func populateDataSource() -> TableKeys.DataSourceModel { return [[:]] }
    func setupControls() {}
}

extension PHSettingBaseSubSettingViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getRows(at: section).count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getHeader(at: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = getRowModel(at: indexPath)
        guard let title = model[TableKeys.Title] else { return UITableViewCell() }

        let cell = tableView.dequeueReusableCell(withIdentifier: PHSettingSingleRowTableViewCell.identifier, for: indexPath) as! PHSettingSingleRowTableViewCell
        cell.textLabel?.text = title
        cell.accessoryView = getAccessoryView(model: model)
        return cell
    }
}

extension PHSettingBaseSubSettingViewController: UITableViewDelegate {

}

extension PHSettingBaseSubSettingViewController {

    typealias RowModel = [String: String]

    func getRows(at section: Int) -> [Any] {
        return dataSource[section][TableKeys.Rows] as! [Any]
    }

    func getHeader(at section: Int) -> String? {
        return dataSource[section][TableKeys.Header] as? String
    }

    func getRowModel(at indexPath: IndexPath) -> RowModel {
        return getRows(at: indexPath.section)[indexPath.row] as! RowModel
    }

    func getAccessoryView(model: RowModel) -> UIView? {
        guard let key = model[TableKeys.AccessoryView] else { return nil }
        guard let view = self.value(forKeyPath: key) as? UIView else { return nil }
        return view
    }

    struct TableKeys {

        typealias DataSourceModel = [[String: Any]]

        static let Header = "header"
        static let Rows = "rows"
        static let Title = "title"
        static let AccessoryView = "accessoryView"
    }
}
