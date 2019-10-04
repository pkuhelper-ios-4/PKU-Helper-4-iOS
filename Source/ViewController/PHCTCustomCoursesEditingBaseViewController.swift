//
//  PHCTCustomCoursesEditingBaseViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/20.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import PopupDialog

protocol PHCTCustomCoursesEditingViewControllerDelegate: AnyObject {

    func editingViewControllerDidSubmitChange(_ viewController: PHCTCustomCoursesEditingBaseViewController, newCourse: PHCourse, oldCourse: PHCourse?)
}

extension PHCTCustomCoursesEditingViewControllerDelegate {

    func editingViewControllerDidSubmitChange(_ viewController: PHCTCustomCoursesEditingBaseViewController, newCourse: PHCourse, oldCourse: PHCourse?) {}
}

class PHCTCustomCoursesEditingBaseViewController: PHBaseViewController {

    weak var delegate: PHCTCustomCoursesEditingViewControllerDelegate?

    static let sideSpacing: CGFloat = PHGlobal.sideSpacing
    static let textFieldHeight: CGFloat = PHGlobal.font.regular.pointSize * 3.5
    static let fieldInsetSpacing: CGFloat = PHGlobal.font.regular.pointSize * 1.2

    let courseNameTextField: UITextField = {
        let field = SkyFloatingLabelTextField()
        field.font = PHGlobal.font.regular
        field.placeholder = "Enter course name"
        field.title = "Course"
        field.titleFont = PHGlobal.font.small
        field.returnKeyType = .done
        return field
    }()

    let classesTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(PHCTCustomCoursesEditingClassTableViewCell.self, forCellReuseIdentifier: PHCTCustomCoursesEditingClassTableViewCell.identifier)
        view.register(PHCTCustomCoursesEditingAddClassTableViewCell.self, forCellReuseIdentifier: PHCTCustomCoursesEditingAddClassTableViewCell.identifier)
        view.register(PHCTCustomCoursesEditingEditClassTableViewCell.self, forCellReuseIdentifier: PHCTCustomCoursesEditingEditClassTableViewCell.identifier)
        view.register(PHCTCustomCoursesEditingClassTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: PHCTCustomCoursesEditingClassTableViewHeaderView.identifier)

        view.allowsSelection = true
        view.allowsMultipleSelection = false
        view.bounces = false
        view.showsVerticalScrollIndicator = false

        let sideSpacing = PHCTCustomCoursesEditingBaseViewController.sideSpacing

        view.separatorStyle = .singleLine
        view.separatorInset = UIEdgeInsets(px: sideSpacing, py: 0)

        view.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)

        return view
    }()

    private let classesTableHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let editingCell = PHCTCustomCoursesEditingEditClassTableViewCell()

    private var isUnfoldEditingCell: Bool = false {
        didSet {
            if oldValue != isUnfoldEditingCell {
                classesTableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
            }
            scrollToEditingCell()
        }
    }

    var originalCourse: PHCourse?

    var course: PHCourse = PHCourse() {
        didSet {
            courseNameTextField.text = course.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setNavigationBackButtonTarget(action: #selector(navBarBackButtonTapped(_:)))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(navBarDoneButtonTapped(_:)))

        courseNameTextField.delegate = self

        classesTableView.dataSource = self
        classesTableView.delegate = self

        editingCell.delegate = self

        view.addSubview(classesTableView)
        classesTableHeaderView.addSubview(courseNameTextField)

        let sideSpacing = PHCTCustomCoursesEditingBaseViewController.sideSpacing
        let textFieldHeight = PHCTCustomCoursesEditingBaseViewController.textFieldHeight
        let fieldInsetSpacing = PHCTCustomCoursesEditingBaseViewController.fieldInsetSpacing

        courseNameTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.bottom.equalToSuperview().inset(fieldInsetSpacing)
            make.height.equalTo(textFieldHeight).priority(.required)
        }

        classesTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    ///
    /// https://stackoverflow.com/questions/20982558/how-do-i-set-the-height-of-tableheaderview-uitableview-with-autolayout
    ///
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if classesTableView.tableHeaderView == nil {
            let headerView = classesTableHeaderView
            classesTableView.tableHeaderView = headerView
            var newFrame = CGRect(x: 0, y: 0, width: classesTableView.bounds.width, height: .greatestFiniteMagnitude)
            let newSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            newFrame.size.height = newSize.height
            headerView.frame = newFrame
            headerView.layoutSubviews()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        showTabBar(animated: animated)
    }
}

extension PHCTCustomCoursesEditingBaseViewController {

    @objc func navBarBackButtonTapped(_ button: UIButton) {
        editingCell.finishEditing(true)
        courseNameTextField.endEditing(true)
        if originalCourse == course {
            navigationController?.popViewController(animated: true)
        } else {

            let popup = PopupDialog(title: "Confirm quit",
                                    message: "All current changes will lose if you quit now.",
                                    image: PHAlert.warningHeaderImage,
                                    buttonAlignment: .horizontal,
                                    transitionStyle: .fadeIn)

            let quitButton = DestructiveButton(title: "QUIT") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }

            let cancelButton = CancelButton(title: "CANCEL", action: nil)

            popup.addButtons([quitButton, cancelButton])

            present(popup, animated: true, completion: nil)
        }
    }

    @objc func navBarDoneButtonTapped(_ item: UIBarButtonItem) {
        editingCell.finishEditing(true)
        courseNameTextField.endEditing(true)
        delegate?.editingViewControllerDidSubmitChange(self, newCourse: course, oldCourse: originalCourse)
        navigationController?.popViewController(animated: true)
    }
}

extension PHCTCustomCoursesEditingBaseViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return course.classes.count + 1
        case 1:
            return isUnfoldEditingCell ? 1 : 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 1 {
            return editingCell
        }

        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PHCTCustomCoursesEditingAddClassTableViewCell.identifier, for: indexPath) as! PHCTCustomCoursesEditingAddClassTableViewCell
            cell.textLabel?.text = "Add a new class ..."
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: PHCTCustomCoursesEditingClassTableViewCell.identifier, for: indexPath) as! PHCTCustomCoursesEditingClassTableViewCell
        let class_ = course.classes[indexPath.row]
        cell.`class` = class_ // bind `class`

        return cell
    }
}

extension PHCTCustomCoursesEditingBaseViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let fieldInsetSpacing = PHCTCustomCoursesEditingBaseViewController.fieldInsetSpacing
        if section == 0 {
            return fieldInsetSpacing * 1.5 + PHGlobal.font.regular.pointSize
        } else {
            return fieldInsetSpacing
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? "Classes" : nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PHCTCustomCoursesEditingClassTableViewHeaderView.identifier) as! PHCTCustomCoursesEditingClassTableViewHeaderView
        return header
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? PHCTCustomCoursesEditingClassTableViewHeaderView else { return }
        header.titleLabel.text = header.textLabel?.text
        header.textLabel?.text = nil
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard indexPath.section == 0 else { return nil } // only allow selection for first classes list
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if courseNameTextField.isFirstResponder {
            courseNameTextField.endEditing(false)
        }
        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            let class_ = PHClass()

            course.classes.append(class_)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .middle)
            tableView.endUpdates()

            if isUnfoldEditingCell {
                // immediately bind to this new class
                editingCell.finishEditing(true)
                editingCell.`class` = class_
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                isUnfoldEditingCell = true // trigger scroll
            }
        } else {
            let class_ = course.classes[indexPath.row]
            if !isUnfoldEditingCell {
                editingCell.`class` = class_
                isUnfoldEditingCell = true
            } else {
                if editingCell.`class` === class_ {
                    tableView.deselectRow(at: indexPath, animated: true)
                    // tap the editing classCell will fold the editingCell
                    editingCell.finishEditing(true)
                    editingCell.`class` = nil
                    isUnfoldEditingCell = false
                } else {
                    // bind to current class
                    editingCell.finishEditing(true)
                    editingCell.`class` = class_
                    tableView.deselectAllRows(exclude: indexPath)
                    isUnfoldEditingCell = true // trigger scroll
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != 0 {
            return false
        } else if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            return false
        } else {
            return true
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let class_ = course.classes[indexPath.row]
            if isUnfoldEditingCell && editingCell.`class` === class_ {
                editingCell.`class` = nil
                isUnfoldEditingCell = false
                // remove observers
                findAllBoundCells(for: class_).forEach { $0.`class` = nil }
            }

            course.classes.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return self.tableView(tableView, canEditRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("\(sourceIndexPath.row) to \(destinationIndexPath.row)")
    }

    func scrollToEditingCell() {
        guard isUnfoldEditingCell else { return }
        let indexPath = IndexPath(row: 0, section: 1)
        classesTableView.safeScrollToRow(at: indexPath, at: .middle, animated: true)
    }

    // find all observers
    func findAllBoundCells(for `class`: PHClass) -> [PHCTCustomCoursesEditingClassTableViewCell] {
        return classesTableView.visibleCells.filter { cell in
            guard let classCell = cell as? PHCTCustomCoursesEditingClassTableViewCell else { return false }
            return classCell.`class` === `class`
        } as! [PHCTCustomCoursesEditingClassTableViewCell]
    }
}

extension PHCTCustomCoursesEditingBaseViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(false)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        course.name = textField.text ?? ""
    }
}

extension PHCTCustomCoursesEditingBaseViewController: PHCTCustomCoursesEditingEditClassTableViewCellDelegate {

    func editingCell(_ cell: PHCTCustomCoursesEditingEditClassTableViewCell, textFieldDidBeginEditing textField: UITextField) {
        scrollToEditingCell()
    }

    func editingCell(_ cell: PHCTCustomCoursesEditingEditClassTableViewCell, didChangeClass `class`: PHClass) {
        // rebind to trigger didSet (notify observers)
        findAllBoundCells(for: `class`).forEach { $0.`class` = `class` }
    }
}


