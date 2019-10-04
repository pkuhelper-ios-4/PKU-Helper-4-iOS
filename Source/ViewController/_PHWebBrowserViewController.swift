//
//  PHWebBrowserViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/9.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit
import WebKit

/// Reference:
/// ================
/// 1. https://gist.github.com/fxm90/50d6c73d07c4d9755981b9bb4c5ab931
/// 2. http://tommikivimaki.com/blog/2018/06/29/how-to-make-a-progress-bar-for-wkwebview/
///
class PHWebBrowserViewController: PHBaseViewController {

    let webView: WKWebView = {
        let view = WKWebView()
        view.allowsBackForwardNavigationGestures = true
        view.scrollView.bounces = false
        return view
    }()

    let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.isHidden = true
        return view
    }()

    // The observation object for the progress of the web view (we only receive notifications until it is deallocated).
    private var estimatedProgressObserver: NSKeyValueObservation?

    private(set) var url: URL?

    convenience init(title: String?, url: URL?) {
        self.init()
        self.title = title
        self.url = url
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.backIndicatorImage = R.image.navbar.close()
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = R.image.navbar.close()

        let itemForward = UIBarButtonItem(image: R.image.navbar.forward(), style: .plain, target: self, action: #selector(forwardButtonTapped(sender:)))
        let itemBack = UIBarButtonItem(image: R.image.navbar.back(), style: .plain, target: self, action: #selector(backButtonTapped(sender:)))
        let itemReload = UIBarButtonItem(image: R.image.navbar.refresh(), style: .plain, target: self, action: #selector(reloadButtonTapped(sender:)))

        navigationItem.rightBarButtonItems = [itemForward, itemBack, itemReload]

        webView.navigationDelegate = self

        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        navigationController?.navigationBar.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(2.0)
        }

        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
        }

        guard let url = url else { return }
        webView.load(URLRequest(url: url))
    }

    private func setupRightBarButtonConstraints() {
        guard let items = navigationItem.rightBarButtonItems else { return }
        var counter = 0
        for item in items {
            if let buttonView = item.value(forKey: "view") as? UIView {
                for case let button as UIButton in buttonView.subviews {
                    button.snp.makeConstraints { make in
                        make.center.equalToSuperview()
                        make.left.right.leading.trailing.equalToSuperview().inset(0).priority(.required)
                    }
                    counter += 1
                }
                buttonView.superview!.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.right.equalToSuperview().priority(.required)
                }
            }
        }
        if counter == 3 {
            // Ensure that all buttons have been created
            isSetupRightBarButtonConstraints = true
        }
    }

    private var isSetupRightBarButtonConstraints: Bool = false

    // Delay setup bar buttons by Listening this property
    // Because the buttons of rightBarButtonItems doesn't exist in viewDidLoad method
    override var isViewLoaded: Bool {
        if !isSetupRightBarButtonConstraints {
            setupRightBarButtonConstraints()
        }
        return super.isViewLoaded
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        showTabBar(animated: true)
        if !progressView.isHidden {
            progressView.isHidden = true
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension PHWebBrowserViewController {

    func showProgressBar() {
        if progressView.isHidden {
            progressView.isHidden = false
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 1
        }, completion: nil)
    }

    func hideProgressBar() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 0
        }, completion: { isFinished in
            // Update `isHidden` flag accordingly:
            //  - set to `true` in case animation was completly finished.
            //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
            self.progressView.isHidden = isFinished
        })
    }

    @objc func reloadButtonTapped(sender: UIBarButtonItem) {
        webView.reload()
    }

    @objc func backButtonTapped(sender: UIBarButtonItem) {
        webView.goBack()
    }

    @objc func forwardButtonTapped(sender: UIBarButtonItem) {
        webView.goForward()
    }
}

// By implementing the `WKNavigationDelegate` we can update the visibility of the `progressView` according to the `WKNavigation` loading progress.
// The view-visibility updates are based on my gist [fxm90/UIView+AnimateIsHidden.swift](https://gist.github.com/fxm90/723b5def31b46035cd92a641e3b184f6)
extension PHWebBrowserViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showProgressBar()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressBar()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideProgressBar()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        PHAlert(on: self)?.error(error: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideProgressBar()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        PHAlert(on: self)?.error(error: error)
    }
}
**/
