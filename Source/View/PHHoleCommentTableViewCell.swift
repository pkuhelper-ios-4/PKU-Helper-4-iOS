//
//  PHHoleCommentTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SnapKit

protocol PHHoleCommentTableViewCellDelegate: PHHoleBaseTableViewCellDelegate {

    func cell(_ cell: PHHoleCommentTableViewCell, didPressOriginPosterLabel label: UILabel)
    func cell(_ cell: PHHoleCommentTableViewCell, didPressCommentButton button: UIButton)
    func cell(_ cell: PHHoleCommentTableViewCell, didPressHideCommentButton button: UIButton)
}

extension PHHoleCommentTableViewCellDelegate {

    func cell(_ cell: PHHoleCommentTableViewCell, didPressOriginPosterLabel label: UILabel) {}
    func cell(_ cell: PHHoleCommentTableViewCell, didPressCommentButton button: UIButton) {}
    func cell(_ cell: PHHoleCommentTableViewCell, didPressHideCommentButton button: UIButton) {}
}

class PHHoleCommentTableViewCell: PHHoleBaseTableViewCell {
    
    static let identifier = "PHHoleCommentTableViewCell"

    let originPosterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = PHGlobal.font.smallBold
        label.isUserInteractionEnabled = true
        return label
    }()

    let commentButton: UIButton = createButton(image: R.image.create_new()!)

    let hideCommentButton: UIButton = createButton(image: R.image.invisible()!)

    var comment: PHHoleComment? {
        didSet {
            guard let comment = self.comment else { return }
            idLabel.text = "#\(comment.cid)"
            tagLabel.text = comment.tag
            contentTextView.text = "[\(comment.name)] \(comment.content.trimmed)"
            timestamp = TimeInterval(comment.timestamp)
            originPosterLabel.text = comment.isOriginalPoster ? "洞主" : nil

//            contentTextView.resizeToFitHeight()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        bottomRightStackView.addArrangedSubviews([hideCommentButton, commentButton])

        headerView.addSubview(originPosterLabel)

        originPosterLabel.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.centerY.equalTo(topLeftStackView)
        }

        originPosterLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(originPosterLabelTapped(_:))))
        commentButton.addTarget(self, action: #selector(commentButtonTapped(_:)), for: .touchUpInside)
        hideCommentButton.addTarget(self, action: #selector(hideCommentButtonTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func originPosterLabelTapped(_ gesture: UIGestureRecognizer) {
        guard let delegate = self.delegate as? PHHoleCommentTableViewCellDelegate else { return }
        delegate.cell(self, didPressOriginPosterLabel: originPosterLabel)
    }

    @objc func commentButtonTapped(_ button: UIButton) {
        guard let delegate = self.delegate as? PHHoleCommentTableViewCellDelegate else { return }
        delegate.cell(self, didPressCommentButton: button)
    }

    @objc func hideCommentButtonTapped(_ button: UIButton) {
        guard let delegate = self.delegate as? PHHoleCommentTableViewCellDelegate else { return }
        delegate.cell(self, didPressHideCommentButton: button)
    }
}
