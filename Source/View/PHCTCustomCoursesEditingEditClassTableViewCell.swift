//
//  PHCTCustomCoursesEditingEditClassTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/20.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftDate

protocol PHCTCustomCoursesEditingEditClassTableViewCellDelegate: AnyObject {

    func editingCell(_ cell: PHCTCustomCoursesEditingEditClassTableViewCell, textFieldDidBeginEditing textField: UITextField)
    func editingCell(_ cell: PHCTCustomCoursesEditingEditClassTableViewCell, didChangeClass `class`: PHClass)
}

extension PHCTCustomCoursesEditingEditClassTableViewCellDelegate {

    func editingCell(_ cell: PHCTCustomCoursesEditingEditClassTableViewCell, textFieldDidBeginEditing textField: UITextField) {}
    func editingCell(_ cell: PHCTCustomCoursesEditingEditClassTableViewCell, didChangeClass `class`: PHClass) {}
}

class PHCTCustomCoursesEditingEditClassTableViewCell: UITableViewCell {

    static let identifier = "PHCTCustomCoursesEditingEditClassTableViewCell"
    static let headerTitles: [String] = ["Week", "Weekday", "Start", "End"]

    weak var delegate: PHCTCustomCoursesEditingEditClassTableViewCellDelegate?

    let classTimePicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()

    let headerLabelsStackView = UIStackView(arrangedSubviews: [], axis: .horizontal, spacing: 0.0, alignment: .center, distribution: .fillEqually)

    let classroomTextField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.font = PHGlobal.font.regular
        field.placeholder = "Enter classroom of this course"
        field.title = "Classroom"
        field.titleFont = PHGlobal.font.small
        field.returnKeyType = .done
        return field
    }()

    var `class`: PHClass? {
        didSet {
            guard let class_ = self.`class` else { return }
            let row0 = PHClass.Week.allCases.firstIndex(of: class_.week) ?? 0
            let row1 = class_.weekday > 0 ? class_.weekday - 1 : 0
            let row2 = class_.start > 0 ? class_.start - 1 : 0
            let row3 = class_.end > 0 ? class_.end - 1 : 0
            let classroom = class_.classroom
            classTimePicker.selectRow(row0, inComponent: 0, animated: true)
            classTimePicker.selectRow(row1, inComponent: 1, animated: true)
            classTimePicker.selectRow(row2, inComponent: 2, animated: true)
            classTimePicker.selectRow(row3, inComponent: 3, animated: true)
            classroomTextField.text = classroom
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        classroomTextField.delegate = self

        classTimePicker.dataSource = self
        classTimePicker.delegate = self

        let headerTitles = PHCTCustomCoursesEditingEditClassTableViewCell.headerTitles
        let headerHeight = PHGlobal.font.regular.pointSize

        for component in 0..<numberOfComponents(in: classTimePicker) {
            let headerWidth = pickerView(classTimePicker, widthForComponent: component)
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: headerWidth, height: headerHeight))
            label.text = headerTitles[component].uppercased()
            label.font = PHGlobal.font.small
            label.textColor = .lightGray
            label.textAlignment = .center
            headerLabelsStackView.addArrangedSubview(label)
        }

        let sideSpacing = PHCTCustomCoursesEditingBaseViewController.sideSpacing
        let fieldHeight = PHCTCustomCoursesEditingBaseViewController.textFieldHeight
        let fieldInsetSpacing = PHCTCustomCoursesEditingBaseViewController.fieldInsetSpacing

        contentView.addSubviews([classroomTextField, headerLabelsStackView, classTimePicker])

        classroomTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(fieldInsetSpacing)
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.height.equalTo(fieldHeight).priority(.required)
        }

        headerLabelsStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(headerHeight * 3).priority(.required)
            make.top.equalTo(classroomTextField.snp.bottom).offset(fieldInsetSpacing)
        }

        classTimePicker.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(headerLabelsStackView.snp.bottom)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        headerLabelsStackView.addBorder(side: .top, thickness: 0.25, color: .lightGray)
        headerLabelsStackView.addBorder(side: .bottom, thickness: 0.25, color: .lightGray)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    func finishEditing(_ force: Bool) {
        classroomTextField.endEditing(force)
    }
}

extension PHCTCustomCoursesEditingEditClassTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.editingCell(self, textFieldDidBeginEditing: textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let class_ = self.`class` else { return }
        class_.classroom = textField.text ?? ""
        delegate?.editingCell(self, didChangeClass: class_)
    }
}

extension PHCTCustomCoursesEditingEditClassTableViewCell: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return PHClass.Week.allCases.count
        case 1:
            return PHCTCourseTableView.weekdays
        case 2, 3:
            return PHClass.lessonTimes.count
        default:
            return 0
        }
    }
}

extension PHCTCustomCoursesEditingEditClassTableViewCell: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {

        // for the spacing between columns of pickerview's components
        let factor: CGFloat = 0.94

        switch component {
        case 0, 1:
            return PHGlobal.screenWidth * 0.25 * factor
        case 2, 3:
            return PHGlobal.screenWidth * 0.25 * factor
        default:
            return 0.0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return PHClass.Week.allCases[row].displayName
        case 1:
            return PHClass.getWeekdayName(row + 1)
        case 2, 3:
            return String(row + 1)
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let class_ = self.`class` else { return }
        switch component {
        case 0:
            class_.week = PHClass.Week.allCases[row]
        case 1:
            class_.weekday = row + 1
        case 2:
            let start = row + 1
            class_.start = start

            let currentEndRow = classTimePicker.selectedRow(inComponent: 3)
            if row > currentEndRow {
                classTimePicker.selectRow(row, inComponent: 3, animated: true)
                class_.end = start
            }
        case 3:
            let end = row + 1
            class_.end = end

            let currentStartRow = classTimePicker.selectedRow(inComponent: 2)
            if currentStartRow > row {
                classTimePicker.selectRow(row, inComponent: 2, animated: true)
                class_.start = end
            }
        default:
            return
        }
        delegate?.editingCell(self, didChangeClass: class_)
    }
}

