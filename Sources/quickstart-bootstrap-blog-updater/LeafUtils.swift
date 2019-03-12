//
//  LeafUtils.swift
//  blog_content_updater
//
//  Created by marc-medley on 2019.03.11.
//  Copyright © 2019 marc-medley. All rights reserved.
//

import Foundation

class LeafUtils {
    
    static func escapingLeafSyntax(_ str: String) -> String {
        var s = str
        // escape closing bracket }
        s = s.replacingOccurrences(of: "}", with: "\\}")
        // leaf comment tokens
        s = s.replacingOccurrences(of: "#//", with: "&num;//")
        s = s.replacingOccurrences(of: "#/*", with: "&num;/*")
        // leaf tokens
        s = s.replacingOccurrences(of: "#(", with: "&num;(")
        s = s.replacingOccurrences(of: "#count(", with: "&num;count(")
        s = s.replacingOccurrences(of: "#for(", with: "&num;for(")
        s = s.replacingOccurrences(of: "#if(", with: "&num;if(")
        s = s.replacingOccurrences(of: "#set(", with: "&num;set(")
        s = s.replacingOccurrences(of: "#embed(", with: "&num;embed(")
        
        s = s.replacingOccurrences(of: "#date(", with: "&num;date(")
        s = s.replacingOccurrences(of: "#capitalize(", with: "&num;capitalize(")
        s = s.replacingOccurrences(of: "#contains(", with: "&num;contains(")
        s = s.replacingOccurrences(of: "#lowercase(", with: "&num;lowercase(")
        s = s.replacingOccurrences(of: "#uppercase(", with: "&num;uppercase(")
        return s
    }
    
}
