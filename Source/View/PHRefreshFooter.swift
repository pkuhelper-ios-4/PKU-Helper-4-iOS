//
//  PHRefreshFooter.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/15.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import PullToRefreshKit

///
/// Reference: https://github.com/LeoMobileDeveloper/PullToRefreshKit/blob/master/Sources/PullToRefreshKit/Classes/Footer.swift
///
class PHRefreshFooter: UIView, RefreshableFooter {

    public let spinner = UIActivityIndicatorView(style: .gray)
    public let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 140, height: 40))

    open var refreshMode = RefreshMode.scrollAndTap {
        didSet{
            tap.isEnabled = (refreshMode != .scroll)
            udpateTextLabelWithMode(refreshMode)
        }
    }

    fileprivate func udpateTextLabelWithMode(_ refreshMode: RefreshMode) {
        switch refreshMode {
        case .scroll:
            textLabel.text = footerText[.pullToRefresh]
        case .tap:
            textLabel.text = footerText[.tapToRefresh]
        case .scrollAndTap:
            textLabel.text = footerText[.scrollAndTapToRefresh]
        }
    }

    fileprivate var tap: UITapGestureRecognizer!
    fileprivate var footerText: [RefreshKitFooterText: String] = [
        .pullToRefresh: "Pull to refresh",
        .refreshing: "Refreshing ...",
        .noMoreData: "No more data",
        .tapToRefresh: "Tap to refresh",
        .scrollAndTapToRefresh: "Scroll or tap to load",
    ]

    // This function can only be called before Refreshing
    open func setText(_ text: String, mode: RefreshKitFooterText) {
        footerText[mode] = text
        textLabel.text = footerText[.pullToRefresh]
    }

    var footerHeightForFooter: CGFloat = 44.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
        addSubview(textLabel)
        udpateTextLabelWithMode(refreshMode)
        textLabel.font = PHGlobal.font.small
        textLabel.textAlignment = .left
        tap = UITapGestureRecognizer(target: self, action: #selector(catchTap(_:)))
        addGestureRecognizer(tap)
        tintColor = .lightGray
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.center = CGPoint(x: frame.size.width/2 + 25, y: frame.size.height/2)
        spinner.center = CGPoint(x: frame.width/2 - 80, y: frame.size.height/2)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open var tintColor: UIColor! {
        didSet {
            textLabel.textColor = tintColor
            spinner.color = tintColor
        }
    }

    @objc func catchTap(_ tap: UITapGestureRecognizer) {
        let scrollView = self.superview?.superview as? UIScrollView
        scrollView?.switchRefreshFooter(to: .refreshing)
    }

    // MARK: - Refreshable  -
    open func heightForFooter() -> CGFloat {
        return footerHeightForFooter
    }

    open func didBeginRefreshing() {
        self.isUserInteractionEnabled = true
        textLabel.text = footerText[.refreshing]
        spinner.startAnimating()
    }

    open func didEndRefreshing() {
        udpateTextLabelWithMode(refreshMode)
        spinner.stopAnimating()
    }

    open func didUpdateToNoMoreData() {
        self.isUserInteractionEnabled = false
        textLabel.text = footerText[.noMoreData]
    }

    open func didResetToDefault() {
        self.isUserInteractionEnabled = true
        udpateTextLabelWithMode(refreshMode)
    }

    open func shouldBeginRefreshingWhenScroll() -> Bool {
        return refreshMode != .tap
    }

    // MARK: - Handle touch -
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard refreshMode != .scroll else { return }
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard refreshMode != .scroll else { return }
        self.backgroundColor = .white
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard refreshMode != .scroll else { return }
        self.backgroundColor = .white
    }
}
