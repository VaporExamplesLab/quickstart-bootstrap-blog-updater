//
//  StringExtensions.swift
//
//  Created by marc-medley on 2016.11.17.
//  Copyright © 2016-2019. All rights reserved.
//

import Foundation


////////////////
// MARK: - Linux
////////////////
#if os(Linux)

extension String.SubSequence { // aka 'Substring'
    
    /// [SR-5627 Provide Substring.hasSuffix/hasPrefix on Linux](https://bugs.swift.org/browse/SR-5627)
    public func hasPrefix(_ prefix: String) -> Bool {
        let s = String(self)
        return s.hasPrefix(prefix)
    }
    
    public func hasSuffix(_ suffix: String) -> Bool {
        let s = String(self)
        return s.hasSuffix(suffix)
    }
    
    /// 'Substring.SubSequence' (aka 'Substring') has no member 'trimmingCharacters' or 'hasSuffix'
    /// https://bugs.swift.org/browse/SR-6395
    
    // :NYI: trimmingCharacters
}

#endif

// MARK: -

extension String {
    @available(*, unavailable, renamed: "dropFirst")
    public func chopPrefix(count: Int = 1) -> String { return "" }
    
    @available(*, deprecated, renamed: "dropFirst")
    public func droppingFirst(_ n: Int = 1) -> String {
        let s = self.dropFirst(n)
        return String(s)
    }
    
    @available(*, unavailable, renamed: "dropLast")
    public func chopSuffix(count: Int = 1) -> String { return "" }
    
    @available(*, deprecated, renamed: "dropLast")
    public func droppingLast(count: Int = 1) -> String {
        let s = self.dropLast(count)
        return String(s)
    }
    
    // TODO: - UNIT TESTING: Continue adding test from this point forward.
    
    // :TODO:VERIFY: Swift 4 String
    public func getSuffix(count: Int = 1, ignoreTrailingWhiteSpace: Bool = true) -> String {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fromIndex: String.Index = trimmed.endIndex(retreatingBy: count)
        
        if fromIndex >= trimmed.startIndex {
            // Swift 3: trimmed.substring(with: fromIndex ..< trimmed.endIndex)
            let s: Substring = trimmed[fromIndex ..< trimmed.endIndex]
            return String(s)
        }
        else {
            // Swift 3: trimmed.substring(with: trimmed.startIndex ..< trimmed.endIndex)
            let s: Substring = trimmed[trimmed.startIndex ..< trimmed.endIndex]
            return String(s)
        }
    }
    
    /// Swift 2.2 `.startIndex.indexAdvancedBy(_)`
    public func startIndex(advancingBy n: Int) -> String.Index {
        let index: String.Index = self.index(self.startIndex, offsetBy: n)
        return index
    }
    
    public func endIndex(retreatingBy n: Int) ->  String.Index {
        let index: String.Index = self.index(self.endIndex, offsetBy: -n)
        return index
    }
    
    public func prefixToCharSet(_ s: String) -> String {
        let charSet = CharacterSet(charactersIn: s)
        let parts = self.components(separatedBy: charSet)
        if let s = parts.first {
            return s
        }
        return self
    }
    
    public func prefixToUnescaped(_ stopChar: Character) -> String {
        var outStr = ""
        
        var countEscape = 0
        
        for index in self.indices {
            let c: Character = self[index]
            
            switch c {
            case stopChar:
                if countEscape % 2 == 0 {
                    return outStr
                }
                outStr.append(c)
                countEscape = 0
            case "\\":
                outStr.append(c)
                countEscape = countEscape + 1
            default:
                outStr.append(c)
                countEscape = 0
            }
        }
        
        return outStr
    }
    
