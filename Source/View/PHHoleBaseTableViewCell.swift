//
//  PHHoleBaseTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/5.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyUserDefaults

protocol PHHoleBaseTableViewCellDelegate: AnyObject {

    func cell(_ cell: PHHoleBaseTableViewCell, didPressHeaderView headerView: UIView)
    func cell(_ cell: PHHoleBaseTableViewCell, didPressbodyView bodyView: UIView)
    func cell(_ cell: PHHoleBaseTableViewCell, didPressFooterView footerView: UIView)
    func cell(_ cell: PHHoleBaseTableViewCell, didPressIdLabel label: UILabel)
    func cell(_ cell: PHHoleBaseTableViewCell, didPressTagLabel label: UILabel)
    func cell(_ cell: PHHoleBaseTableViewCell, didPressContentTextView textView: UITextView)
    func cell(_ cell: PHHoleBaseTableViewCell, didPressContentImageView imageView: UIImageView)
    func cell(_ cell: PHHoleBaseTableViewCell, didPressTimeLabel label: UILabel)
    func cell(_ cell: PHHoleBaseTableViewCell, didDownloadContentImage imageView: UIImageView)
    func cell(_ cell: PHHoleBaseTableViewCell, didPressURLInContent url: URL)
    func cell(_ cell: PHHoleBaseTableViewCell, didPressPIDInContent pid: Int)
}

extension PHHoleBaseTableViewCellDelegate {

    func cell(_ cell: PHHoleBaseTableViewCell, didPressHeaderView headerView: UIView) {}
    func cell(_ cell: PHHoleBaseTableViewCell, didPressbodyView bodyView: UIView) {}
    func cell(_ cell: PHHoleBaseTableViewCell, didPressFooterView footerView: UIView) {}
    func cell(_ cell: PHHoleBaseTableViewCell, didPressIdLabel label: UILabel) {}
    func cell(_ cell: PHHoleBaseTableViewCell, didPressTagLabel label: UILabel) {}
    func cell(_ cell: PHHoleBaseTableViewCell, didPressContentTextView textView: UITextView) {}
    func cell(_ cell: PHHoleBaseTableViewCell, didPressContentImageView imageView: UIImageView) {}
    func cell(_ cell: PHHoleBaseTableViewCell, didPressTimeLabel label: UILabel) {}
    func cell(_ cell: PHHoleBaseTableViewCell, didDownloadContentImage imageView: UIImageView) {}
    func cell(_ cell: PHHoleBaseTableViewCell, didPressURLInContent url: URL) {}
    func cell(_ cell: PHHoleBaseTableViewCell, didPressPIDInContent pid: Int) {}
}

class PHHoleBaseTableViewCell: UITableViewCell {

    static let lineSpacing: CGFloat = PHGlobal.font.small.pointSize
    static let sideSpacing: CGFloat = 15
    static let iconSideLength = PHGlobal.font.regular.pointSize
    static let spacingBetweenIconAndLabel = PHGlobal.font.regular.pointSize * 0.5

    weak var delegate: PHHoleBaseTableViewCellDelegate?

    let headerView: UIView = {
        let view = UIView()
        return view
    }()

    let bodyView: UIView = {
        let view = UIView()
        return view
    }()

    let footerView: UIView = {
        let view = UIView()
        return view
    }()

    let cellSpacingView: UIView = {
        let view = UIView()
        view.backgroundColor = .groupTableViewBackground
        return view
    }()

