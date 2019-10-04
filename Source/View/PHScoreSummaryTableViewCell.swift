//
//  PHScoreSummaryTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHScoreSummaryTableViewCell: PHScoreTableViewCell {

    override class var identifier: String { return "PHScoreSummaryTableViewCell" }
    
    override var score: PHCourseScore? {
        didSet {
            guard let score = self.score else { return }
            courseNameLabel.text = score.course
            scoreLabel.text = score.gpa?.format("%.3f") ?? PHScoreTableViewCell.nullField
            roundImageView.image = getColoredRoundImage(gpa: score.gpa)
        }
    }
}