    /// :NYI: enumerate bracket types
    public func prefixToClosing(_ closeBracketChar: Character) -> String {
        var outStr = ""
        
        // open bracket character
        var openBracketChar: Character = "("
        switch closeBracketChar {
        case "}":
            openBracketChar = "{"
        case "]":
            openBracketChar = "["
        case ">":
            openBracketChar = "<"
        default:
            break
        }
        
        var countEscape = 0
        var countOpen = 0
        var countClose = 0
        
        for index in self.indices {
            let c: Character = self[index]
            
            switch c {
            case openBracketChar:
                outStr.append(c)
                countEscape = 0
                countOpen = countOpen + 1
            case closeBracketChar:
                if countEscape % 2 == 0 &&
                    !(countOpen > countClose) {
                    return outStr
                }
                outStr.append(c)
                countEscape = 0
                countClose = countClose + 1
            case "\\":
                outStr.append(c)
                countEscape = countEscape + 1
            default:
                outStr.append(c)
                countEscape = 0
            }
        }
        
        return outStr
    }
    
    public func prefixToWhitespace() -> String {
        return prefixToCharSet("\t \r\n")
    }
    
}

// http://stackoverflow.com/questions/25138339/nsrange-to-rangestring-index
// http://stackoverflow.com/questions/27040924/nsrange-from-swift-range
// http://stackoverflow.com/questions/30093688/how-to-create-range-in-swift
// http://stackoverflow.com/questions/32936411/using-rangeindex-with-nsrange-in-the-nsattributedstring-api

extension String {
    
    //    // :TODO:VERIFY: Swift 4 String. Is `nsRange` still needed?
    //    public func nsRange(from range: Range<String.Index>) -> NSRange {
    //        let from = range.lowerBound.samePosition(in: utf16)
    //        let to = range.upperBound.samePosition(in: utf16)
    //        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
    //                       length: utf16.distance(from: from, to: to))
    //    }
    
    public func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16Index = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16Index = utf16.index(from16Index, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let fromIndex = String.Index(from16Index, within: self),
            let toIndex = String.Index(to16Index, within: self)
            else { return nil }
        return fromIndex ..< toIndex
    }
}

//
//extension NSRange {
//    func range(for str: String) -> Range<String.Index>? {
//        guard location != NSNotFound else { return nil }
//
//        guard let from16Index = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
//        guard let to16Index = str.utf16.index(from16Index, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
//        guard let fromIndex = String.Index(from16Index, within: str) else { return nil }
//        guard let toIndex = String.Index(to16Index, within: str) else { return nil }
//
//        return fromIndex ..< toIndex
//    }
//}

extension String {
    public func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

extension String {
    
    public func capitalizingCamelStyle(firstSegmentLowercase: Bool = false) -> String {
        let charSet: CharacterSet = CharacterSet(charactersIn: " -/:,.!")
        return capitalizingCamelStyle(separatorChars: charSet, firstSegmentLowercase: firstSegmentLowercase)
    }
    
    public func capitalizingCamelStyle(separatorChars: CharacterSet,
                                       firstSegmentLowercase: Bool = false
        ) -> String {
        assert(separatorChars.isEmpty == false)
        
        let parts = self.components(separatedBy: separatorChars)
        
        var stringOut = ""
        
        var i = 0
        while i < parts.count {
            let w = parts[i]
            if w.isEmpty {
                // skip any empty parts
            }
            else if i == 0 && firstSegmentLowercase {
                stringOut += w.lowercased()
            } else {
                stringOut += w.setFirstCharToUppercase()
            }
            i += 1
        }
        
        return stringOut
    }
    
    public func setFirstCharToLowercase() -> String {
        // The start index is the first character
        let first: Index = self.startIndex
        
        //
        // The rest of the string goes from the position after the first letter
        // to the end.
        let rest = self.index(self.startIndex, offsetBy: 1) ..< self.endIndex
        
        // Glue these two ranges together, with the first uppercased, and you'll
        // get the result you want. Note that I'm using description[first...first]
        // to get the first letter because I want a String, not a Character, which
        // is what you'd get with description[first].
        let capitalised = self[first...first].lowercased() + self[rest]
        
        return capitalised
    }
    
