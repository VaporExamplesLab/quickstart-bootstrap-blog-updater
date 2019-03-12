//
//  MarkdownUpdater.swift
//  blog_content_updater
//
//  Created by marc-medley on 2019.03.11.
//  Copyright © 2019 marc-medley. All rights reserved.
//

import Foundation

class MarkdownUpdater {
    
    let fromMdUrl: URL
    let toMdLeafUrl: URL
    let toMdPublicUrl: URL

    struct ItemAsset: Codable {
        var url: URL
        var modifiedDate:Date
    }
    
    struct ItemMarkdown: Codable {
        var url: URL
        var modifiedDate: Date
        var lookupId: String // yyyyMMdd + word initials
    }

    
    init(originalContent: URL, processedContent: URL) {
        fromMdUrl = originalContent.appendingPathComponent("markdown", isDirectory: true)
        toMdLeafUrl = processedContent
            .appendingPathComponent("leaf", isDirectory: true)
            .appendingPathComponent("m", isDirectory: true)
        toMdPublicUrl = processedContent
            .appendingPathComponent("public", isDirectory: true)
            .appendingPathComponent("m", isDirectory: true)
    }
    
    func updateMarkdownLeafContent() throws {
        // setup from nodes
        let fromNodes = try fm.subpathsOfDirectory(atPath: fromMdUrl.path)
        var fromMdNodes: [String] = []
        for node in fromNodes {
            if node.hasSuffix(".md") {
                fromMdNodes.append(node)
            }
        }
        fromMdNodes.sort()
        mclog.verbose("### fromMdNodes=")
        for s in fromMdNodes { mclog.verbose(s) }
        
        // setup to nodes
        let toNodes = try fm.subpathsOfDirectory(atPath: toMdLeafUrl.path)
        var toLeafNodes: [String] = []
        for node in toNodes {
            if node.hasSuffix(".leaf") {
                toLeafNodes.append(node)
            }
        }
        toLeafNodes.sort()
        mclog.verbose("### toLeafNodes=")
        for s in toLeafNodes { mclog.verbose(s) }
        
        mclog.verbose("### **COMPARE**")
        var idxFromMd = 0, idxToLeaf = 0
        let maxFromMd = fromMdNodes.count
        let maxToLeaf = toLeafNodes.count
        while idxFromMd < maxFromMd && idxToLeaf < maxToLeaf {
            let currentFromMdNode = fromMdNodes[idxFromMd]
            let currentToLeafNode = toLeafNodes[idxToLeaf]
            let compareResult: ComparisonResult = currentFromMdNode.compare(currentToLeafNode)
            mclog.verbose("\(currentFromMdNode) vs \(currentToLeafNode)")
            if compareResult == .orderedSame {
                // :TODO: compare dates (file modified)
                mclog.verbose("SKIP:\(currentFromMdNode) and \(currentToLeafNode)")
                idxFromMd = idxFromMd + 1
                idxToLeaf = idxToLeaf + 1
            }
            else if compareResult == .orderedAscending {
                addMarkdownLeaf(subpath: fromMdNodes[idxFromMd])
                idxFromMd = idxFromMd + 1
            }
            else if compareResult == .orderedDescending {
                dropMarkdownLeaf(subpath: toLeafNodes[idxToLeaf])
                idxToLeaf = idxToLeaf + 1
            }
        }
        while idxFromMd < maxFromMd {
            addMarkdownLeaf(subpath: fromMdNodes[idxFromMd])
            idxFromMd = idxFromMd + 1
        }
        while idxToLeaf < maxToLeaf {
            dropMarkdownLeaf(subpath: toLeafNodes[idxToLeaf])
            idxToLeaf = idxToLeaf + 1
        }
        
        // Generate BaseRecent.leaf Menu
        let recentCount = fromMdNodes.count < menuRecentMax ? fromMdNodes.count : menuRecentMax
        var baseRecentLeafStr = ""
        baseRecentLeafStr.append(contentsOf: "<h6 class=\"dropdown-header\"><em>New</em></h6>\n")
        for i in fromMdNodes.count-recentCount ..< fromMdNodes.count {
            let node = fromMdNodes[i]
            
            // :TODO: get title from content else form file name
            // :TODO: get date from content else from file attribute
            
            let leaf = node.dropLast(3) // drop .md
            let nodeParts = node.components(separatedBy: "/")
            let label = nodeParts[0] + "-" + nodeParts[1] + " " + nodeParts[2].dropLast(3)
            let s = "<a class=\"dropdown-item\" href=\"/post/\(leaf)\">\(label)</a>\n"
            baseRecentLeafStr.append(contentsOf: s)
        }
        baseRecentLeafStr.append(contentsOf: "<h6 class=\"dropdown-header\"><em>Updated</em></h6>\n")
        baseRecentLeafStr.append(contentsOf: "<div class=\"dropdown-divider\"></div>\n")
        baseRecentLeafStr.append(contentsOf: "<a class=\"dropdown-item\" href=\"/archives\">Archives</a>\n")
        print(baseRecentLeafStr)
        
    }
    
