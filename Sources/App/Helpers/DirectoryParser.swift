//
//  File.swift
//  
//
//  Created by Anderson David on 8/17/21.
//

import Foundation
import Purdue_App_API_Models
import Kanna

class DirectoryParser {
    struct Response: Codable {
        var status: String
        var message: String
        var results: [DirectoryResult]
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Response.CodingKeys.self)
            
            try container.encode(self.status, forKey: .status)
            if results.count > 0 {
                try container.encode(self.results, forKey: .message)
            }
            else {
                try container.encode(self.message, forKey: .message)
            }
        }
    }
    
    class func parseResults(html: String) -> Response {
        var response: Response = Response(status: "", message: "", results: [])
        var directoryResults: [DirectoryResult] = []
        guard let document = try? HTML(html: html, encoding: .utf8), let results = document.at_css("section[id=\"results\"]") else {
            return response
        }
        
        if let tooManyEntries = results.toHTML?.contains("too many entries"), tooManyEntries {
            response.status = "fail"
            response.message = "too many"
            response.results = directoryResults
            return response
        }
        else if let noMatches = results.toHTML?.contains("nothing matches"), noMatches {
            response.status = "fail"
            response.message = "none"
            response.results = directoryResults
            return response
        }
        
        for result in results.css("li") {
            var toAdd = DirectoryResult()
            
            /* Get name */
            if let name = result.at_css("h2")?.text {
                toAdd.name = name
            }
            
            for (index, table) in result.css("table").enumerated() {
                var tableQuery = "tbody tr"
                if index == 1 {
                    tableQuery = "tr"
                }
                /* Get attributes */
                for attribute in table.css(tableQuery) {
                    if let attrName = attribute.at_css("th")?.text, let attrVal = attribute.at_css("td")?.text {
                        
                        switch attrName {
                            case "Alias":
                                toAdd.alias = attrVal
                                break
                            case "Campus":
                                toAdd.campus = attrVal
                            case "Email":
                                toAdd.email = attrVal
                            case "Qualified Name":
                                toAdd.qualifiedName = attrVal
                            case "School":
                                toAdd.school = attrVal
                            default:
                                break
                        }
                    }
                }
            }
            
            directoryResults.append(toAdd)
        }
        
        response.status = "success"
        response.message = ""
        response.results = directoryResults
        return response
    }
}
