//
//  PHSettingCourseTableViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/11.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class PHSettingCourseTableViewController: PHSettingBaseSubSettingViewController {

    @objc let standardSemesterBeginningRefreshButton: UIButton = {
        let button = UIButton()
        let font = PHGlobal.font.regular
        button.frame = CGRect(x: 0, y: 0, width: font.pointSize * 5, height: font.pointSize * 1.2)
        button.contentHorizontalAlignment = .right
        button.titleLabel?.font = font
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.titleForNormal = "Refresh"
        button.titleForDisabled = "Refreshing"
        button.titleColorForNormal = .lightGray
        return button
    }()

    @objc let customSemesterBeginningSwitcher: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()

    let semesterBeginningDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = PHGlobal.regionBJ.locale
        let now = PHGlobal.regionBJ.nowInThisRegion()
        let standardBeginning = Defaults[.standardSemesterBeginning]?.in(region: PHGlobal.regionBJ)
        let initDate = Defaults[.customSemesterBeginning]?.in(region: PHGlobal.regionBJ) ?? (standardBeginning ?? now)
        picker.date = initDate.date
        picker.minimumDate = now.dateByAdding(-1, .year).date
        picker.maximumDate = now.dateByAdding(1, .year).date
        return picker
    }()

    @objc private(set) lazy var semesterBeginningTextField: UITextField = {
        let field = UITextField()
        let font = PHGlobal.font.regular
        field.frame = CGRect(x: 0, y: 0, width: font.pointSize * 6, height: font.pointSize * 1.2)
        field.font = font
        field.textAlignment = .right
        field.textColor = .lightGray
        field.tintColor = .clear  // no cursor
        field.inputView = semesterBeginningDatePicker
        return field
    }()

    @objc let defaultExpandedHeaderSwitcher: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()

    @objc let defaultExpandedSideColumnSwitcher: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()

    @objc let courseColumnExpandableSwitcher: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()

    @objc let defaultExpandedTodaysCourseColumnSwitcher: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()

    let cellTextColorPicker: PHSingleColorPicker = {
        let picker = PHSingleColorPicker()
        picker.frame = CGRect(x: 0, y: 0, width: 0, height: PHGlobal.screenHeight * 0.4)
        picker.colorPool = defaultColorPool
        picker.selectedColor = Defaults[.courseTableCellTextColor] ?? PHCTClassCellView.defaultTextColor
        return picker
    }()

    @objc private(set) lazy var cellTextColorTextField: UITextField = {
        let field = UITextField()
        let font = PHGlobal.font.regular
        field.frame = CGRect(x: 0, y: 0, width: font.pointSize * 5, height: font.pointSize * 1.2)
        field.font = font
        field.textAlignment = .right
        field.textColor = .lightGray
        field.tintColor = .clear // no cursor
        field.inputView = cellTextColorPicker
        return field
    }()

    let colorPoolColorPicker: PHMultiColorPicker = {
        let picker = PHMultiColorPicker()
        picker.frame = CGRect(x: 0, y: 0, width: 0, height: PHGlobal.screenHeight * 0.4)
        picker.colorPool = defaultColorPool
        var usedColors = Defaults[.courseTableColorPool]
        picker.usedColors = usedColors.count > 0 ? usedColors : PHCTClassCellView.defaultColorPool
        return picker
    }()

    @objc private(set) lazy var colorPoolTextField: UITextField = {
        let field = UITextField()
        let font = PHGlobal.font.regular
        field.frame = CGRect(x: 0, y: 0, width: font.pointSize * 5, height: font.pointSize * 1.2)
        field.font = font
        field.textAlignment = .right
        field.textColor = .lightGray
        field.tintColor = .clear  // no cursor
        field.inputView = colorPoolColorPicker
        return field
    }()

    @objc let disableColorPoolSizeAlertSwitcher: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()

    @objc let hideOtherWeeksClassesSwither: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()

    let otherWeeksClassesColorPicker: PHSingleColorPicker = {
        let picker = PHSingleColorPicker()
        picker.frame = CGRect(x: 0, y: 0, width: 0, height: PHGlobal.screenHeight * 0.4)
        picker.colorPool = defaultColorPool
        picker.selectedColor = Defaults[.courseTableColorForOtherWeeksClasses] ?? PHCTClassCellView.defaultColorForHiddenClass
        return picker
    }()

    @objc private(set) lazy var otherWeeksClassesColorTextField: UITextField = {
        let field = UITextField()
        let font = PHGlobal.font.regular
        field.frame = CGRect(x: 0, y: 0, width: font.pointSize * 5, height: font.pointSize * 1.2)
        field.font = font
        field.textAlignment = .right
        field.textColor = .lightGray
        field.tintColor = .clear  // no cursor
        field.inputView = otherWeeksClassesColorPicker
        return field
    }()

    let userRandomSeedStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0.0
        stepper.maximumValue = 500.0
        stepper.stepValue = 1.0
        stepper.isContinuous = true
        stepper.autorepeat = true
        return stepper
    }()

    @objc private(set) lazy var userRandomSeedLabeledStepper: PHLabeledStepperView = {
        let view = PHLabeledStepperView()
        let font = view.titleLabel.font!
        let width = userRandomSeedStepper.frame.width + font.pointSize * 2
        let height = userRandomSeedStepper.frame.height
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        view.stepper = userRandomSeedStepper
        return view
    }()

    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = PHGlobal.regionBJ.locale
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Course Table"

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidePicker)))
    }

    override func setupControls() {

        customSemesterBeginningSwitcher.isOn = Defaults[.useCustomSemesterBeginning]
        semesterBeginningTextField.isEnabled = customSemesterBeginningSwitcher.isOn
        semesterBeginningTextField.text = dateFormatter.string(from: semesterBeginningDatePicker.date)

        defaultExpandedHeaderSwitcher.isOn = Defaults[.courseTableDefaultExpandedWeekdayHeader]
        defaultExpandedSideColumnSwitcher.isOn = Defaults[.courseTableDefaultExpandedSideColumn]
        courseColumnExpandableSwitcher.isOn = Defaults[.courseTableCourseColumnExpandable]
        defaultExpandedTodaysCourseColumnSwitcher.isOn = Defaults[.courseTableDefaultExpandedTodaysCourseColumn]

        cellTextColorTextField.text = cellTextColorPicker.selectedColor.hexString
        colorPoolTextField.text = "size: \(colorPoolColorPicker.usedColors.count)"
        disableColorPoolSizeAlertSwitcher.isOn = Defaults[.courseTableDisableColorPoolSizeAlert]
        hideOtherWeeksClassesSwither.isOn = Defaults[.courseTableHideOtherWeeksClasses]
        otherWeeksClassesColorTextField.isEnabled = !hideOtherWeeksClassesSwither.isOn
        otherWeeksClassesColorTextField.text = otherWeeksClassesColorPicker.selectedColor.hexString
        userRandomSeedStepper.value = Defaults[.courseTableUserRandomSeed]


        standardSemesterBeginningRefreshButton.addTarget(self, action: #selector(handleStandardSemesterBeginningRefreshButton(_:)), for: .touchUpInside)
        customSemesterBeginningSwitcher.addTarget(self, action: #selector(handleCustomSemesterBeginningSwitcher(_:)), for: .valueChanged)
        semesterBeginningDatePicker.addTarget(self, action: #selector(handleCustomSemesterBeginningDatePicker(_:)), for: .valueChanged)

        defaultExpandedHeaderSwitcher.addTarget(self, action: #selector(handleDefaultExpandedHeaderSwitcher(_:)), for: .valueChanged)
        defaultExpandedSideColumnSwitcher.addTarget(self, action: #selector(handleDefaultExpandedSideColumnSwitcher(_:)), for: .valueChanged)
        courseColumnExpandableSwitcher.addTarget(self, action: #selector(handleCourseColumnExpandableSwitcher(_:)), for: .valueChanged)
        defaultExpandedTodaysCourseColumnSwitcher.addTarget(self, action: #selector(handleDefaultExpandedTodaysCourseColumnSwitcher(_:)), for: .valueChanged)

        cellTextColorPicker.addTarget(self, action: #selector(handleCellTextColorPicker(_:)), for: .valueChanged)
        colorPoolColorPicker.addTarget(self, action: #selector(handleColorPoolColorPicker(_:)), for: .valueChanged)
        disableColorPoolSizeAlertSwitcher.addTarget(self, action: #selector(handleDisableColorPoolSizeAlertSwitcher(_:)), for: .valueChanged)
        hideOtherWeeksClassesSwither.addTarget(self, action: #selector(handleHideOtherWeeksClassesSwitcher(_:)), for: .valueChanged)
        otherWeeksClassesColorPicker.addTarget(self, action: #selector(handleOtherWeeksClassesColorPicker(_:)), for: .valueChanged)
        userRandomSeedStepper.addTarget(self, action: #selector(handleUserRandomSeedStepper(_:)), for: .valueChanged)
    }

    @objc func hidePicker() {
        [semesterBeginningTextField, cellTextColorTextField,
         colorPoolTextField, otherWeeksClassesColorTextField].forEach { view in
            view.resignFirstResponder()
        }
    }

    @objc func handleStandardSemesterBeginningRefreshButton(_ button: UIButton) {
        button.isEnabled = false  // require lock

        PHBackendAPI.request(
            PHBackendAPI.Base.getSemesterBeginning,
            on: self,
            errorHandler: { [weak self] error in
                PHAlert(on: self)?.backendError(error) {
                    button.isEnabled = true
                }
            },
            detailHandler: { (detail: PHV2BaseGetSemesterBeginning) in
                Defaults[.lastUpdateSemesterBeginning] = PHUtil.now()
                Defaults[.standardSemesterBeginning] = detail.date
                let timestamp = detail.date.timeIntervalSince1970.formatTimestamp(to: "yyyy-MM-dd")
                PHAlert(on: self)?.success(message: "Current standard semester beginning: \(timestamp)")
                button.isEnabled = true
            }
        )
    }


    @objc func handleCustomSemesterBeginningSwitcher(_ switcher: UISwitch) {
        Defaults[.useCustomSemesterBeginning] = switcher.isOn
        hidePicker()
        semesterBeginningTextField.isEnabled = switcher.isOn
    }

    @objc func handleCustomSemesterBeginningDatePicker(_ picker: UIDatePicker) {
        Defaults[.customSemesterBeginning] = picker.date
        semesterBeginningTextField.text = dateFormatter.string(from: picker.date)
    }


    @objc func handleDefaultExpandedHeaderSwitcher(_ switcher: UISwitch) {
        Defaults[.courseTableDefaultExpandedWeekdayHeader] = switcher.isOn
    }

    @objc func handleDefaultExpandedSideColumnSwitcher(_ switcher: UISwitch) {
        Defaults[.courseTableDefaultExpandedSideColumn] = switcher.isOn
    }

    @objc func handleCourseColumnExpandableSwitcher(_ switcher: UISwitch) {
        Defaults[.courseTableCourseColumnExpandable] = switcher.isOn
    }

    @objc func handleDefaultExpandedTodaysCourseColumnSwitcher(_ switcher: UISwitch) {
        Defaults[.courseTableDefaultExpandedTodaysCourseColumn] = switcher.isOn
    }


    @objc func handleCellTextColorPicker(_ picker: PHSingleColorPicker) {
        Defaults[.courseTableCellTextColor] = picker.selectedColor
        cellTextColorTextField.text = picker.selectedColor.hexString
    }

    @objc func handleColorPoolColorPicker(_ picker: PHMultiColorPicker) {
        Defaults[.courseTableColorPool] = picker.usedColors
        colorPoolTextField.text = "size: \(picker.usedColors.count)"
    }

    @objc func handleDisableColorPoolSizeAlertSwitcher(_ switcher: UISwitch) {
        Defaults[.courseTableDisableColorPoolSizeAlert] = switcher.isOn
    }

    @objc func handleHideOtherWeeksClassesSwitcher(_ switcher: UISwitch) {
        Defaults[.courseTableHideOtherWeeksClasses] = switcher.isOn
        hidePicker()
        otherWeeksClassesColorTextField.isEnabled = !switcher.isOn
    }

    @objc func handleOtherWeeksClassesColorPicker(_ picker: PHSingleColorPicker) {
        Defaults[.courseTableColorForOtherWeeksClasses] = picker.selectedColor
        otherWeeksClassesColorTextField.text = picker.selectedColor.hexString
    }

    @objc func handleUserRandomSeedStepper(_ stepper: UIStepper) {
        Defaults[.courseTableUserRandomSeed] = stepper.value
    }


    override func populateDataSource() -> TableKeys.DataSourceModel {
        return [
            [
                TableKeys.Header: "Semester Beginning",
                TableKeys.Rows: [
                    [
                        TableKeys.Title: "Refresh standard semester beginning",
                        TableKeys.AccessoryView: "standardSemesterBeginningRefreshButton",
                    ],
                    [
                        TableKeys.Title: "Use custom semester beginning",
                        TableKeys.AccessoryView: "customSemesterBeginningSwitcher",
                    ],
                    [
                        TableKeys.Title: "Custom semester beginning",
                        TableKeys.AccessoryView: "semesterBeginningTextField",
                    ]
                ]
            ],
            [
                TableKeys.Header: "Column expansion",
                TableKeys.Rows: [
                    [
                        TableKeys.Title: "Weekday header expanded by default",
                        TableKeys.AccessoryView: "defaultExpandedHeaderSwitcher",
                    ],
                    [
                        TableKeys.Title: "Side column expanded by default",
                        TableKeys.AccessoryView: "defaultExpandedSideColumnSwitcher",
                    ],
                    [
                        TableKeys.Title: "Course column expandable",
                        TableKeys.AccessoryView: "courseColumnExpandableSwitcher",
                    ],
                    [
                        TableKeys.Title: "Today's column expanded by default",
                        TableKeys.AccessoryView: "defaultExpandedTodaysCourseColumnSwitcher",
                    ]
                ]
            ],
            [
                TableKeys.Header: "Themes",
                TableKeys.Rows: [
                    [
                        TableKeys.Title: "Cell text color",
                        TableKeys.AccessoryView: "cellTextColorTextField",
                    ],
                    [
                        TableKeys.Title: "Cell color pool",
                        TableKeys.AccessoryView: "colorPoolTextField",
                    ],
                    [
                        TableKeys.Title: "Disable color pool size alert",
                        TableKeys.AccessoryView: "disableColorPoolSizeAlertSwitcher",
                    ],
                    [
                        TableKeys.Title: "Hide other week's classes",
                        TableKeys.AccessoryView: "hideOtherWeeksClassesSwither",
                    ],
                    [
                        TableKeys.Title: "Color for other week's classes",
                        TableKeys.AccessoryView: "otherWeeksClassesColorTextField",
                    ],
                    [
                        TableKeys.Title: "User random seed",
                        TableKeys.AccessoryView: "userRandomSeedLabeledStepper",
                    ]
                ]
            ]
        ]
    }
}

fileprivate extension PHSettingCourseTableViewController {

    static let defaultColorPool: [PHBaseColorPicker.ColorPoolSectionModel] = [
        (
            title: "Material",
            colors: [
                Color.Material.red50,
                Color.Material.red100,
                Color.Material.red200,
                Color.Material.red300,
                Color.Material.red400,
                Color.Material.red500,
                Color.Material.red600,
                Color.Material.red700,
                Color.Material.red800,
                Color.Material.red900,
                Color.Material.redA100,
                Color.Material.redA200,
                Color.Material.redA400,
                Color.Material.redA700,

                Color.Material.pink50,
                Color.Material.pink100,
                Color.Material.pink200,
                Color.Material.pink300,
                Color.Material.pink400,
                Color.Material.pink500,
                Color.Material.pink600,
                Color.Material.pink700,
                Color.Material.pink800,
                Color.Material.pink900,
                Color.Material.pinkA100,
                Color.Material.pinkA200,
                Color.Material.pinkA400,
                Color.Material.pinkA700,

                Color.Material.purple50,
                Color.Material.purple100,
                Color.Material.purple200,
                Color.Material.purple300,
                Color.Material.purple400,
                Color.Material.purple500,
                Color.Material.purple600,
                Color.Material.purple700,
                Color.Material.purple800,
                Color.Material.purple900,
                Color.Material.purpleA100,
                Color.Material.purpleA200,
                Color.Material.purpleA400,
                Color.Material.purpleA700,

                Color.Material.deepPurple50,
                Color.Material.deepPurple100,
                Color.Material.deepPurple200,
                Color.Material.deepPurple300,
                Color.Material.deepPurple400,
                Color.Material.deepPurple500,
                Color.Material.deepPurple600,
                Color.Material.deepPurple700,
                Color.Material.deepPurple800,
                Color.Material.deepPurple900,
                Color.Material.deepPurpleA100,
                Color.Material.deepPurpleA200,
                Color.Material.deepPurpleA400,
                Color.Material.deepPurpleA700,

                Color.Material.indigo50,
                Color.Material.indigo100,
                Color.Material.indigo200,
                Color.Material.indigo300,
                Color.Material.indigo400,
                Color.Material.indigo500,
                Color.Material.indigo600,
                Color.Material.indigo700,
                Color.Material.indigo800,
                Color.Material.indigo900,
                Color.Material.indigoA100,
                Color.Material.indigoA200,
                Color.Material.indigoA400,
                Color.Material.indigoA700,

                Color.Material.blue50,
                Color.Material.blue100,
                Color.Material.blue200,
                Color.Material.blue300,
                Color.Material.blue400,
                Color.Material.blue500,
                Color.Material.blue600,
                Color.Material.blue700,
                Color.Material.blue800,
                Color.Material.blue900,
                Color.Material.blueA100,
                Color.Material.blueA200,
                Color.Material.blueA400,
                Color.Material.blueA700,

                Color.Material.lightBlue50,
                Color.Material.lightBlue100,
                Color.Material.lightBlue200,
                Color.Material.lightBlue300,
                Color.Material.lightBlue400,
                Color.Material.lightBlue500,
                Color.Material.lightBlue600,
                Color.Material.lightBlue700,
                Color.Material.lightBlue800,
                Color.Material.lightBlue900,
                Color.Material.lightBlueA100,
                Color.Material.lightBlueA200,
                Color.Material.lightBlueA400,
                Color.Material.lightBlueA700,

                Color.Material.cyan50,
                Color.Material.cyan100,
                Color.Material.cyan200,
                Color.Material.cyan300,
                Color.Material.cyan400,
                Color.Material.cyan500,
                Color.Material.cyan600,
                Color.Material.cyan700,
                Color.Material.cyan800,
                Color.Material.cyan900,
                Color.Material.cyanA100,
                Color.Material.cyanA200,
                Color.Material.cyanA400,
                Color.Material.cyanA700,

                Color.Material.teal50,
                Color.Material.teal100,
                Color.Material.teal200,
                Color.Material.teal300,
                Color.Material.teal400,
                Color.Material.teal500,
                Color.Material.teal600,
                Color.Material.teal700,
                Color.Material.teal800,
                Color.Material.teal900,
                Color.Material.tealA100,
                Color.Material.tealA200,
                Color.Material.tealA400,
                Color.Material.tealA700,

                Color.Material.green50,
                Color.Material.green100,
                Color.Material.green200,
                Color.Material.green300,
                Color.Material.green400,
                Color.Material.green500,
                Color.Material.green600,
                Color.Material.green700,
                Color.Material.green800,
                Color.Material.green900,
                Color.Material.greenA100,
                Color.Material.greenA200,
                Color.Material.greenA400,
                Color.Material.greenA700,

                Color.Material.lightGreen50,
                Color.Material.lightGreen100,
                Color.Material.lightGreen200,
                Color.Material.lightGreen300,
                Color.Material.lightGreen400,
                Color.Material.lightGreen500,
                Color.Material.lightGreen600,
                Color.Material.lightGreen700,
                Color.Material.lightGreen800,
                Color.Material.lightGreen900,
                Color.Material.lightGreenA100,
                Color.Material.lightGreenA200,
                Color.Material.lightGreenA400,
                Color.Material.lightGreenA700,

                Color.Material.lime50,
                Color.Material.lime100,
                Color.Material.lime200,
                Color.Material.lime300,
                Color.Material.lime400,
                Color.Material.lime500,
                Color.Material.lime600,
                Color.Material.lime700,
                Color.Material.lime800,
                Color.Material.lime900,
                Color.Material.limeA100,
                Color.Material.limeA200,
                Color.Material.limeA400,
                Color.Material.limeA700,

                Color.Material.yellow50,
                Color.Material.yellow100,
                Color.Material.yellow200,
                Color.Material.yellow300,
                Color.Material.yellow400,
                Color.Material.yellow500,
                Color.Material.yellow600,
                Color.Material.yellow700,
                Color.Material.yellow800,
                Color.Material.yellow900,
                Color.Material.yellowA100,
                Color.Material.yellowA200,
                Color.Material.yellowA400,
                Color.Material.yellowA700,

                Color.Material.amber50,
                Color.Material.amber100,
                Color.Material.amber200,
                Color.Material.amber300,
                Color.Material.amber400,
                Color.Material.amber500,
                Color.Material.amber600,
                Color.Material.amber700,
                Color.Material.amber800,
                Color.Material.amber900,
                Color.Material.amberA100,
                Color.Material.amberA200,
                Color.Material.amberA400,
                Color.Material.amberA700,

                Color.Material.orange50,
                Color.Material.orange100,
                Color.Material.orange200,
                Color.Material.orange300,
                Color.Material.orange400,
                Color.Material.orange500,
                Color.Material.orange600,
                Color.Material.orange700,
                Color.Material.orange800,
                Color.Material.orange900,
                Color.Material.orangeA100,
                Color.Material.orangeA200,
                Color.Material.orangeA400,
                Color.Material.orangeA700,

                Color.Material.deepOrange50,
                Color.Material.deepOrange100,
                Color.Material.deepOrange200,
                Color.Material.deepOrange300,
                Color.Material.deepOrange400,
                Color.Material.deepOrange500,
                Color.Material.deepOrange600,
                Color.Material.deepOrange700,
                Color.Material.deepOrange800,
                Color.Material.deepOrange900,
                Color.Material.deepOrangeA100,
                Color.Material.deepOrangeA200,
                Color.Material.deepOrangeA400,
                Color.Material.deepOrangeA700,

                Color.Material.brown50,
                Color.Material.brown100,
                Color.Material.brown200,
                Color.Material.brown300,
                Color.Material.brown400,
                Color.Material.brown500,
                Color.Material.brown600,
                Color.Material.brown700,
                Color.Material.brown800,
                Color.Material.brown900,

                Color.Material.grey50,
                Color.Material.grey100,
                Color.Material.grey200,
                Color.Material.grey300,
                Color.Material.grey400,
                Color.Material.grey500,
                Color.Material.grey600,
                Color.Material.grey700,
                Color.Material.grey800,
                Color.Material.grey900,

                Color.Material.blueGrey50,
                Color.Material.blueGrey100,
                Color.Material.blueGrey200,
                Color.Material.blueGrey300,
                Color.Material.blueGrey400,
                Color.Material.blueGrey500,
                Color.Material.blueGrey600,
                Color.Material.blueGrey700,
                Color.Material.blueGrey800,
                Color.Material.blueGrey900,

                Color.Material.black,
                Color.Material.white,
            ]
        ),
        (
            title: "Flat UI v1",
            colors: [
                Color.FlatUI.turquoise,
                Color.FlatUI.greenSea,
                Color.FlatUI.emerald,
                Color.FlatUI.nephritis,
                Color.FlatUI.peterRiver,
                Color.FlatUI.belizeHole,
                Color.FlatUI.amethyst,
                Color.FlatUI.wisteria,
                Color.FlatUI.wetAsphalt,
                Color.FlatUI.midnightBlue,
                Color.FlatUI.sunFlower,
                Color.FlatUI.flatOrange,
                Color.FlatUI.carrot,
                Color.FlatUI.pumkin,
                Color.FlatUI.alizarin,
                Color.FlatUI.pomegranate,
                Color.FlatUI.clouds,
                Color.FlatUI.silver,
                Color.FlatUI.asbestos,
                Color.FlatUI.concerte,
            ]
        ),
        (
            title: "iOS",
            colors: [
                UIColor.black,
                UIColor.darkGray,
                UIColor.lightGray,
                UIColor.white,
                UIColor.gray,
                UIColor.red,
                UIColor.green,
                UIColor.blue,
                UIColor.cyan,
                UIColor.yellow,
                UIColor.magenta,
                UIColor.orange,
                UIColor.purple,
                UIColor.brown,
            ]
        ),
        (
            title: "CSS",
            colors: [
                Color.CSS.aliceBlue,
                Color.CSS.antiqueWhite,
                Color.CSS.aqua,
                Color.CSS.aquamarine,
                Color.CSS.azure,
                Color.CSS.beige,
                Color.CSS.bisque,
                Color.CSS.black,
                Color.CSS.blanchedAlmond,
                Color.CSS.blue,
                Color.CSS.blueViolet,
                Color.CSS.brown,
                Color.CSS.burlyWood,
                Color.CSS.cadetBlue,
                Color.CSS.chartreuse,
                Color.CSS.chocolate,
                Color.CSS.coral,
                Color.CSS.cornflowerBlue,
                Color.CSS.cornsilk,
                Color.CSS.crimson,
                Color.CSS.cyan,
                Color.CSS.darkBlue,
                Color.CSS.darkCyan,
                Color.CSS.darkGoldenRod,
                Color.CSS.darkGray,
                Color.CSS.darkGrey,
                Color.CSS.darkGreen,
                Color.CSS.darkKhaki,
                Color.CSS.darkMagenta,
                Color.CSS.darkOliveGreen,
                Color.CSS.darkOrange,
                Color.CSS.darkOrchid,
                Color.CSS.darkRed,
                Color.CSS.darkSalmon,
                Color.CSS.darkSeaGreen,
                Color.CSS.darkSlateBlue,
                Color.CSS.darkSlateGray,
                Color.CSS.darkSlateGrey,
                Color.CSS.darkTurquoise,
                Color.CSS.darkViolet,
                Color.CSS.deepPink,
                Color.CSS.deepSkyBlue,
                Color.CSS.dimGray,
                Color.CSS.dimGrey,
                Color.CSS.dodgerBlue,
                Color.CSS.fireBrick,
                Color.CSS.floralWhite,
                Color.CSS.forestGreen,
                Color.CSS.fuchsia,
                Color.CSS.gainsboro,
                Color.CSS.ghostWhite,
                Color.CSS.gold,
                Color.CSS.goldenRod,
                Color.CSS.gray,
                Color.CSS.grey,
                Color.CSS.green,
                Color.CSS.greenYellow,
                Color.CSS.honeyDew,
                Color.CSS.hotPink,
                Color.CSS.indianRed,
                Color.CSS.indigo,
                Color.CSS.ivory,
                Color.CSS.khaki,
                Color.CSS.lavender,
                Color.CSS.lavenderBlush,
                Color.CSS.lawnGreen,
                Color.CSS.lemonChiffon,
                Color.CSS.lightBlue,
                Color.CSS.lightCoral,
                Color.CSS.lightCyan,
                Color.CSS.lightGoldenRodYellow,
                Color.CSS.lightGray,
                Color.CSS.lightGrey,
                Color.CSS.lightGreen,
                Color.CSS.lightPink,
                Color.CSS.lightSalmon,
                Color.CSS.lightSeaGreen,
                Color.CSS.lightSkyBlue,
                Color.CSS.lightSlateGray,
                Color.CSS.lightSlateGrey,
                Color.CSS.lightSteelBlue,
                Color.CSS.lightYellow,
                Color.CSS.lime,
                Color.CSS.limeGreen,
                Color.CSS.linen,
                Color.CSS.magenta,
                Color.CSS.maroon,
                Color.CSS.mediumAquaMarine,
                Color.CSS.mediumBlue,
                Color.CSS.mediumOrchid,
                Color.CSS.mediumPurple,
                Color.CSS.mediumSeaGreen,
                Color.CSS.mediumSlateBlue,
                Color.CSS.mediumSpringGreen,
                Color.CSS.mediumTurquoise,
                Color.CSS.mediumVioletRed,
                Color.CSS.midnightBlue,
                Color.CSS.mintCream,
                Color.CSS.mistyRose,
                Color.CSS.moccasin,
                Color.CSS.navajoWhite,
                Color.CSS.navy,
                Color.CSS.oldLace,
                Color.CSS.olive,
                Color.CSS.oliveDrab,
                Color.CSS.orange,
                Color.CSS.orangeRed,
                Color.CSS.orchid,
                Color.CSS.paleGoldenRod,
                Color.CSS.paleGreen,
                Color.CSS.paleTurquoise,
                Color.CSS.paleVioletRed,
                Color.CSS.papayaWhip,
                Color.CSS.peachPuff,
                Color.CSS.peru,
                Color.CSS.pink,
                Color.CSS.plum,
                Color.CSS.powderBlue,
                Color.CSS.purple,
                Color.CSS.rebeccaPurple,
                Color.CSS.red,
                Color.CSS.rosyBrown,
                Color.CSS.royalBlue,
                Color.CSS.saddleBrown,
                Color.CSS.salmon,
                Color.CSS.sandyBrown,
                Color.CSS.seaGreen,
                Color.CSS.seaShell,
                Color.CSS.sienna,
                Color.CSS.silver,
                Color.CSS.skyBlue,
                Color.CSS.slateBlue,
                Color.CSS.slateGray,
                Color.CSS.slateGrey,
                Color.CSS.snow,
                Color.CSS.springGreen,
                Color.CSS.steelBlue,
                Color.CSS.tan,
                Color.CSS.teal,
                Color.CSS.thistle,
                Color.CSS.tomato,
                Color.CSS.turquoise,
                Color.CSS.violet,
                Color.CSS.wheat,
                Color.CSS.white,
                Color.CSS.whiteSmoke,
                Color.CSS.yellow,
                Color.CSS.yellowGreen,
            ]
        ),
        (
            title: "PKU Helper 2 iOS",
            colors: [
                Color(hex: 0x1FB3EC)!,
                Color(hex: 0xF57E8B)!,
                Color(hex: 0x28C89B)!,
                Color(hex: 0xB98CDC)!,
                Color(hex: 0xFC8D4A)!,
                Color(hex: 0x71A0F3)!,
                Color(hex: 0xFDB92E)!,
                Color(hex: 0x2C61F8)!,
            ]
        ),
        (
            title: "PKU Helper 3 Android",
            colors: [
                Color(hex: 0xAAA3DB)!,
                Color(hex: 0x86ACE9)!,
                Color(hex: 0x92D261)!,
                Color(hex: 0x80D8A3)!,
                Color(hex: 0xF1C672)!,
                Color(hex: 0xFDAD88)!,
                Color(hex: 0xADBEFF)!,
                Color(hex: 0x94D6FA)!,
                Color(hex: 0xC3B5F6)!,
                Color(hex: 0x99CCFF)!,
                Color(hex: 0xFBA6ED)!,
                Color(hex: 0xEE8262)!,
                Color(hex: 0xEE6363)!,
                Color(hex: 0xEEB4B4)!,
                Color(hex: 0xD2B48C)!,
                Color(hex: 0xCD9B9B)!,
                Color(hex: 0x5F9EA0)!,
            ]
        ),
        (
            title: "Google Calendar",
            colors: [
                Color(hex: 0xad1457)!,
                Color(hex: 0xd61b5f)!,
                Color(hex: 0xd60000)!,
                Color(hex: 0xe77c76)!,
                Color(hex: 0xf4531f)!,
                Color(hex: 0xef6c00)!,
                Color(hex: 0xef9302)!,
                Color(hex: 0xf4c128)!,
                Color(hex: 0xe5c443)!,
                Color(hex: 0xc0ca35)!,
                Color(hex: 0x7db344)!,
                Color(hex: 0x31b77a)!,
                Color(hex: 0x0a8044)!,
                Color(hex: 0x009788)!,
                Color(hex: 0x039be4)!,
                Color(hex: 0x4286f5)!,
                Color(hex: 0x3f51b3)!,
                Color(hex: 0x7988cd)!,
                Color(hex: 0xb39ddb)!,
                Color(hex: 0x9d6aaf)!,
                Color(hex: 0x8e24aa)!,
                Color(hex: 0x795547)!,
                Color(hex: 0x616161)!,
                Color(hex: 0xa79b8d)!,
            ]
        ),
        (
            title: "Design Seeds",
            colors: [
                Color(hex: 0xF4D9DF)!,
                Color(hex: 0xF0C5D6)!,
                Color(hex: 0xD1534F)!,
                Color(hex: 0x913737)!,
                Color(hex: 0xF7E3DE)!,
                Color(hex: 0xF8C4A1)!,
                Color(hex: 0xF08264)!,
                Color(hex: 0x806648)!,
                Color(hex: 0xE8E5DA)!,
                Color(hex: 0xFFF3C8)!,
                Color(hex: 0xFEE0A1)!,
                Color(hex: 0xA4B593)!,
                Color(hex: 0xDEE6C3)!,
                Color(hex: 0xC5DB91)!,
                Color(hex: 0x6cb77e)!,
                Color(hex: 0x3F4C3B)!,
                Color(hex: 0xADD1C3)!,
                Color(hex: 0x76A693)!,
                Color(hex: 0x377A71)!,
                Color(hex: 0x294743)!,
                Color(hex: 0xD1EFF0)!,
                Color(hex: 0xA4DCDE)!,
                Color(hex: 0x519C90)!,
                Color(hex: 0x23313D)!,
                Color(hex: 0xDAEEFA)!,
                Color(hex: 0x86C1E0)!,
                Color(hex: 0x4181A1)!,
                Color(hex: 0x18292D)!,
                Color(hex: 0xD4D4E4)!,
                Color(hex: 0x7C83A8)!,
                Color(hex: 0x1F274D)!,
                Color(hex: 0x10131F)!,
                Color(hex: 0xF0E7EF)!,
                Color(hex: 0xAF8BB7)!,
                Color(hex: 0x554475)!,
                Color(hex: 0x645B75)!,
                Color(hex: 0xD6C6B6)!,
                Color(hex: 0xB29E8A)!,
                Color(hex: 0x847364)!,
                Color(hex: 0x464543)!,
                Color(hex: 0xD0D2D9)!,
                Color(hex: 0x9FA1A8)!,
                Color(hex: 0x62636B)!,
                Color(hex: 0x1A1A1A)!,
            ]
        ),
        (
            title: "Alice",
            colors: [
                Color(hex: 0xfc3d5d)!,
                Color(hex: 0xee7589)!,
                Color(hex: 0xffa3b2)!,
                Color(hex: 0xffcfd7)!,
                Color(hex: 0xec9393)!,
                Color(hex: 0xeaabab)!,
                Color(hex: 0xe8c4c4)!,
                Color(hex: 0xffd2d2)!,
                Color(hex: 0xb39ef3)!,
                Color(hex: 0xc2b2f3)!,
                Color(hex: 0xd8cdf7)!,
                Color(hex: 0xf6f3ff)!,
                Color(hex: 0xfd7044)!,
                Color(hex: 0xf9ab67)!,
                Color(hex: 0xf8be8c)!,
                Color(hex: 0xffdaba)!,
                Color(hex: 0xf4f967)!,
                Color(hex: 0xfae966)!,
                Color(hex: 0xfcf19a)!,
                Color(hex: 0xfef9d3)!,
                Color(hex: 0x35a368)!,
                Color(hex: 0x21e17a)!,
                Color(hex: 0x73d5a1)!,
                Color(hex: 0xc9f7df)!,
                Color(hex: 0x35b1ca)!,
                Color(hex: 0x68d3e8)!,
                Color(hex: 0x93e6f7)!,
                Color(hex: 0xd3f3fa)!,
                Color(hex: 0x3ee5b8)!,
                Color(hex: 0x7befd0)!,
                Color(hex: 0xaff5e2)!,
                Color(hex: 0xc0e5db)!,
            ]
        )
    ]
}