    let topLeftStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        return view
    }()

    let bottomRightStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = spacingBetweenIconAndLabel * 2
        return view
    }()


    let idLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.smallBold
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()

    let tagLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.smallBold
        label.textColor = .blue
        label.isUserInteractionEnabled = true
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.small
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()

    let contentImageView: UIImageView = {
        let view = PHScaledHeightImageView()
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()

    let contentTextView: PHClickableTextView = {
        let view = PHClickableTextView(frame: .null)
        view.font = labelFont
        view.textColor = .black
        view.textAlignment = .left
        view.isScrollEnabled = false // MOST IMPORTANT !
        view.textContainer.lineFragmentPadding = 0.0
        view.rules = [urlRule, pidRule]
        return view
    }()

    static func createButton(
        image: UIImage,
        title: String? = nil,
        completion: ((UIButton) -> Void)? = nil)
        -> UIButton
    {
        let button = UIButton()
        button.imageForNormal = image.scaled(toWidth: iconSideLength)?.template
        button.tintColor = .black

        if let title = title {
            button.titleForNormal = title
            button.titleColorForNormal = .black
            button.titleLabel?.font = PHGlobal.font.small
            let spacing = spacingBetweenIconAndLabel
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        }

        completion?(button)
        return button
    }

    var postImage: PHBackendAPI.Image? {
        didSet {
            guard oldValue != postImage else { return }
            guard let image = postImage else { return }

            let sideSpacing = PHHoleBaseTableViewCell.sideSpacing
            let displayedImageWidth = PHGlobal.screenWidth - sideSpacing * 2

            guard image.isValid else {
                let placeholder = R.image.image_placeholder()!
                contentImageView.image = placeholder
                contentImageView.frame.size = placeholder.size * (displayedImageWidth / placeholder.size.width)
                return
            }

            let placeholder = UIImage(color: .lightGray, size: image.size)
            contentImageView.frame.size = image.size * (displayedImageWidth / image.width)
            contentImageView.kf.setImage(with: image.url, placeholder: placeholder) {
                [weak self] (image, error, cacheType, imageUrl) in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.cell(strongSelf, didDownloadContentImage: strongSelf.contentImageView)
            }
        }
    }

    fileprivate var defaultIsShowRelativeDate: Bool { return Defaults[.pkuHoleDefaultShowRelativeDate] }
    fileprivate var isShowRelativeDate: Bool!

    var timestamp: TimeInterval = PHUtil.now() {
        didSet {
            timeLabel.text = getTimeLabelText(for: timestamp)
        }
    }

    fileprivate var contentTextViewTapGestureRecognizer: UITapGestureRecognizer!


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        accessoryType = .none
        backgroundColor = .white

        isShowRelativeDate = defaultIsShowRelativeDate

        contentTextView.clickDelegate = self

        let sideSpacing = PHHoleBaseTableViewCell.sideSpacing
        let lineSpacing = PHHoleBaseTableViewCell.lineSpacing

        contentView.addSubviews([headerView, bodyView, footerView, cellSpacingView])

        headerView.addSubview(topLeftStackView)
        bodyView.addSubviews([contentImageView, contentTextView])
        footerView.addSubviews([timeLabel, bottomRightStackView])

        topLeftStackView.addArrangedSubviews([idLabel, tagLabel])
        topLeftStackView.spacing = PHGlobal.font.small.pointSize * 1.5

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.equalToSuperview().inset(lineSpacing)
        }

        bodyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.equalTo(headerView.snp.bottom)
        }

        footerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.equalTo(bodyView.snp.bottom).offset(lineSpacing * 1.5)
        }

        cellSpacingView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(footerView.snp.bottom)
            make.height.equalTo(lineSpacing)
        }

        topLeftStackView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }

        contentImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(lineSpacing)
        }

        contentTextView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(contentImageView.snp.bottom).offset(lineSpacing)
            make.bottom.equalToSuperview()
        }

        timeLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(lineSpacing)
        }

        bottomRightStackView.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.centerY.equalTo(timeLabel)
            make.bottom.equalToSuperview().inset(lineSpacing)
        }

        headerView.setContentCompressionResistancePriority(.required, for: .vertical)
        footerView.setContentCompressionResistancePriority(.required, for: .vertical)

        contentTextViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(contentTextViewTapped(_:)))
        contentTextViewTapGestureRecognizer.delegate = self

        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerViewTapped(_:))))
        bodyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyViewTapped(_:))))
        footerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(footerViewTapped(_:))))
        idLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(idLabelTapped(_:))))
        tagLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tagLabelTapped(_:))))
        contentTextView.addGestureRecognizer(contentTextViewTapGestureRecognizer)
        contentImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentImageViewTapped(_:))))
        timeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(timeLabelTapped(_:))))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if postImage != nil {
            contentImageView.kf.cancelDownloadTask()
            contentImageView.image = nil
            postImage = nil
        }

        contentTextView.text = nil
        isShowRelativeDate = defaultIsShowRelativeDate
        delegate = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PHHoleBaseTableViewCell {

    @objc func headerViewTapped(_ gesture: UIGestureRecognizer) {
        delegate?.cell(self, didPressHeaderView: headerView)
    }

    @objc func bodyViewTapped(_ gesture: UIGestureRecognizer) {
        delegate?.cell(self, didPressbodyView: bodyView)
    }

    @objc func footerViewTapped(_ gesture: UIGestureRecognizer) {
        delegate?.cell(self, didPressFooterView: footerView)
    }

    @objc func idLabelTapped(_ gesture: UIGestureRecognizer) {
        delegate?.cell(self, didPressIdLabel: idLabel)
    }

    @objc func tagLabelTapped(_ gesture: UIGestureRecognizer) {
        delegate?.cell(self, didPressTagLabel: tagLabel)
    }

    @objc func contentTextViewTapped(_ gesture: UIGestureRecognizer) {
        delegate?.cell(self, didPressContentTextView: contentTextView)
    }

    @objc func contentImageViewTapped(_ gesture: UIGestureRecognizer) {
        delegate?.cell(self, didPressContentImageView: contentImageView)
    }

    @objc func timeLabelTapped(_ gesture: UIGestureRecognizer) {
        isShowRelativeDate.toggle()
        timeLabel.text = getTimeLabelText(for: timestamp)
        delegate?.cell(self, didPressTimeLabel: timeLabel)
    }

    fileprivate func getTimeLabelText(for timestamp: TimeInterval) -> String {
        if isShowRelativeDate {
            return timestamp.secondsToRelativeDate()
        } else {
            return timestamp.formatTimestamp(to: "MM/dd/yyyy HH:mm:ss")
        }
    }
}

