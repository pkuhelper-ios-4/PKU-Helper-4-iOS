//
//  PHTestMainViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit

class PHTestMainViewController: PHBaseViewController {

    private static let reuseIdentifier = "TestCell"

    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(UITableViewCell.self, forCellReuseIdentifier: PHTestMainViewController.reuseIdentifier)
        view.allowsSelection = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Test"

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

}

extension PHTestMainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PHTestMainViewController.reuseIdentifier, for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Theme"
            bindSingleTapGestureRecognizer(cell, action: #selector(btn1TappedHandler(sender:)))
        case 1:
            cell.textLabel?.text = "Score"
            bindSingleTapGestureRecognizer(cell, action: #selector(btn2TappedHandler(sender:)))
        case 2:
            cell.textLabel?.text = "Course Table"
            bindSingleTapGestureRecognizer(cell, action: #selector(btn3TappedHandler(sender:)))
        case 3:
            cell.textLabel?.text = "Image Picker"
            bindSingleTapGestureRecognizer(cell, action: #selector(btn4TappedHandler(sender:)))
        case 4:
            cell.textLabel?.text = "Pop Menu"
            bindSingleTapGestureRecognizer(cell, action: #selector(btn5TappedHandler(sender:)))
        case 5:
            cell.textLabel?.text = "Write Post"
            bindSingleTapGestureRecognizer(cell, action: #selector(btn6TappedHandler(sender:)))
        case 6:
            cell.textLabel?.text = "Login"
            bindSingleTapGestureRecognizer(cell, action: #selector(btn7TappedHandler(sender:)))
        case 7:
            cell.textLabel?.text = "PKU Hole"
            bindSingleTapGestureRecognizer(cell, action: #selector(btn8TappedHandler(sender:)))
        case 8:
            cell.textLabel?.text = "Add a course"
            bindSingleTapGestureRecognizer(cell, action: #selector(btn9TappedHandler(sender:)))
        case 9:
            cell.textLabel?.text = "Message"
            bindSingleTapGestureRecognizer(cell, action: #selector(btn10TappedHandler(sender:)))
        default:
            break
        }
        return cell
    }
}

extension PHTestMainViewController: UITableViewDelegate {

}

extension PHTestMainViewController {

    @objc func btn1TappedHandler(sender: UIGestureRecognizer) {
        let vc = PHSettingThemeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func btn2TappedHandler(sender: UIGestureRecognizer) {
        let vc = PHScoreMainViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func btn3TappedHandler(sender: UIGestureRecognizer) {
        let vc = PHCTMainViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func btn4TappedHandler(sender: UIGestureRecognizer) {
        let vc = PHTestImagePickerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func btn5TappedHandler(sender: UIGestureRecognizer) {
        let vc = PHTestPopMenuViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func btn6TappedHandler(sender: UIGestureRecognizer) {
        let vc = PHHoleWritePostViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func btn7TappedHandler(sender: UIGestureRecognizer) {
        let vc = PHUserLoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func btn8TappedHandler(sender: UIGestureRecognizer) {
        let vc = PHTestPKUHoleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func btn9TappedHandler(sender: UIGestureRecognizer) {
        let vc = PHCTCustomCoursesAddCourseViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func btn10TappedHandler(sender: UIGestureRecognizer) {
        let vc = PHMessageMainViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func bindSingleTapGestureRecognizer(_ cell: UITableViewCell, action: Selector?) {
        cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
    }
}
**/