    public func setFirstCharToUppercase() -> String {
        // The start index is the first character
        let first: Index = self.startIndex
        
        //
        // The rest of the string goes from the position after the first letter
        // to the end.
        let rest = self.index(self.startIndex, offsetBy: 1) ..< self.endIndex
        
        // Glue these two ranges together, with the first uppercased, and you'll
        // get the result you want. Note that I'm using description[first...first]
        // to get the first letter because I want a String, not a Character, which
        // is what you'd get with description[first].
        let capitalised = self[first...first].uppercased() + self[rest]
        
        return capitalised
    }
    
}

extension String {
    /// change based on UnicodeScalar.
    ///
    /// **Unicode Scalar** : unique 21-bit number (and name) for a character or modifier.  UTF-8 and UTF-16 are encoding formats for Unicode Scalars.
    ///
    /// Example:
    ///
    /// * `U+0061` LOWERCASE LATIN LETTER A("a")
    /// * `U+1F425` FRONT-FACING BABY CHICK ("\U0001f425").
    public func lowercasedFirstWord() -> String {
        let unicodeScalars = Array(self.unicodeScalars)
        let lowercase = CharacterSet.lowercaseLetters
        let digits = CharacterSet.decimalDigits
        var outputStr = ""
        
        var i = 0
        var inFirstWord = true
        while i < unicodeScalars.count {
            let currentLetter = unicodeScalars[i]
            let currentStr = currentLetter.escaped(asASCII: false)
            
            if i == 0 {
                if i < count - 1 {
                    // look ahead
                    let nextLetter = unicodeScalars[i + 1]
                    if lowercase.contains(nextLetter) || digits.contains(nextLetter) {
                        inFirstWord = false
                    }
                }
                outputStr.append(currentStr.lowercased())
            } else if inFirstWord {
                if i < count - 1 {
                    // look ahead
                    let nextLetter = unicodeScalars[i + 1]
                    if lowercase.contains(nextLetter) || digits.contains(nextLetter) {
                        inFirstWord = false
                        outputStr.append(currentStr)
                    } else {
                        outputStr.append(currentStr.lowercased())
                    }
                } else {
                    outputStr.append(currentStr.lowercased())
                }
            } else {
                outputStr.append(currentStr)
            }
            
            i = i + 1
        }
        
        return outputStr
    }
    
    public func separateLetterCase() -> (lowercase: String, uppercase: String, nocase: String) {
        let unicodeScalars: String.UnicodeScalarView = self.unicodeScalars
        let lowerCase = CharacterSet.lowercaseLetters
        let upperCase = CharacterSet.uppercaseLetters
        
        var lowercaseOutStr = ""
        var uppercaseOutStr = ""
        var nocaseOutStr = ""
        
        for currentCharacter in unicodeScalars {
            if lowerCase.contains(currentCharacter) {
                lowercaseOutStr.append(currentCharacter.escaped(asASCII: false))
            } else if upperCase.contains(currentCharacter) {
                uppercaseOutStr.append(currentCharacter.escaped(asASCII: false))
            } else {
                nocaseOutStr.append(currentCharacter.escaped(asASCII: false))
            }
        }
        return (lowercaseOutStr, uppercaseOutStr, nocaseOutStr)
    }
    
    /// Convert Unicode to escaped ASCII such as "\t" and "\u{BC25}"
    public func escapedAsASCII() -> String {
        let unicodeScalars: String.UnicodeScalarView = self.unicodeScalars
        var outputString = ""
        for scalar in unicodeScalars {
            outputString.append(scalar.escaped(asASCII: true))
        }
        return outputString
    }
    
    public func isASCII() -> Bool {
        var isAllAscii = true
        for currentCharacter in self.unicodeScalars {
            if currentCharacter.isASCII == false {
                isAllAscii = false
            }
        }
        return isAllAscii
    }
    
}

extension String {
    
