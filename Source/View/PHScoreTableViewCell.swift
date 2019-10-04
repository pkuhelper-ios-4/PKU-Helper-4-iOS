//
//  PHScoreTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHScoreTableViewCell: UITableViewCell {
    
    /// The static variable in class can't be 'override' by subclass ...
    class var identifier: String { return "PHScoreTableViewCell" }

    static let diameterOfRound: CGFloat = PHGlobal.font.huge.pointSize
    static let nullField: String = "-"

    let roundImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    let courseNameLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regular
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regular
        label.textColor = .gray
        return label
    }()

    var score: PHCourseScore? {
        didSet {
            guard let score = self.score, !score.isSummary else { return }
            courseNameLabel.text = score.course
            scoreLabel.text = score.score
            roundImageView.image = getColoredRoundImage(gpa: score.gpa)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .none
        backgroundColor = .white

        contentView.addSubviews([roundImageView, courseNameLabel, scoreLabel])

        let sideSpacing = PHScoreMainViewController.sideSpacing
        let labelSpacing = PHScoreMainViewController.labelSpacing
        let diameter = PHScoreTableViewCell.diameterOfRound

        roundImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(sideSpacing)
            make.width.height.equalTo(diameter)
        }

        courseNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(roundImageView.snp.right).offset(labelSpacing)
        }

        scoreLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(sideSpacing)
            make.left.greaterThanOrEqualTo(courseNameLabel.snp.right).offset(labelSpacing)
        }

        courseNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        courseNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    func getColoredRoundImage(gpa: Double?) -> UIImage? {
        let color = gpa2Color(gpa)
        let diameter = PHScoreTableViewCell.diameterOfRound
        return UIImage(color: color, size: CGSize(width: diameter, height: diameter)).rounded()
    }
    
    func gpa2Color(_ gpa: Double?) -> UIColor {
        guard let gpa = gpa, gpa >= 1.0, gpa <= 4.0 else { return .black }

        let score = 100.0 - ((4.0 - gpa) * 1600 / 3).squareRoot()
        let percent = (CGFloat(score) - 60.0) / 40.0

        var r, g, b: CGFloat
        if percent < 0 { // impossible
            r = 0.0
            g = 0.0
            b = 0.0
        } else if percent < 0.5 {
            r = 1.0
            g = percent / 0.5
            b = 0.1
        } else {
            r = (1.0 - percent) / 0.5
            g = 1.0
            b = 0.1
        }

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.removeGestureRecognizers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