fileprivate extension PHHoleBaseTableViewCell {

    static let labelFont = PHGlobal.font.small
    static let blockTextColor: UIColor = .blue

    //
    // http://urlregex.com/
    //
    static let urlRule = PHClickableTextView.Rule(
        regex: try! NSRegularExpression(
            pattern: "(http|https)://(?:[a-zA-Z]|[0-9]|[$-_@.&+#]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+",
            options: [.caseInsensitive]
        ),
        attributes: [
            .foregroundColor: blockTextColor,
            .font: labelFont,
        ],
        attributesOnClick: [
            .foregroundColor: blockTextColor,
            .font: UIFont.boldSystemFont(ofSize: labelFont.pointSize),
        ]
    )

    //
    // https://github.com/pkuhelper-web/webhole/blob/master/src/text_splitter.js
    //
    static let pidRule = PHClickableTextView.Rule(
        regex: try! NSRegularExpression(
            pattern: "(^|[^\\d\\u20e3\\ufe0e\\ufe0f])([2-9]\\d{4,5}|1\\d{4,6})(?![\\d\\u20e3\\ufe0e\\ufe0f])",
            options: [.caseInsensitive]
        ),
        groupIndex: 2,
        attributes: [
            .foregroundColor: blockTextColor,
            .font: labelFont,
        ],
        attributesOnClick: [
            .foregroundColor: blockTextColor,
            .font: UIFont.boldSystemFont(ofSize: labelFont.pointSize),
        ]
    )
}

extension PHHoleBaseTableViewCell: PHClickableTextViewClickDelegate {

    func clickableTextView(_ textView: PHClickableTextView, didClickBlock block: PHClickableTextView.Block) {
        switch block.rule {
        case PHHoleBaseTableViewCell.urlRule:
            debugPrint("click url \(block.matched as Any)")
            guard var matched = block.matched else { return }
            // for webhole url: https://pkuhelper.pku.edu.cn/hole/##800000
            matched = matched.replacingOccurrences(of: "##", with: "#")
            guard let url = URL(string: matched) else { return }
            delegate?.cell(self, didPressURLInContent: url)
        case PHHoleBaseTableViewCell.pidRule:
            debugPrint("click pid \(block.matched as Any)")
            guard let matched = block.matched else { return }
            guard let pid = Int(matched) else { return }
            delegate?.cell(self, didPressPIDInContent: pid)
        default:
            break
        }
    }
}

extension PHHoleBaseTableViewCell {

    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer === contentTextViewTapGestureRecognizer {
            let point = touch.location(in: contentTextView)
            if contentTextView.block(at: point) != nil {
                return false
            } else if contentTextView.isSelected {
                return false
            }
        }
        return true // don't call super method, as it's not defined, the app will be crashed
    }
}
