//
//  PHHoleHiddenTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHHoleHiddenTableViewCellDelegate: AnyObject {

    func cell(_ cell: PHHoleHiddenTableViewCell, didPressBodyView bodyView: UIView)
    func cell(_ cell: PHHoleHiddenTableViewCell, didPressDisplayButton button: UIButton)
}

extension PHHoleHiddenTableViewCellDelegate {

    func cell(_ cell: PHHoleHiddenTableViewCell, didPressBodyView bodyView: UIView) {}
    func cell(_ cell: PHHoleHiddenTableViewCell, didPressDisplayButton button: UIButton) {}
}

class PHHoleHiddenTableViewCell: UITableViewCell {

    weak var delegate: PHHoleHiddenTableViewCellDelegate?

    static let identifier = "PHHoleHiddenTableViewCell"

    let bodyView: UIView = {
        let view = UIView()
        return view
    }()

    let cellSpacingView: UIView = {
        let view = UIView()
        view.backgroundColor = .groupTableViewBackground
        return view
    }()

    let hiddenIconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = R.image.invisible()?.scaled(toWidth: PHHoleBaseTableViewCell.iconSideLength)
        view.isUserInteractionEnabled = true
        return view
    }()

    let idLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regularBold
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
        label.isUserInteractionEnabled = true
        return label
    }()

    let displayButton: UIButton = {
        let button = UIButton()
        button.titleForNormal = "display"
        button.titleColorForNormal = .gray
        button.titleLabel?.font = PHGlobal.font.small
        return button
    }()

    var model: Model? {
        didSet {
            guard let model = self.model else { return }
            idLabel.text = "\(model.type.rawValue.uppercased()) #\(model.id) is hidden"
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubviews([bodyView, cellSpacingView])
        bodyView.addSubviews([hiddenIconImageView, idLabel, displayButton])

        let sideSpacing = PHHoleBaseTableViewCell.sideSpacing
        let lineSpacing = PHHoleBaseTableViewCell.lineSpacing
        let itemSpacing = PHHoleBaseTableViewCell.spacingBetweenIconAndLabel * 2

        bodyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.equalToSuperview().inset(lineSpacing)
        }

        cellSpacingView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(bodyView.snp.bottom).offset(lineSpacing)
            make.height.equalTo(lineSpacing)
        }

        hiddenIconImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }

        idLabel.snp.makeConstraints { make in
            make.left.equalTo(hiddenIconImageView.snp.right).offset(itemSpacing)
            make.top.bottom.equalToSuperview()
        }

        displayButton.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.left.greaterThanOrEqualTo(idLabel.snp.right).offset(itemSpacing)
        }

        bodyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyViewTapped(_:))))
        displayButton.addTarget(self, action: #selector(displayButtonTapped(_:)), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func displayButtonTapped(_ button: UIButton) {
        delegate?.cell(self, didPressDisplayButton: button)
    }

    @objc func bodyViewTapped(_ gesture: UIGestureRecognizer) {
        delegate?.cell(self, didPressBodyView: bodyView)
    }
}

extension PHHoleHiddenTableViewCell {

    enum ItemType: String {
        case post, comment
    }

    struct Model {

        let id: Int
        let type: ItemType

        var pid: Int? {
            guard type == .post else { return nil }
            return id
        }

        var cid: Int? {
            guard type == .comment else { return nil }
            return id
        }

        init?(fromPost post: PHHolePost?) {
            guard let post = post else { return nil }
            id = post.pid
            type = .post
        }

        init?(fromComment comment: PHHoleComment?) {
            guard let comment = comment else { return nil }
            id = comment.cid
            type = .comment
        }
    }
}
