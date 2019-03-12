//
//  McLogger.swift
//
//  Created by marc-medley on 2017.01.10.
//  Copyright © 2017-2019 marc-medley. All rights reserved.
//
//

import Foundation

///
/// - Note: Be sure to set the "DEBUG" symbol in the compiler flags for the development build.
///
/// `Build Settings` > `All, Levels` > `Swift Compiler` - `Custom Flags/Other Swift Flags` >
/// `(+) -D DEBUG`
public enum McLoggerLevel: Int, Comparable {
    case all        = 6 // highest verbosity
    case verbose    = 5
    case debug      = 4
    case info       = 3
    case warning    = 2
    case error      = 1
    case off        = 0
    
    /// Get string description for log level.
    ///
    /// - parameter logLevel: A LogLevel
    ///
    /// - returns: A string.
    public static func description(logLevel: McLoggerLevel) -> String {
        switch logLevel {
        case .all:     return "all"
        case .verbose: return "verbose"
        case .debug:   return "debug"
        case .info:    return "info"
        case .warning: return "warning"
        case .error:   return "error"
        case .off:     return "off"
            //default: assertionFailure("Invalid level")
            //return "Null"
        }
    }
    
    // Set the "DEBUG" symbol in the compiler flags
    #if DEBUG
    static public let defaultLevel = McLoggerLevel.all
    #else
    static public let defaultLevel = McLoggerLevel.warning
    #endif
}

public func < (lhs: McLoggerLevel, rhs: McLoggerLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public func == (lhs: McLoggerLevel, rhs: McLoggerLevel) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public class McLogger {
    /// Current log level.
    public var logLevel = McLoggerLevel.defaultLevel
    
    /// Log line counter
    private var lineCount = 0
    /// Log line numbers to watch: [Int]
    public var watchpointList: [Int] = [18830, 26855]
    ///
    private var logfileUrl: URL?
    
    /// DateFromatter used internally.
    private let dateFormatter = DateFormatter()
    
    public init() {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") //24H
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss.SSS"
        
        /// LogFunction used, `print` for DEBUG, file for Production.
        #if DEBUG
        
        #else
        // :NYI: production would use the default file
        #endif
    }
    
    // public func message
    public func verbose(_ s: String) {
        if (.verbose <= logLevel) {
            log(s)
        }
    }
    
    public func debug(_ s: String) {
        if (.debug <= logLevel) {
            log(s)
        }
    }
    
    public func info(_ s: String) {
        if (.info <= logLevel) {
            log(s)
        }
    }
    
    public func warning(_ s: String) {
        if (.warning <= logLevel) {
            log(s)
        }
    }
    
    public func error(_ s: String) {
        if (.error <= logLevel) {
            log(s)
        }
    }
    
    private func log(_ string: String) {
        lineCount = lineCount + 1
        let logString = "[[\(lineCount)]] \(string)"
        #if DEBUG
        if watchpointList.contains(lineCount) {
            print(":::WATCHPOINT::: [[\(lineCount)]]")
        }
        #endif
        if let url = logfileUrl {
            do {
                let fileHandle = try FileHandle(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                fileHandle.write( (logString + "\n").data(using: .utf8)!)
                fileHandle.closeFile()
            } catch {
                #if DEBUG
                print("FAIL: could not append to \(url.absoluteString)")
                print(logString)
                #endif
            }
            
            // :WIP:OBSOLETE: ... remove sometime
            //do {
            //    // try logString.appendLineToURL(fileURL: url)
            //} catch {
            //    #if DEBUG
            //        print("FAIL: could not append to \(url.absoluteString)")
            //        print(logString)
            //    #endif
            //}
        }
        else {
            print(logString)
        }
    }
    
    ///// - note: requires a file system friendly `CFBundleName`
    //public func useLogFileDefault() {
    //    var token = "TOKEN"
    //    //Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
    //    let o = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
    //    if let cfBundleName = o {
    //        token = cfBundleName as? String ?? ""
    //    }
    //    
    //    useLogFile(
    //        nameToken: token,
    //        relativePathComponents: ["Library", "Logs", "McLogger"]
    //    )
    //}
    
    ///// - parameter nameToken: string included in file name
    ///// - parameter relativePathComponents: path relative to user home directory
    //public func useLogFile(nameToken: String, relativePathComponents: [String]) {
    //    let fm = FileManager.default
    //
    //    var logDirUrl: URL = fm.homeDirectoryForCurrentUser
    //    for component in relativePathComponents {
    //        logDirUrl = logDirUrl.appendingPathComponent(component, isDirectory: true)
    //    }
    //
    //    useLogFile(nameToken: nameToken, absolutePath: logDirUrl.path)
    //}
    
    public func useLogFile(nameToken: String, absolutePath: String) {
        let fm = FileManager.default
        let logDirUrl = URL(fileURLWithPath: absolutePath, isDirectory: true)
        
        //
        //print("logDir.path \(logDir.path)")
        // returns: /Users/username/opt/apps/MCxYonderCode
        //print("logDir.absoluteString \(logDir.absoluteString)")
        // returns: file:///Users/username/opt/apps/MCxYonderCode/
        
        guard logDirUrl.path.isEmpty == false else {
            return
        }
        
        if fm.fileExists(atPath: logDirUrl.path) == false {
            do {
                try fm.createDirectory(at: logDirUrl, withIntermediateDirectories: true)
            } catch  {
                return
            }
        }
        
        let currentTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        //formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let dateTimestamp = formatter.string(from: currentTime)
        
        let logfileName = "log-\(nameToken)-\(dateTimestamp).txt"
        logfileUrl = logDirUrl.appendingPathComponent(logfileName, isDirectory: false)
    }
    
}
