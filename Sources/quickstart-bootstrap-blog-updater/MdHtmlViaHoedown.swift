//
//  MdHtmlViaHoedown.swift
//  blog_content_updater
//
//  Created by marc-medley on 2019.03.11.
//  Copyright © 2019 marc-medley. All rights reserved.
//

import Foundation

func mdHtmlViaHoedown(mdUrlIn: URL) -> String {
    let workPath = mdUrlIn.absoluteURL.deletingLastPathComponent().path
    mclog.debug("workPath = \(workPath)")
    
    var args: [String] = []
    args = args + ["--strikethrough"]
    args = args + ["--tables"]
    args = args + ["--fenced-code"]
    args = args + ["--footnotes"]
    args = args + ["--math"]
    args = args + ["--math-explicit"]
    args = args + ["--"]
    args = args + [mdUrlIn.path]
    
    let result = McProcess.run(
        commandPath: hoedownPath,
        withArguments: args,
        workDirectory: workPath
    )
    //print("stdout:\n\(result.stdout)")
    //print("stderr:\n\(result.stderr)")
    
    return result.stdout
}

/**************************************
 
###############
### HOEDOWN ###
###############
# Main options:
#  --max-nesting=N  Maximum level of block nesting parsed. Default is 16.
#  --toc-level=N    Maximum level for headers included in the TOC. Zero disables TOC (the default).
#  --html           Render (X)HTML. The default.
#  --html-toc       Render the Table of Contents in (X)HTML.
#  --time           Show time spent in rendering.
#  --input-unit=N   Reading block size. Default is 1024.
#  --output-unit=N  Writing block size. Default is 64.
#  --help           Print this help text.
#  --version        Print Hoedown version.
#
# Block extensions (--all-block):
#  --tables         Parse PHP-Markdown style tables.
#  --fenced-code    Parse fenced code blocks.
#  --footnotes      Parse footnotes.
#
# Span extensions (--all-span):
#  --autolink       Automatically turn safe URLs into links.
#  --strikethrough  Parse ~~stikethrough~~ spans.
#  --underline      Parse _underline_ instead of emphasis.
#  --highlight      Parse ==highlight== spans.
#  --quote          Render `"quotes"` as `<q>quotes</q>`. different from <quoteblock>
#  --superscript    Parse super^script.
#  --math           Parse TeX $$math$$ syntax, Kramdown style.
#
# Other flags (--all-flags):
#  --disable-intra-emphasis  Disable emphasis_between_words. Both `_` and `*`
#  --space-headers  Require a space after '#' in headers.
#  --math-explicit  Instead of guessing by context, parse $inline math$ and $$always block math$$ (requires --math).
#
# Negative flags (--all-negative):
#  --disable-indented-code  Don't parse indented code blocks.
#
# HTML-specific options:
#  --skip-html      Strip all HTML tags.
#  --escape         Escape all HTML.
#  --hard-wrap      Render each linebreak as <br>.
#  --xhtml          Render XHTML.

####
BODY_FILE="test.hoedown.b"
hoedown \
  --strikethrough \
  --tables \
  --fenced-code \
  --footnotes \
  --math --math-explicit \
  -- \
  $INPUT_FILE \
  > $BODY_FILE.txt
cat $HEADER_FILE $BODY_FILE.txt $FOOTER_FILE > $BODY_FILE.html
 
 **************************************/
