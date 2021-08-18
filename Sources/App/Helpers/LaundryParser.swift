//
//  File.swift
//  
//
//  Created by Anderson David on 8/18/21.
//

import Foundation
import Purdue_App_API_Models
import Kanna

class LaundryParser {
    class func parseResults(html: String) -> LaundryResponse {
        var response: LaundryResponse = LaundryResponse(status: "", rooms: [])
        var laundryRooms: [LaundryRoom] = []
        guard let document = try? HTML(html: html, encoding: .utf8), let results = document.at_css("main[class=\"container\"]") else {
            return response
        }
        
        /* Get names of rooms */
        for result in document.css("main[class=\"container\"] > h2") {
            var toAdd = LaundryRoom()
            
            if let roomName = result.text {
                toAdd.name = roomName
            }
            
            laundryRooms.append(toAdd)
        }
        
        /* Get machine info for each room */
        for (index, table) in document.css("main[class=\"container\"] > table").enumerated() {
            if index >= laundryRooms.count {
                break
            }
            
            for machine in table.css("tbody tr") {
                let name = machine.at_css("td[class=\"name\"]")?.text ?? ""
                let type = machine.at_css("td[class=\"type\"]")?.text ?? ""
                let status = machine.at_css("td[class=\"status\"]")?.text ?? ""
                let time = machine.at_css("td[class=\"time\"]")?.text ?? ""
                
                let toAdd = LaundryMachine(name: name, type: LaundryType(rawValue: type) ?? .washer, status: LaundryStatus(rawValue: status) ?? .other, time: time == "\u{00a0}" ? nil : time)
                
                laundryRooms[index].machines.append(toAdd)
            }
        }
        
        response.status = "success"
        response.rooms = laundryRooms
        return response
    }
}
