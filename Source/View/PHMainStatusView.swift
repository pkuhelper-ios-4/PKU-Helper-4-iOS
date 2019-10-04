//
//  PHMainStatusView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHMainStatusViewDelegate: AnyObject {

    func statusView(_ statusView: PHMainStatusView, didPressCell cell: PHMainStatusCellView)
}

extension PHMainStatusViewDelegate {

    func statusView(_ statusView: PHMainStatusView, didPressCell cell: PHMainStatusCellView) {}
}

class PHMainStatusView: UIView {

    weak var delegate: PHMainStatusViewDelegate?

    static let maxNumberOfCells: Int = 4
    static let cellInset = PHGlobal.sideSpacing * 0.5

    let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .fill
        view.spacing = cellInset
        return view
    }()

    typealias Model = [PHMainStatusCellView.CellModel]

    var models: Model! {
        didSet {
            contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for model in models {
                let cell = PHMainStatusCellView()
                cell.model = model
                cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellDidPress(_:))))
                contentStackView.addArrangedSubview(cell)
            }
            // MARK: create dummy cell
            for _ in 0..<(PHMainStatusView.maxNumberOfCells - models.count) {
                let cell = PHMainStatusCellView()
                contentStackView.addArrangedSubview(cell)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(contentStackView)

        let cellInset = PHMainStatusView.cellInset

        contentStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(cellInset)
            make.top.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func cellDidPress(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? PHMainStatusCellView else { return }
        delegate?.statusView(self, didPressCell: cell)
    }
}
