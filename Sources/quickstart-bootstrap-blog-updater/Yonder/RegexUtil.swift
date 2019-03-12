//
//  RegexUtil.swift
//
//  Created by marc-medley on 2016.05.27.
//  Copyright © 2016-2019. All rights reserved.
//

import Foundation

// MARK: REGEX case switch() support

/// NS Items:
/// • `NSRegularExpression`
///
/// • `NSTextCheckingResult`: matchesInString(String, `NSMatchingOptions`, `NSRange`)
///
/// • `NSRange`: `rangeAtIndex(…)`  utf16 based range
///
/// [NSHipster: Swift Literal Convertibles](http://nshipster.com/swift-literal-convertible/)
///
/// [LesStroud: Using Regex in Switch Statements with Swift](http://www.lesstroud.com/swift-using-regex-in-switch-statements/)
public struct Regex {
    let pattern: String
    let options: NSRegularExpression.Options
    
    fileprivate var matcher: NSRegularExpression {
        return try! NSRegularExpression(pattern: self.pattern, options: self.options)
    }
    
    public init(pattern: String, options: NSRegularExpression.Options = []) {
        self.pattern = pattern
        self.options = options
    }
    
    public func match(_ inString: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        let nsRange = NSRange(location: 0, length: inString.utf16.count)
        var count: Int?
        //autoreleasepool{
        count = self.matcher.numberOfMatches(
            in: inString,
            options: options,
            range: nsRange)
        //}
        return count! != 0
    }
}

public protocol RegularExpressionMatchable {
    func match(_ regex: Regex) -> Bool
}

//
extension String: RegularExpressionMatchable {
    public func match(_ regex: Regex) -> Bool {
        return regex.match(self)
    }
}

public func ~=<T: RegularExpressionMatchable>(pattern: Regex, matchable: T) -> Bool {
    return matchable.match(pattern)
}

// MARK: - REGEX String extension

public extension String {
    public func regexMatch(pattern: String) -> Bool {
        let anyMatch = self.regexSearch(pattern: pattern)
        if anyMatch.count > 0 {
            return true
        }
        return false
    }
    
    @available(*, unavailable, renamed: "regexRemoving")
    public func regexRemove(pattern: String) -> String { return "" }
    
    public func regexRemoving(pattern: String) -> String {
        return self.regexReplacing(pattern: pattern, template: "")
    }
    
    @available(*, unavailable, renamed: "regexReplacing")
    public func regexReplace(pattern: String, template: String) -> String { return "" }
    
    public func regexReplacing(pattern: String, template: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            
            let nsRange = NSRange(location: 0, length: self.utf16.count)
            var outString: String?
            //autoreleasepool{
            outString = regex.stringByReplacingMatches(
                in: self,
                options: [],
                range: nsRange,
                withTemplate: template
            )
            //}
            return outString!
        }
        catch {
            return ""
        }
    }
    
    public func regexSearch(pattern: String) -> [String] {
        var stringGroupMatches = [String]()
        
        do {
            
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsRangeAll = NSRange(location: 0, length: self.utf16.count)
            
            // autoreleasepool {
            let matches = regex.matches( in: self, options: [], range: nsRangeAll)
            
            for match: NSTextCheckingResult in matches {
                let rangeCount = match.numberOfRanges
                // remember: $0th match is whole pattern
                for group in 0 ..< rangeCount {
                    let nsRange: NSRange = match.range(at: group)
                    let r: Range = self.range(from: nsRange)!
                    
                    // :SWIFT4: 'substring(with:)' is deprecated: Please use String slicing subscript.
                    // stringGroupMatches.append(self.substring(with: r))
                    stringGroupMatches.append( String(self[r.lowerBound ..< r.upperBound]) )
                }
            }
            // }
            return stringGroupMatches
        }
        catch {
            return []
        }
    }
    
}

// MARK: - REGEX utility functions

public class RegexUtil {
    
