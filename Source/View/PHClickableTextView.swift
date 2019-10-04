//
//  PHClickableTextView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/10/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
//
//  References:
//  --------------
//  1. https://github.com/instacart/Nantes
//  2. https://github.com/TTTAttributedLabel/TTTAttributedLabel
//

import UIKit

public protocol PHClickableTextViewClickDelegate: AnyObject {

    func clickableTextView(_ textView: PHClickableTextView, didClickBlock block: PHClickableTextView.Block)
}

public extension PHClickableTextViewClickDelegate {

    func clickableTextView(_ textView: PHClickableTextView, didClickBlock block: PHClickableTextView.Block) {}
}

public class PHClickableTextView: UITextView {

    public class Rule: Equatable {

        static let nullGroupIndex = -1

        let regex: NSRegularExpression
        let matchingOptions: NSRegularExpression.MatchingOptions
        let groupIndex: Int

        let attributes: [NSAttributedString.Key: Any]
        let attributesOnClick: [NSAttributedString.Key: Any]

        init(regex: NSRegularExpression,
             matchingOptions: NSRegularExpression.MatchingOptions = [],
             groupIndex: Int = nullGroupIndex,
             attributes: [NSAttributedString.Key: Any] = [:],
             attributesOnClick: [NSAttributedString.Key: Any] = [:])
        {
            self.regex = regex
            self.matchingOptions = matchingOptions
            self.groupIndex = groupIndex
            self.attributes = attributes
            self.attributesOnClick = attributesOnClick
        }

        public static func == (lhs: PHClickableTextView.Rule, rhs: PHClickableTextView.Rule) -> Bool {
            return lhs.regex == rhs.regex
                && lhs.matchingOptions == rhs.matchingOptions
                && lhs.groupIndex == rhs.groupIndex
                && (lhs.attributes as NSDictionary).isEqual(to: rhs.attributes)
                && (lhs.attributesOnClick as NSDictionary).isEqual(to: rhs.attributesOnClick)
        }
    }

    public class Block: Equatable {

        let rule: Rule
        let result: NSTextCheckingResult
        let text: String

        var range: NSRange {
            if rule.groupIndex == Rule.nullGroupIndex {
                return result.range
            } else {
                return result.range(at: rule.groupIndex)
            }
        }

        var matched: String? {
            guard let range = Range(range, in: text) else { return nil }
            return String(text[range])
        }

        init(rule: Rule, result: NSTextCheckingResult, text: String) {
            self.rule = rule
            self.result = result
            self.text = text
        }

        public static func == (lhs: PHClickableTextView.Block, rhs: PHClickableTextView.Block) -> Bool {
            return lhs.rule == rhs.rule
                && lhs.range == rhs.range
                && lhs.text == rhs.text
        }
    }


    public weak var clickDelegate: PHClickableTextViewClickDelegate?

    public var rules: [Rule] = []

    private var clickableBlocks: [Block] = []

    private var activedBlock: Block? {
        didSet {
            didSetActivedBlock(activedBlock, oldValue: oldValue)
        }
    }

    private var _attributedText: NSAttributedString?
    private var isAttributedTextSetDisabled: Bool = false

    override open var attributedText: NSAttributedString? {
        get {
            return _attributedText
        }
        set {
            guard !isAttributedTextSetDisabled else { return }
            guard newValue != _attributedText else { return }
            guard newValue != nil else {
                _attributedText = nil
                clickableBlocks.removeAll()

                //
                // https://stackoverflow.com/questions/41326719/reset-attributes-of-attributedtext-in-textview-when-clearing-it-swift
                //
                typingAttributes = self.attributes
                return
            }

            _attributedText = newValue

            setupClickableBlocks()

            super.attributedText = attributedText
            setNeedsDisplay()
        }
    }

