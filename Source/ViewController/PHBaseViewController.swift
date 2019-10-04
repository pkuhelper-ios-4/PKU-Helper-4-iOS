//
//  PHBaseViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/6.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHBaseViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: custom title with network activity indicator

    private let activityTitleLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regularBold
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        indicator.style = .gray
        return indicator
    }()

    private lazy var activityView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubviews([activityIndicator, activityTitleLabel])
        stackView.axis = .horizontal
        stackView.spacing = PHGlobal.font.regularBold.pointSize / 2
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    var isNavigationBarNetworkActivityIndicatorVisable: Bool = false {
        didSet {
            if isNavigationBarNetworkActivityIndicatorVisable {
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            } else {
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
            }
        }
    }

    override var title: String? {
        didSet {
            activityTitleLabel.text = title
            activityTitleLabel.sizeToFit()
        }
    }

    // MARK: custom back button

    private var navigationBackButton: UIButton!

    func setNavigationBackButtonTarget(action: Selector) {
        navigationBackButton.removeTarget(nil, action: nil, for: .allTouchEvents)
        navigationBackButton.addTarget(self, action: action, for: .touchUpInside)
    }

    private func setupNavigationBackButton() {
        navigationBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        navigationBackButton.setImage(R.image.navbar.back()?.template, for: .normal)
        setNavigationBackButtonTarget(action: #selector(defaultBackButtonTapped(_:)))

//        navigationBackButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        navigationBackButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        navigationBackButton.hitTestEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navigationBackButton)

        guard let navigationController = self.navigationController else { return }
        if navigationController.viewControllers.count <= 1 {
            navigationBackButton.isHidden = true
        }
    }


    // MARK: custom pop gesture

//    private var navigationControllerPopGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
//
//    var isNavigationControllerPopGestureEnabled: Bool {
//        get {
//            return navigationControllerPopGestureRecognizer.isEnabled
//        }
//        set {
//            navigationControllerPopGestureRecognizer.isEnabled = newValue
//            if newValue == true {
//                view.addGestureRecognizer(navigationControllerPopGestureRecognizer)
//            } else {
//                view.removeGestureRecognizer(navigationControllerPopGestureRecognizer)
//            }
//        }
//    }
//
//    //
//    // https://blog.csdn.net/qxuewei/article/details/53939129
//    //
//    // The default pop gesture will be disabled if setup custom leftBarButtonItem.
//    // So let's setup a custom pop gesture too.
//    //
//    private func setupNavigationControllerPopGestureRecognizer() {
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//
//        guard let targetsValue: NSArray = navigationController?.interactivePopGestureRecognizer?.value(forKey: "_targets") as! NSArray? else { return }
//        guard let interactivePopGestureRecognizerTarget: NSObject = targetsValue.lastObject as! NSObject? else { return }
//        guard let target: Any = interactivePopGestureRecognizerTarget.value(forKey: "target") else { return }
//        let action: Selector = Selector(("handleNavigationTransition:"))
//
//        navigationControllerPopGestureRecognizer = UIPanGestureRecognizer(target: target, action: action)
//        navigationControllerPopGestureRecognizer.delegate = self
//        view.addGestureRecognizer(navigationControllerPopGestureRecognizer)
//    }

//    var isNavigationControllerPopGestureEnabled: Bool = true {
//        didSet {
//            navigationController?.interactivePopGestureRecognizer?.isEnabled = isNavigationControllerPopGestureEnabled
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        navigationItem.titleView = activityView

//        setupNavigationControllerPopGestureRecognizer()
        setupNavigationBackButton()

        //
        // http://www.hangge.com/blog/cache/detail_1092.html
        //
//        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("\(NSStringFromClass(type(of: self))) viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        debugPrint("\(NSStringFromClass(type(of: self))) viewDidAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        debugPrint("\(NSStringFromClass(type(of: self))) viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        debugPrint("\(NSStringFromClass(type(of: self))) viewDidDisappear")
    }

    @objc private func defaultBackButtonTapped(_ button: UIButton) {
        debugPrint("default back button tapped")
        navigationController?.popViewController(animated: true)
    }

    deinit{
        print("deinit \(NSStringFromClass(type(of: self)))")
    }
}

extension PHBaseViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController = self.navigationController else { return true }
        if navigationController.viewControllers.count <= 1 {
            return false // pop gesture will be disabled in root viewController
        }
        return true
    }
}
