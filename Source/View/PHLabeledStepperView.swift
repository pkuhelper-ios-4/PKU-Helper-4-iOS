//
//  PHLabeledStepperView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHLabeledStepperView: UIView {

    var stepper: UIStepper? {
        didSet {
            oldValue?.removeFromSuperview()
            oldValue?.removeTarget(self, action: #selector(handleStepper(_:)), for: .valueChanged)
            guard let stepper = self.stepper else { return }
            contentStackView.addArrangedSubview(stepper)
            stepper.addTarget(self, action: #selector(handleStepper(_:)), for: .valueChanged)
            handleStepper(stepper) // init
        }
    }

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.textAlignment = .right
        label.font = PHGlobal.font.regular
        return label
    }()

    let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        view.spacing = PHGlobal.font.regular.pointSize
        return view
    }()

    var titleFormat: String = "%g" {
        didSet {
            guard let stepper = stepper else { return }
            handleStepper(stepper)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentStackView.addArrangedSubview(titleLabel)

        addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.setContentCompressionResistancePriority(.required, for: .horizontal) // no compression
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func handleStepper(_ stepper: UIStepper) {
        titleLabel.text = String(format: titleFormat, stepper.value)
    }
}
