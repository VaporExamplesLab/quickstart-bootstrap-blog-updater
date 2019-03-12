//
//  MdHtmlViaMultimarkdown.swift
//  blog_content_updater
//
//  Created by marc-medley on 2019.03.11.
//  Copyright © 2019 marc-medley. All rights reserved.
//

import Foundation

func mdHtmlViaMultimarkdown(mdUrlIn: URL) -> String {
    let workPath = mdUrlIn.absoluteURL.deletingLastPathComponent().path
    mclog.debug("workPath = \(workPath)")
    
    var args: [String] = []
    args = args + ["--nosmart"]
    args = args + ["--nolabels"]
    args = args + [mdUrlIn.path]
    
    let result = McProcess.run(
        commandPath: multimarkdownPath,
        withArguments: args,
        workDirectory: workPath
    )
    //print("stdout:\n\(result.stdout)")
    //print("stderr:\n\(result.stderr)")
    
    return result.stdout
}

/*******************************************************
 
 #################################
### MULTIMARKDOWN: `markdown` ###
#################################
### NOTE: Discount `markdown` and MultiMarkdown `markdown` have the same command name.
### Thus, Discount `markdown` and MultiMarkdown `markdown` mutually exclusive brew installs.
# multimarkdown  [OPTION...] [<FILE>...]
#
# 	<FILE>               read input from file(s) -- use stdin if no files given
#
# Options:
# --help                 Show help
# --version              Show version information
#
# -o, --output=FILE      Send output to FILE
# -t, --to=FORMAT        Convert to FORMAT
#     FORMATs: html(default)|latex|beamer|memoir|mmd|odt|fodt|epub|opml|bundle|bundlezip
#
# -b, --batch            Process each file separately
# -c, --compatibility    Markdown compatibility mode.
# -f, --full             Force a complete document
# -s, --snippet          Force a snippet
#
# -m, --metadata-keys    List all metadata keys
# -e, --extract          Extract specified metadata
#
# --random               Use random numbers for footnote anchors
#
# -a, --accept           Accept all CriticMarkup changes
# -r, --reject           Reject all CriticMarkup changes
#
# --nosmart              Disable smart typography
# --nolabels             Disable id attributes for headers
# --notransclude         Disable file transclusion
# --opml                 Convert OPML source to plain text before processing
#
# -l, --lang=LANG        language/smart quote localization, LANG = en|es|de|fr|he|nl|sv

 ### all preferred settings
BODY_FILE="test.multimarkdown.a"
multimarkdown \
  --nosmart \
  --nolabels \
  $INPUT_FILE \
  > $BODY_FILE.txt
cat $HEADER_FILE $BODY_FILE.txt $FOOTER_FILE > $BODY_FILE.html

 *******************************************************/