    override open var text: String? {
        get {
            return attributedText?.string
        }
        set {
            guard newValue != text else { return }
            guard let text = newValue else {
                attributedText = nil
                withDisabledAttributedTextSet {
                    super.text = ""
                }
                return
            }
            attributedText = NSAttributedString(string: text, attributes: attributes)
            withDisabledAttributedTextSet {
                super.text = attributedText?.string
            }
            debugPrint(typingAttributes)
            debugPrint(attributedText as Any)
        }
    }

    private var attributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if let font = self.font {
            attributes[.font] = font
        }
        if let textColor = self.textColor {
            attributes[.foregroundColor] = textColor
        }
        return attributes
    }

    private func setupClickableBlocks() {
        guard let text = attributedText?.string else { return }
        guard let updatedAttributedString = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }

        var blocks: [Block] = []

        for rule in rules {
            for result in rule.regex.matches(in: text, options: rule.matchingOptions, range: NSMakeRange(0, text.count)) {
                let block = Block(rule: rule, result: result, text: text)
                blocks.append(block)
            }
        }

        for block in blocks {
            updatedAttributedString.addAttributes(block.rule.attributes, range: block.range)
        }

        clickableBlocks = blocks
        _attributedText = updatedAttributedString
    }

    private func withDisabledAttributedTextSet(_ closure: () -> Void) {
        isAttributedTextSetDisabled = true
        closure()
        isAttributedTextSetDisabled = false
    }

    private func isBlockInAttributedString(_ block: Block, _ string: NSMutableAttributedString) -> Bool {
        let range = block.range
        return range.length > 0 && NSLocationInRange(NSMaxRange(range) - 1, NSRange(location: 0, length: string.length))
    }

    private func didSetActivedBlock(_ newValue: Block?, oldValue: Block?) {
        guard newValue != oldValue else { return }
        guard let updatedAttributedString = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }

        if let activedBlock = newValue {
            guard isBlockInAttributedString(activedBlock, updatedAttributedString) else { return }
            let newRange = activedBlock.range
            updatedAttributedString.addAttributes(activedBlock.rule.attributesOnClick, range: newRange)

        } else if let oldBlock = oldValue {
            guard isBlockInAttributedString(oldBlock, updatedAttributedString) else { return }
            let oldRange = oldBlock.range
            oldBlock.rule.attributesOnClick.keys.forEach { key in
                updatedAttributedString.removeAttribute(key, range: oldRange)
            }
            updatedAttributedString.addAttributes(oldBlock.rule.attributes, range: oldRange)

        } else {
            return
        }

        _attributedText = updatedAttributedString
        super.attributedText = _attributedText
        setNeedsDisplay()
        CATransaction.flush()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        isEditable = false

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: touch actions

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard block(at: point) != nil && isUserInteractionEnabled && !isHidden && alpha > 0.0 else {
            return super.hitTest(point, with: event)
        }
        return self
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let touch = touches.first,
            let block = block(at: touch.location(in: self)) else {
                super.touchesBegan(touches, with: event)
                return
        }
        activedBlock = block
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard activedBlock != nil else {
            super.touchesCancelled(touches, with: event)
            return
        }
        activedBlock = nil
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let block = activedBlock else {
            super.touchesEnded(touches, with: event)
            return
        }
        handleBlockTapped(block)
    }

    //
    // https://stackoverflow.com/questions/19332283/detecting-taps-on-attributed-text-in-a-uitextview-in-ios
    //
    func block(at point: CGPoint) -> Block? {
        guard !clickableBlocks.isEmpty else { return nil }
        guard let attributedText = attributedText else { return nil }

        let characterIndex = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        guard NSLocationInRange(characterIndex, NSRange(location: 0, length: attributedText.length)) else { return nil }

        for block in clickableBlocks {
            if NSLocationInRange(characterIndex, block.range) {
                return block
            }
        }

        return nil
    }

    private func handleBlockTapped(_ block: Block) {
        activedBlock = nil
        clickDelegate?.clickableTextView(self, didClickBlock: block)
    }
}