    /// extracts __/&ast; comment &ast;/__ from input string
    public static func regexExtractSwiftCommentBlocks(_ stringIn: String) -> (stringOut : String, stringComments: [String]) {
        do {
            var stringOut :String?
            var stringComments = [String]()
            
            let patternComment = "[\\s]+/\\*[\\s]*(.*)\\*/[\\s]*"
            let regex:NSRegularExpression  = try NSRegularExpression(
                pattern: patternComment,
                options: []
            )
            
            //autoreleasepool {
            let nsRangeAll = NSRange(location: 0, length: stringIn.utf16.count)
            
            stringOut = regex.stringByReplacingMatches(
                in: stringIn,
                options: [],
                range: nsRangeAll,
                withTemplate: ""
            )
            
            let matches = regex.matches(in: stringIn, options: [], range: nsRangeAll)
            for match: NSTextCheckingResult in matches {
                let rangeCount = match.numberOfRanges
                // skip $0th match which is whole pattern
                for group in 1 ..< rangeCount {
                    let nsRange: NSRange = match.range(at: group)
                    let r: Range = stringIn.range(from: nsRange)!
                    // :SWIFT4: 'substring(with:)' is deprecated: Please use String slicing subscript.
                    // stringComments.append(stringIn.substring(with: r))
                    stringComments.append( String(stringIn[r.lowerBound ..< r.upperBound]) )
                }
            }
            //}
            
            return (stringOut!, stringComments)
        }
        catch {
            return ("", [])
        }
    }
    
    /// extracts `// comment line` from input string
    public static func regexExtractSwiftCommentLines(_ stringIn: String) -> (stringOut : String, stringComment: String) {
        do {
            var stringOut: String?
            var stringComments = [String]()
            
            let patternComment = "[\\s]*//[\\s]*(.*)$"
            let regex:NSRegularExpression  = try NSRegularExpression(
                pattern: patternComment,
                options: []
            )
            
            //autoreleasepool {
            let nsRangeAll = NSRange(location: 0, length: stringIn.utf16.count)
            
            // get string without comment
            stringOut = regex.stringByReplacingMatches(
                in: stringIn,
                options: [],
                range: nsRangeAll,
                withTemplate: "")
            
            // get comment, if any
            let matches = regex.matches(in: stringIn, options: [], range: nsRangeAll)
            
            for match: NSTextCheckingResult in matches {
                let rangeCount = match.numberOfRanges
                // skip $0th match which is whole pattern
                for group in 1 ..< rangeCount {
                    let nsRange = match.range(at: group)
                    if let range = stringIn.range(from: nsRange) {
                        // :SWIFT4: 'substring(with:)' is deprecated: Please use String slicing subscript.
                        // stringComments.append(stringIn.substring(with: range))
                        stringComments.append(String( stringIn[range.lowerBound ..< range.upperBound] ))
                    }
                }
            }
            if (stringComments.count > 1) {
                print("ERROR: more than 1 // comment found")
            }
            //}
            
            return (stringOut!, stringComments.count > 0 ? stringComments[0] : "")
        }
        catch {
            return ("", "")
        }
    }
    
    @available(*, unavailable, renamed: "regexReplacing")
    public static func regexReplace(pattern: String, template: String, stringIn: String) -> String { return "" }
    
    public static func regexReplacing(pattern: String, template: String, stringIn: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            var stringOut: String?
            
            //autoreleasepool{
            let nsRange = NSRange(location: 0, length: stringIn.utf16.count)
            stringOut = regex.stringByReplacingMatches(
                in: stringIn,
                options: [],
                range: nsRange,
                withTemplate: template
            )
            //}
            return stringOut!
        }
        catch {
            return ""
        }
    }
    
    public static func regexSearch(pattern: String, stringIn: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        var stringGroupMatches = [String]()
        
        //autoreleasepool {
        let nsRangeAll = NSRange(location: 0, length: stringIn.utf16.count)
        
        let matches = regex.matches(in: stringIn, options: [], range: nsRangeAll)
        
        for match: NSTextCheckingResult in matches {
            let rangeCount = match.numberOfRanges
            
            // remember: $0th match is whole pattern
            for group in 0 ..< rangeCount {
                let nsRange: NSRange = match.range(at: group)
                if let range = stringIn.range(from: nsRange) {
                    // :SWIFT4: 'substring(with:)' is deprecated: Please use String slicing subscript.
                    // stringGroupMatches.append(stringIn.substring(with: range))
                    stringGroupMatches.append(String( stringIn[range.lowerBound ..< range.upperBound] ))
                }
            }
        }
        //}
        
        return stringGroupMatches
    }
    
}


