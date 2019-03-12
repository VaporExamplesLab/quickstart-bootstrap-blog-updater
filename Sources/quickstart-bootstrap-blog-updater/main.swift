//
//  main.swift
//
//  Created by marc-medley on 2017.01.10.
//  Copyright © 2019. All rights reserved.
//

import Foundation

let helpStr = """
--help                     prints this help section

--original-dir=<DIR_PATH>  directory of <filename.md> markdown files.
referenced assets are expected to be in <filename_files/>.
unreferenced files are ignored.
--processed-dir=<DIR_PATH> directory for generated <filename.leaf> resorces
and associated public <filename_files/*> content.

--verbose                  prints extra processing informaton.
"""

/////////////////////
/// Configuration ///
/////////////////////
let menuRecentMax = 8 // maximun number of items to show on Recent menu
// `brew install hoedown`
let hoedownPath = "/usr/local/bin/pandoc"
// `brew install multimarkdown`
let multimarkdownPath = "/usr/local/bin/pandoc"
// `brew install pandoc`
let pandocPath = "/usr/local/bin/pandoc"

///
var contentOriginalUrlOptional: URL?
var contentProcessedUrlOptional: URL?
let fm = FileManager.default
var logFlag: Bool = false
let mclog = McLogger()
mclog.logLevel = McLoggerLevel.warning

if CommandLine.arguments.contains("--help") {
    print(helpStr)
    exit(0)
}
if CommandLine.arguments.contains("--verbose") {
    mclog.logLevel = McLoggerLevel.all
}
mclog.verbose("### Command Line Arguments:")
for arg in CommandLine.arguments {
    if arg.hasPrefix("--original-dir=") {
        contentOriginalUrlOptional = URL(fileURLWithPath: String(arg.dropFirst(15)))
        mclog.verbose("contentOriginalUrl=\(contentOriginalUrlOptional!.path)")
    }
    else if arg.hasPrefix("--processed-dir=") {
        contentProcessedUrlOptional = URL(fileURLWithPath: String(arg.dropFirst(16)))
        mclog.verbose("contentProcessedUrl=\(contentProcessedUrlOptional!.path)")
    }
}

guard let contentOriginalUrl = contentOriginalUrlOptional,
    let contentProcessedUrl = contentProcessedUrlOptional
    else {
        print("ERROR: required arguments --original-dir=<DIR_PATH> and --processed-dir=<DIR_PATH>\n")
        print(helpStr)
        exit(-1)
}

/////////////
/// Paths ///
/////////////
let fromMdUrl = contentOriginalUrl.appendingPathComponent("markdown", isDirectory: true)
let toMdLeafUrl = contentProcessedUrl
    .appendingPathComponent("leaf", isDirectory: true)
    .appendingPathComponent("m", isDirectory: true)
let toMdPublicUrl = contentProcessedUrl
    .appendingPathComponent("public", isDirectory: true)
    .appendingPathComponent("m", isDirectory: true)


do {
    let mdUpdater = MarkdownUpdater(originalContent: contentOriginalUrl, processedContent: contentProcessedUrl)
    try mdUpdater.updateMarkdownLeafContent()
}
catch {
    
}

// updateHtmlContent()
// updatePaprikaContent()
