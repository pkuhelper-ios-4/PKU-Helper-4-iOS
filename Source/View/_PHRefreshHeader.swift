//
//  PHRefreshHeader.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/15.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import PullToRefreshKit

/// Reference:
/// ===============
/// 1. https://github.com/LeoMobileDeveloper/PullToRefreshKit/blob/master/Demo/Demo/TaoBaoRefreshHeader.swift
/// 2. https://github.com/LeoMobileDeveloper/PullToRefreshKit/blob/master/Sources/PullToRefreshKit/Classes/Header.swift
///
class PHRefreshHeader: UIView, RefreshableHeader {

    let circleLayer = CAShapeLayer()
    let arrowLayer = CAShapeLayer()
    let stateTextLabel = UILabel()
    let stateImageView = UIImageView()

    private(set) var headerText: [RefreshKitHeaderText: String] = [
        .pullToRefresh: "Pull to refresh",
        .releaseToRefresh: "Release to refresh",
        .refreshSuccess: "Update successful",
        .refreshFailure: "Update failed",
        .refreshing: "Refreshing ...",
    ]

    func setText(_ text: String, mode: RefreshKitHeaderText) {
        headerText[mode] = text
    }

    // MARK: for RefreshableHeader protocol
    var headerHeight: CGFloat = 60.0
    var headerCenterYOffset: CGFloat = 0.0
    var headerHeightForFireRefreshing: CGFloat = 60.0
    var headerHeightForRefreshingState: CGFloat = 60.0

    var refreshingResultShowingTime: TimeInterval = 1.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpCircleLayer()
        setUpArrowLayer()
        stateTextLabel.textAlignment = .left
        stateTextLabel.font = PHGlobal.font.small
        stateTextLabel.text = headerText[.pullToRefresh]
        stateImageView.isHidden = true
        stateImageView.image = R.image.header.success()?.template
        stateImageView.sizeToFit()
        addSubview(stateTextLabel)
        addSubview(stateImageView)
        tintColor = .lightGray
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let centerY = frame.height/2 + headerCenterYOffset

        stateTextLabel.frame = CGRect(x: 0, y: 0, width: 160, height: 40)
        stateTextLabel.center = CGPoint(x: frame.width/2 + 45, y: centerY)

        let stateSymbolCenter = CGPoint(x: frame.width/2 - 60, y: centerY)
        arrowLayer.position = stateSymbolCenter
        circleLayer.position = stateSymbolCenter

        stateImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        stateImageView.center = stateSymbolCenter
    }

    func setUpArrowLayer() {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 20, y: 15))
        bezierPath.addLine(to: CGPoint(x: 20, y: 25))
        bezierPath.addLine(to: CGPoint(x: 25,y: 20))
        bezierPath.move(to: CGPoint(x: 20, y: 25))
        bezierPath.addLine(to: CGPoint(x: 15, y: 20))
        arrowLayer.path = bezierPath.cgPath
        arrowLayer.fillColor = UIColor.clear.cgColor
        arrowLayer.lineWidth = 1.0
        circleLayer.lineCap = .round
        arrowLayer.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        arrowLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.addSublayer(arrowLayer)
    }

    func setUpCircleLayer() {
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20),
                                      radius: 12.0,
                                      startAngle: -CGFloat.pi/2,
                                      endAngle: CGFloat.pi/2 * 3.0,
                                      clockwise: true)
        circleLayer.path = bezierPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeStart = 0.05
        circleLayer.strokeEnd = 0.05
        circleLayer.lineWidth = 1.0
        circleLayer.lineCap = .round
        circleLayer.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.addSublayer(circleLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var tintColor: UIColor! {
        didSet {
            stateTextLabel.textColor = tintColor
            stateImageView.tintColor = tintColor
            arrowLayer.strokeColor = tintColor.cgColor
            circleLayer.strokeColor = tintColor.cgColor
        }
    }

    // MARK: -- RefreshableHeader --

    func heightForHeader() -> CGFloat {
        return headerHeight
    }

    func heightForFireRefreshing() -> CGFloat {
        return headerHeightForFireRefreshing
    }

    func heightForRefreshingState() -> CGFloat {
        return headerHeightForRefreshingState
    }

    func percentUpdateDuringScrolling(_ percent: CGFloat) {
        let adjustPercent = max(min(1.0, percent), 0.0)
        if adjustPercent == 1.0 {
            stateTextLabel.text = headerText[.releaseToRefresh]
        } else {
            stateTextLabel.text = headerText[.pullToRefresh]
        }
        circleLayer.strokeEnd = 0.05 + 0.9 * adjustPercent
    }

    func didBeginRefreshingState() {
        circleLayer.strokeEnd = 0.95
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.toValue = NSNumber(value: Double.pi * 2.0)
        rotateAnimation.duration = 0.6
        rotateAnimation.isCumulative = true
        rotateAnimation.repeatCount = 10000000
        circleLayer.add(rotateAnimation, forKey: "rotate")
        arrowLayer.isHidden = true
        stateImageView.isHidden = true
        stateImageView.image = nil
        stateTextLabel.text = headerText[.refreshing]
    }

    func didBeginHideAnimation(_ result: RefreshResult) {
        transitionWithOutAnimation {
            circleLayer.strokeEnd = 0.05
        }
        circleLayer.removeAllAnimations()

        stateImageView.transform = CGAffineTransform.identity
        stateImageView.image = nil
        stateImageView.isHidden = false

        switch result {
        case .success:
            stateTextLabel.text = headerText[.refreshSuccess]
            stateImageView.image = R.image.header.success()?.template
        case .failure:
            stateTextLabel.text = headerText[.refreshFailure]
            stateImageView.image = R.image.header.failure()?.template
        case .none:
            stateTextLabel.text = headerText[.pullToRefresh]
            stateImageView.isHidden = true
        }

        PHUtil.delay(refreshingResultShowingTime - 0.05) { [weak self] in
            self?.stateImageView.image = nil
            self?.stateImageView.isHidden = true
        }
    }

    func didCompleteHideAnimation(_ result: RefreshResult) {
        transitionWithOutAnimation {
            circleLayer.strokeEnd = 0.05
        }
        arrowLayer.isHidden = false

        stateImageView.image = nil
        stateImageView.isHidden = true
        stateTextLabel.text = headerText[.pullToRefresh]
    }

    func transitionWithOutAnimation(_ clousre: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        clousre()
        CATransaction.commit()
    }
}
**/
