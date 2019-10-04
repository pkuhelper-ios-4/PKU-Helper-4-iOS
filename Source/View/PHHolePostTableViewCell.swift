//
//  PHHolePostTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SnapKit
import SwiftDate

protocol PHHolePostTableViewCellDelegate: PHHoleBaseTableViewCellDelegate {

    func cell(_ cell: PHHolePostTableViewCell, didPressReportedButton button: UIButton)
    func cell(_ cell: PHHolePostTableViewCell, didPressHidePostButton button: UIButton)
    func cell(_ cell: PHHolePostTableViewCell, diePressStarButton button: UIButton)
    func cell(_ cell: PHHolePostTableViewCell, didPressCommentButton button: UIButton)
}

extension PHHolePostTableViewCellDelegate {

    func cell(_ cell: PHHolePostTableViewCell, didPressReportedButton button: UIButton) {}
    func cell(_ cell: PHHolePostTableViewCell, didPressHidePostButton button: UIButton) {}
    func cell(_ cell: PHHolePostTableViewCell, diePressStarButton button: UIButton) {}
    func cell(_ cell: PHHolePostTableViewCell, didPressCommentButton button: UIButton) {}
}

class PHHolePostTableViewCell: PHHoleBaseTableViewCell {
    
    static let identifier = "PHHolePostTableViewCell"

    let commentButton: UIButton = createButton(image: R.image.sms()!, title: String(0))

    let starButton: UIButton = createButton(image: R.image.star()!, title: String(0))

    let hidePostButton: UIButton = createButton(image: R.image.invisible()!)

    let reportedButton: UIButton = createButton(image: R.image.attention()!, title: "REPORTED") { button in
        button.tintColor = .red
        button.titleColorForNormal = .red
    }

    var post: PHHolePost? {
        didSet {
            guard let post = self.post else { return }
            idLabel.text = "#\(post.pid)"
            tagLabel.text = post.tag
            timestamp = TimeInterval(post.timestamp)
            starButton.titleForNormal = String(post.starCount)
            commentButton.titleForNormal = String(post.comments?.count ?? post.commentCount)

            if post.type == .audio {
                contentTextView.text = "(Audio post is deprecated)\n\(post.content.trimmed)"
            } else {
                contentTextView.text = post.content.trimmed.empty2Nil()
            }
//            contentTextView.resizeToFitHeight()

            starButton.tintColor = (post.starred) ? .blue : .black
            reportedButton.isHidden = !post.reported

            postImage = post.image
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        headerView.addSubview(reportedButton)
        bottomRightStackView.addArrangedSubviews([hidePostButton, starButton, commentButton])

        reportedButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        reportedButton.addTarget(self, action: #selector(reportedButtonTapped(_:)), for: .touchUpInside)
        hidePostButton.addTarget(self, action: #selector(hidePostButtonTapped(_:)), for: .touchUpInside)
        starButton.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentButtonTapped(_:)), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func reportedButtonTapped(_ button: UIButton) {
        guard let delegate = self.delegate as? PHHolePostTableViewCellDelegate else { return }
        delegate.cell(self, didPressReportedButton: button)
    }

    @objc func hidePostButtonTapped(_ button: UIButton) {
        guard let delegate = self.delegate as? PHHolePostTableViewCellDelegate else { return }
        delegate.cell(self, didPressHidePostButton: button)
    }

    @objc func starButtonTapped(_ button: UIButton) {
        guard let delegate = self.delegate as? PHHolePostTableViewCellDelegate else { return }
        delegate.cell(self, diePressStarButton: button)
    }

    @objc func commentButtonTapped(_ button: UIButton) {
        guard let delegate = self.delegate as? PHHolePostTableViewCellDelegate else { return }
        delegate.cell(self, didPressCommentButton: button)
    }
}