    func addMarkdownLeaf(subpath: String) {
        let fromUrl = fromMdUrl.appendingPathComponent(subpath, isDirectory: false)
        let toUrl = toMdLeafUrl
            .appendingPathComponent(subpath, isDirectory: false)
            .deletingPathExtension()
            .appendingPathExtension("leaf")
        mclog.verbose("… ADD:\(subpath) --> *.leaf (remainder)")
        var html = mdHtmlViaPandoc(mdUrlIn: fromUrl)
        
        html = LeafUtils.escapingLeafSyntax(html)

        // find title <h1>First Post</h1>
        let pagetitle = "Blog Page"
        let leafStr = """
        #set("title") {\(pagetitle)}
        
        #set("body") {
        <div class="blogpage">
        \(html)
        </div>
        }
        
        #embed("Base")
        """
        
        do {
            let attributes: [FileAttributeKey : Any] = [:]
            try fm.createDirectory(at: toUrl.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: attributes)
            try leafStr.write(to: toUrl, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            mclog.error("mdHtmlViaPandoc failed to write out mdUrlOut:\(toUrl)")
        }
    }
    
    func addMarkdownAssets() {
        
    }
    
    func dropEmptyFolder() {
        
    }

    func dropMarkdownLeaf(subpath: String) {
        mclog.verbose("… DROP:\(subpath) --X (remainder)")
        
        // move old file to trash
        /*
         do {
         var resultingURL: NSURL?
         try FileManager.default.trashItem(at: mdUrlIn, resultingItemURL: &resultingURL)
         mclog.verbose("trashed: \(resultingURL! as URL)")
         // saveForUndo resultingURL as! URL
         } catch {
         mclog.error("failed move to trash: \(mdUrlIn.path)")
         }
         */
        
        // :TODO: delete directory if empty
        
    }
    
    //
    func showUrlResourceValues(fromUrl: URL) {
        let urlResourceKeys: [URLResourceKey] = [
            URLResourceKey.addedToDirectoryDateKey, // not supported by all volumes
            URLResourceKey.attributeModificationDateKey, // nil if unsupported
            URLResourceKey.contentModificationDateKey, // nil if unsupported
            URLResourceKey.creationDateKey, // nil is not supported
            URLResourceKey.isDirectoryKey, //
            URLResourceKey.isRegularFileKey,
            URLResourceKey.nameKey,
            URLResourceKey.parentDirectoryURLKey,
            URLResourceKey.pathKey
        ]
        
        do {
            
            let contents = try fm.contentsOfDirectory(at: fromUrl,
                                                      includingPropertiesForKeys: urlResourceKeys,
                                                      options: [.skipsHiddenFiles, .skipsPackageDescendants])
            
            for c in contents {
                try mclog.verbose("\(c.resourceValues(forKeys: [.creationDateKey, .isDirectoryKey]))")
            }
            
            mclog.verbose( "contents=\n\(contents)" )
            
        } catch /* pattern */ {
            mclog.verbose("fail: showUrlResourceValues")
        }
    }

}

