//
//  UITableView+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

public extension UITableView {
    
    /// SwifterSwift: Index of last section in tableView.
    var lastSection: Int? {
        return numberOfSections > 0 ? numberOfSections - 1 : nil
    }

    /// SwifterSwift: Safely scroll to possibly invalid IndexPath
    ///
    /// - Parameters:
    ///   - indexPath: Target IndexPath to scroll to
    ///   - scrollPosition: Scroll position
    ///   - animated: Whether to animate or not
    func safeScrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        guard indexPath.section < numberOfSections else { return }
        guard indexPath.row < numberOfRows(inSection: indexPath.section) else { return }
        scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }

}


extension UITableView {

    func reloadCell(_ cell: UITableViewCell, animated: Bool, with animation: UITableView.RowAnimation = .automatic) {
        guard let indexPath = self.indexPath(for: cell) else { return }
//        let location = contentOffset
        beginUpdates()
        defer {
            endUpdates()
//            setContentOffset(location, animated: animated) // reset reading position
        }
        if animated {
            reloadRows(at: [indexPath], with: animation)
        } else {
            UIView.performWithoutAnimation {
                reloadRows(at: [indexPath], with: animation)
            }
        }
    }

    func deselectAllRows(exclude indexPath: IndexPath) {
        visibleCells.forEach { cell in
            guard let _indexPath = self.indexPath(for: cell) else { return }
            if _indexPath != indexPath && cell.isSelected {
                deselectRow(at: _indexPath, animated: true)
            }
        }
    }
}
