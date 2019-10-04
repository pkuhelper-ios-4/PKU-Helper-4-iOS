//
//  PHTestColorPickerViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit

class PHTestColorPickerViewController: PHBaseViewController {

    let editTextField: UITextField = {
        let field = UITextField()
        field.text = "Show Color Picker"
        field.textColor = .white
        field.backgroundColor = .blue
        return field
    }()

    let colorPicker: PHMultiColorPicker = {
        let view = PHMultiColorPicker()
        view.frame = CGRect(x: 0, y: 0, width: 0, height: PHGlobal.screenHeight * 0.4)
        view.colorPool = colorPool
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Color Picker"

        editTextField.inputView = colorPicker

        view.addSubview(editTextField)

        editTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview().offset(-PHGlobal.screenHeight * 0.2)
        }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    @objc func hideKeyboard() {
        colorPicker.resignFirstResponder()
    }
}

extension PHTestColorPickerViewController {

    static let colorPool: [UIColor] = [

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
}
**/
