//
//  String+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/6.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation
import UIKit

public extension String {

    func empty2Nil() -> String? {
        return isEmpty ? nil : self
    }

    ///
    /// https://stackoverflow.com/questions/1324379/how-to-calculate-the-width-of-a-text-string-of-a-specific-font-and-font-size/39904016
    ///
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}


public extension String {

    //
    // https://www.jianshu.com/p/c5c9ce074615
    //
    func transformToPinyin(hasBlank: Bool = true) -> String {
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef, nil, kCFStringTransformToLatin, false)
        CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false)
        let pinyin = stringRef as String
        return hasBlank ? pinyin : pinyin.replacingOccurrences(of: " ", with: "")
    }

    func transformToPinyinInitials() -> String {
        return String(self.transformToPinyin(hasBlank: true)
            .split(separator: " ")
            .compactMap{ $0.count > 0 ? $0.first : nil })
    }
}


public extension String {

    //
    // https://stackoverflow.com/questions/42789953/swift-3-how-do-i-extract-captured-groups-in-regular-expressions
    //
    func extractGroups(
            for regex: NSRegularExpression,
            options: NSRegularExpression.MatchingOptions = [])
            -> [String]?
    {
        let range = NSRange(self.startIndex..., in: self)
        guard let result = regex.firstMatch(in: self, options: options, range: range) else { return nil }
        return result.groups(in: self)
    }
}


// MARK: - Properties
public extension String {

    /// SwifterSwift: String with no spaces or new lines in beginning and end.
    ///
    ///        "   hello  \n".trimmed -> "hello"
    ///
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// SwifterSwift: URL from string (if applicable).
    ///
    ///        "https://google.com".url -> URL(string: "https://google.com")
    ///        "not url".url -> nil
    ///
    var url: URL? {
        return URL(string: self)
    }

    /// SwifterSwift: String decoded from base64 (if applicable).
    ///
    ///        "SGVsbG8gV29ybGQh".base64Decoded = Optional("Hello World!")
    ///
    var base64Decoded: String? {
        // https://github.com/Reza-Rg/Base64-Swift-Extension/blob/master/Base64.swift
        guard let decodedData = Data(base64Encoded: self) else { return nil }
        return String(data: decodedData, encoding: .utf8)
    }

    /// SwifterSwift: String encoded in base64 (if applicable).
    ///
    ///        "Hello World!".base64Encoded -> Optional("SGVsbG8gV29ybGQh")
    ///
    var base64Encoded: String? {
        // https://github.com/Reza-Rg/Base64-Swift-Extension/blob/master/Base64.swift
        let plainData = data(using: .utf8)
        return plainData?.base64EncodedString()
    }

    /// SwifterSwift: Check if string contains only letters.
    ///
    ///        "abc".isAlphabetic -> true
    ///        "123abc".isAlphabetic -> false
    ///
    var isAlphabetic: Bool {
        let hasLetters = rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
        let hasNumbers = rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
        return hasLetters && !hasNumbers
    }

    /// SwifterSwift: Check if string contains at least one letter and one number.
    ///
    ///        // useful for passwords
    ///        "123abc".isAlphaNumeric -> true
    ///        "abc".isAlphaNumeric -> false
    ///
    var isAlphaNumeric: Bool {
        let hasLetters = rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
        let hasNumbers = rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
        let comps = components(separatedBy: .alphanumerics)
        return comps.joined(separator: "").count == 0 && hasLetters && hasNumbers
    }

    /// SwifterSwift: Check if string is a valid Swift number.
    ///
    /// Note:
    /// In North America, "." is the decimal separator,
    /// while in many parts of Europe "," is used,
    ///
    ///     "123".isNumeric -> true
    ///     "1.3".isNumeric -> true (en_US)
    ///     "1,3".isNumeric -> true (fr_FR)
    ///     "abc".isNumeric -> false
    ///
    var isNumeric: Bool {
        let scanner = Scanner(string: self)
        scanner.locale = NSLocale.current
        #if os(Linux)
        return scanner.scanDecimal() != nil && scanner.isAtEnd
        #else
        return scanner.scanDecimal(nil) && scanner.isAtEnd
        #endif
    }

    /// SwifterSwift: Check if string only contains digits.
    ///
    ///     "123".isDigits -> true
    ///     "1.3".isDigits -> false
    ///     "abc".isDigits -> false
    ///
    var isDigits: Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
    }

    /// SwifterSwift: Check if the given string contains only white spaces
    var isWhitespace: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// SwifterSwift: Bool value from string (if applicable).
    ///
    ///        "1".bool -> true
    ///        "False".bool -> false
    ///        "Hello".bool = nil
    ///
    var bool: Bool? {
        let selfLowercased = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch selfLowercased {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }

    /// SwifterSwift: Integer value from string (if applicable).
    ///
    ///        "101".int -> 101
    ///
    var int: Int? {
        return Int(self)
    }
}

