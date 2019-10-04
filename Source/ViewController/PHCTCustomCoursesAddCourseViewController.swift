//
//  PHCTCustomCoursesAddCourseViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/20.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHCTCustomCoursesAddCourseViewController: PHCTCustomCoursesEditingBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Course"

        originalCourse = (course.copy() as! PHCourse)
    }
}