    /// escapes double quote `"`. encloses in double quotes
    public func jsonQuotedEscaped() -> String {
        return "\"" + self.replacingOccurrences(of: "\"", with: "\\\"") + "\""
    }
    
    ///  escapes single quote `'` with `''`. encloses in single quotes
    public func sqlQuotedEscaped() -> String {
        let escaped = self.replacingOccurrences(of: "'", with: "''")
        return "'" + escaped + "'"
    }
    
    /// removingEscapeEncoding
    ///
    /// escaped special characters \0 (null character), \\ (backslash), \t (horizontal tab), \n (line feed), \r (carriage return), \" (double quote) and \' (single quote)
    ///
    public func removingEscapeEncoding() -> String {
        var outStr = ""
        var escaped: Bool = false
        
        for index in self.indices {
            let c: Character = self[index]
            
            switch c {
            case "t", "r", "n", "'", "\"":
                if escaped {
                    outStr.append("\\\(c)")
                }
                else {
                    outStr.append(c)
                }
                escaped = false
            case "\\":
                if escaped {
                    outStr.append(c)
                    escaped = false
                }
                else {
                    escaped = true
                }
                
            default:
                outStr.append(c)
                escaped = false
            }
        }
        
        return outStr
    }
    
    /// removingUnicodeHexadecimalEncoding
    ///
    /// arbitrary "U+hexadecimal" Unicode scalar, written as \u{n}, where n is a 1–8 digit hexadecimal number, not UTF-8
    ///
    /// :NYI:
    ///
    
    /// removingPercentEncoding already exists
    
    /// Returns a new `String` made by replacing all HTML/XML
    /// each character entity `&…;` with the corresponding
    /// character.
    public var removingEntityEncoding : String {
        
        // ===== Utility functions =====
        
        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(_ string : Substring, base : Int) -> Character? {
            guard let code = UInt32(string, radix: base),
                let uniScalar = UnicodeScalar(code) else { return nil }
            return Character(uniScalar)
        }
        
        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(_ entity : Substring) -> Character? {
            
            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X") {
                return decodeNumeric(entity.dropFirst(3).dropLast(), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(entity.dropFirst(2).dropLast(), base: 10)
            } else {
                return StringUtil.characterEntities[entity]
            }
        }
        
        // ===== Method starts here =====
        
        var result = ""
        var position = startIndex
        
        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self[position...].range(of: "&") {
            result.append(contentsOf: self[position ..< ampRange.lowerBound])
            position = ampRange.lowerBound
            
            // Find the next ';' and copy everything from '&' to ';' into `entity`
            guard let semiRange = self[position...].range(of: ";") else {
                // No matching ';'.
                break
            }
            let entity = self[position ..< semiRange.upperBound]
            position = semiRange.upperBound
            
            if let decoded = decode(entity) {
                // Replace by decoded character:
                result.append(decoded)
            } else {
                // Invalid entity, copy verbatim:
                result.append(contentsOf: entity)
            }
        }
        // Copy remaining characters to `result`:
        result.append(contentsOf: self[position...])
        return result
    }
}

extension String {
    
    //    let keyword = "a"
    //    let html = "aaaa"
    //    let indicies = html.indicesOf(string: keyword)
    //    print(indicies) // [0, 1, 2, 3]
    
    /// find all occurrences of a substring
    public func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}

// see https://developer.apple.com/reference/foundation/nscharacterset
// see https://developer.apple.com/reference/swift/string/1690785-addingpercentencoding
// urlUserAllowed urlPasswordAllowed urlHostAllowed urlPathAllowed urlQueryAllowed urlFragmentAllowed

//extension CharacterSet {
//    static let urlAllowed: CharacterSet = {
//        return CharacterSet.urlFragmentAllowed
//            .union(.urlHostAllowed)
//            .union(.urlPasswordAllowed)
//            .union(.urlQueryAllowed)
//            .union(.urlUserAllowed)
//    }()
//}