// MARK: - Methods
public extension String {

    /// Float value from string (if applicable).
    ///
    /// - Parameter locale: Locale (default is Locale.current)
    /// - Returns: Optional Float value from given string.
    func float(locale: Locale = .current) -> Float? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self)?.floatValue
    }

    /// Double value from string (if applicable).
    ///
    /// - Parameter locale: Locale (default is Locale.current)
    /// - Returns: Optional Double value from given string.
    func double(locale: Locale = .current) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self)?.doubleValue
    }

    /// CGFloat value from string (if applicable).
    ///
    /// - Parameter locale: Locale (default is Locale.current)
    /// - Returns: Optional CGFloat value from given string.
    func cgFloat(locale: Locale = .current) -> CGFloat? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self) as? CGFloat
    }

    /// SwifterSwift: Returns a localized string, with an optional comment for translators.
    ///
    ///        "Hello world".localized -> Hallo Welt
    ///
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }

    /// SwifterSwift: Removes given prefix from the string.
    ///
    ///   "Hello, World!".removingPrefix("Hello, ") -> "World!"
    ///
    /// - Parameter prefix: Prefix to remove from the string.
    /// - Returns: The string after prefix removing.
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    /// SwifterSwift: Removes given suffix from the string.
    ///
    ///   "Hello, World!".removingSuffix(", World!") -> "Hello"
    ///
    /// - Parameter suffix: Suffix to remove from the string.
    /// - Returns: The string after suffix removing.
    func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }

    /// SwifterSwift: Removes spaces and new lines in beginning and end of string.
    ///
    ///        var str = "  \n Hello World \n\n\n"
    ///        str.trim()
    ///        print(str) // prints "Hello World"
    ///
    @discardableResult
    mutating func trim() -> String {
        self = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return self
    }

    /// SwifterSwift: Pad string to fit the length parameter size with another string in the start.
    ///
    ///   "hue".padStart(10) -> "       hue"
    ///   "hue".padStart(10, with: "br") -> "brbrbrbhue"
    ///
    /// - Parameter length: The target length to pad.
    /// - Parameter string: Pad string. Default is " ".
    @discardableResult
    mutating func padStart(_ length: Int, with string: String = " ") -> String {
        self = paddingStart(length, with: string)
        return self
    }

    /// SwifterSwift: Returns a string by padding to fit the length parameter size with another string in the start.
    ///
    ///   "hue".paddingStart(10) -> "       hue"
    ///   "hue".paddingStart(10, with: "br") -> "brbrbrbhue"
    ///
    /// - Parameter length: The target length to pad.
    /// - Parameter string: Pad string. Default is " ".
    /// - Returns: The string with the padding on the start.
    func paddingStart(_ length: Int, with string: String = " ") -> String {
        guard count < length else { return self }

        let padLength = length - count
        if padLength < string.count {
            return string[string.startIndex..<string.index(string.startIndex, offsetBy: padLength)] + self
        } else {
            var padding = string
            while padding.count < padLength {
                padding.append(string)
            }
            return padding[padding.startIndex..<padding.index(padding.startIndex, offsetBy: padLength)] + self
        }
    }

    /// SwifterSwift: Pad string to fit the length parameter size with another string in the start.
    ///
    ///   "hue".padEnd(10) -> "hue       "
    ///   "hue".padEnd(10, with: "br") -> "huebrbrbrb"
    ///
    /// - Parameter length: The target length to pad.
    /// - Parameter string: Pad string. Default is " ".
    @discardableResult
    mutating func padEnd(_ length: Int, with string: String = " ") -> String {
        self = paddingEnd(length, with: string)
        return self
    }

    /// SwifterSwift: Returns a string by padding to fit the length parameter size with another string in the end.
    ///
    ///   "hue".paddingEnd(10) -> "hue       "
    ///   "hue".paddingEnd(10, with: "br") -> "huebrbrbrb"
    ///
    /// - Parameter length: The target length to pad.
    /// - Parameter string: Pad string. Default is " ".
    /// - Returns: The string with the padding on the end.
    func paddingEnd(_ length: Int, with string: String = " ") -> String {
        guard count < length else { return self }

        let padLength = length - count
        if padLength < string.count {
            return self + string[string.startIndex..<string.index(string.startIndex, offsetBy: padLength)]
        } else {
            var padding = string
            while padding.count < padLength {
                padding.append(string)
            }
            return self + padding[padding.startIndex..<padding.index(padding.startIndex, offsetBy: padLength)]
        }
    }
}
