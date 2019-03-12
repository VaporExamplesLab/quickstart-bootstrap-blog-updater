//
//  MdHtmlViaPandoc.swift
//  blog_content_updater
//
//  Created by marc-medley on 2019.03.10.
//  Copyright © 2019 marc-medley. All rights reserved.
//

import Foundation

func mdHtmlViaPandoc(mdUrlIn: URL) -> String {
    let workPath = mdUrlIn.absoluteURL.deletingLastPathComponent().path
    mclog.debug("workPath = \(workPath)")
    
    // ### Start with Markdown strict baseline, then add all preferred settings
    // ### OPTIONS="--from=markdown_strict"
    var options = "--from=markdown_strict"
    //options.append(contentsOf: "-blank_before_header")
    // ### INLINE
    // ### Note: `+intraword_underscores` disables intra_word underscore
    //options.append(contentsOf: "+intraword_underscores")
    options.append(contentsOf: "+strikeout")
    // ### TABLES
    //options.append(contentsOf: "+table_captions")
    //options.append(contentsOf: "+simple_tables")
    //options.append(contentsOf: "+multiline_tables")
    //options.append(contentsOf: "+grid_tables")
    options.append(contentsOf: "+pipe_tables")
    // ### CODE BLOCKS
    options.append(contentsOf: "+fenced_code_blocks")
    options.append(contentsOf: "+backtick_code_blocks")
    // ### FOOTNOTES
    options.append(contentsOf: "+footnotes")
    //options.append(contentsOf: "-inline_notes")
    // ### MATH
    options.append(contentsOf: "+tex_math_dollars")
    options.append(contentsOf: "+tex_math_double_backslash")

    var args: [String] = []
    args = args + [options]
    args = args + ["--no-highlight"] // do not use pandoc highlighting
    args = args + ["--to=html5"]
    args = args + ["--mathjax"]
    //args = args + ["--output=\(leafUrlOut.path)"]
    args = args + [mdUrlIn.path]
    
    let result = McProcess.run(
        commandPath: pandocPath,
        withArguments: args,
        workDirectory: workPath
    )
    //print("stdout:\n\(result.stdout)")
    //print("stderr:\n\(result.stderr)")
    
    return result.stdout
}
