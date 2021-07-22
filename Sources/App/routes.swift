import Vapor
import Purdue_App_API_Models

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.get("dining", "locations") { req -> EventLoopFuture<Response> in
        let uri = URI(string: "\(DiningHelpers.baseURL)/locations/")
        return req.client.get(uri).flatMap { res in
            
            let encoder = JSONEncoder()
            guard let locations = try? res.content.decode(DiningLocationResponse.self), let data = try? encoder.encode(locations).encodeResponse(for: req, code: .ok, contentType: "application/json; charset=utf-8") else {
                return "Unable to decode JSON".data(using: .utf8)?.encodeResponse(for: req, code: .internalServerError) ?? Data().encodeResponse(for: req, code: .internalServerError)
            }
            
            return data
        }
    }
    
    app.get("dining", "locations", ":locationName", ":date") { req -> EventLoopFuture<Response> in
        
        guard let locationString = req.parameters.get("locationName"), let location = LocationName(rawValue: locationString) else {
            return "Invalid location name".data(using: .utf8)?.encodeResponse(for: req, code: .badRequest) ?? Data().encodeResponse(for: req, code: .badRequest)
        }
        
        guard let dateString = req.parameters.get("date"), let date = DiningHelpers.dateFormatter.date(from: dateString) else {
            return "Invalid date".data(using: .utf8)?.encodeResponse(for: req, code: .badRequest) ?? Data().encodeResponse(for: req, code: .badRequest)
        }
        
        let uri = URI(string: "\(DiningHelpers.baseURL)/locations/\(location.rawValue)/\(dateString)")
        return req.client.get(uri).flatMap { res in
            
            let encoder = JSONEncoder()
            guard let diningCourt = try? res.content.decode(DiningCourt.self), let data = try? encoder.encode(diningCourt).encodeResponse(for: req, code: .ok, contentType: "application/json; charset=utf-8") else {
                return "Unable to decode JSON".data(using: .utf8)?.encodeResponse(for: req, code: .internalServerError) ?? Data().encodeResponse(for: req, code: .internalServerError)
            }
            
            return data
        }
    }
    
    app.get("dining", "items", ":itemID") { req -> EventLoopFuture<Response> in
        
        guard let itemID = req.parameters.get("itemID") else {
            return "Invalid item ID".data(using: .utf8)?.encodeResponse(for: req, code: .badRequest) ?? Data().encodeResponse(for: req, code: .badRequest)
        }
        
        let uri = URI(string: "\(DiningHelpers.baseURL)/items/\(itemID)")
        return req.client.get(uri).flatMap { res in
            
            guard let item = try? res.content.decode(ItemDetail.self), let data = try? JSONEncoder().encode(item).encodeResponse(for: req, code: .ok, contentType: "application/json; charset=utf-8") else {
                return "Unable to decode JSON".data(using: .utf8)?.encodeResponse(for: req, code: .internalServerError) ?? Data().encodeResponse(for: req, code: .internalServerError)
            }
            
            return data
        }
    }
    
    app.get("corec", "locations") { req -> EventLoopFuture<Response> in
        let uri = URI(string: "\(CorecHelpers.baseURL)")
        return req.client.get(uri).flatMap { res in
            
            let encoder = JSONEncoder()
            guard let locations = try? res.content.decode([CorecLocation].self, using: JSONDecoder()), let data = try? encoder.encode(locations).encodeResponse(for: req, code: .ok, contentType: "application/json; charset=utf-8") else {
                return "Unable to decode JSON".data(using: .utf8)?.encodeResponse(for: req, code: .internalServerError) ?? Data().encodeResponse(for: req, code: .internalServerError)
            }
            
            return data
        }
    }
    
    app.get("dining", "retail") { req -> EventLoopFuture<Response> in
        let uri = URI(string: "\(DiningHelpers.baseURL)/retail/")
        return req.client.get(uri).flatMap { res in
            
            let encoder = JSONEncoder()
            guard let locations = try? res.content.decode(RetailLocationResponse.self), let data = try? encoder.encode(locations).encodeResponse(for: req, code: .ok, contentType: "application/json; charset=utf-8") else {
                return "Unable to decode JSON".data(using: .utf8)?.encodeResponse(for: req, code: .internalServerError) ?? Data().encodeResponse(for: req, code: .internalServerError)
            }
            
            return data
        }
    }
    
//    app.get("dining2", "locations", ":locationName", ":date") { req -> EventLoopFuture<Response> in
//
//        var headers = HTTPHeaders()
//        headers.add(name: .contentType, value: "application/json; charset=utf-8")
//
//        guard let locationString = req.parameters.get("locationName"), let location = LocationName(rawValue: locationString) else {
//            return req.eventLoop.makeSucceededFuture(Response(status: .custom(code: 404, reasonPhrase: "Invalid location"), headers: headers, body: "Invalid location"))
//        }
//
//        guard let dateString = req.parameters.get("date"), let date = Helpers.dateFormatter.date(from: dateString) else {
//            return req.eventLoop.makeSucceededFuture(Response(status: .custom(code: 404, reasonPhrase: "Invalid date"), headers: headers, body: "Invalid date"))
//        }
//
//        var futures:[EventLoopFuture<DiningCourt?>] = []
//        for daysAfter in 0..<3 {
//            var dayComp = DateComponents()
//            dayComp.day = daysAfter
//
//            guard let dateToUse = Calendar.current.date(byAdding: dayComp, to: date) else {
//                return req.eventLoop.makeSucceededFuture(Response(status: .custom(code: 404, reasonPhrase: "Invalid date"), headers: headers, body: "Invalid date"))
//            }
//
//            let uri = URI(string: "\(baseURL)/locations/\(location.rawValue)/\(Helpers.dateFormatter.string(from: dateToUse))")
//
//            futures.append(req.client.get(uri).map { res in
//                do {
//                    let diningCourt = try res.content.decode(DiningCourt.self)
//                    return diningCourt
//                } catch {
//                    return nil
//                }
//            })
//        }
//
//        return req.eventLoop.flatten(futures).map { diningCourts -> Response in
//            guard let data = try? JSONEncoder().encode(diningCourts) else {
//                return Response(status: .custom(code: 404, reasonPhrase: "Unable to JSONify"), headers: headers, body: .init(string: "Invalid date"))
//            }
//
//            return Response(status: .ok, headers: headers, body: .init(string: String(data: data, encoding: .utf8) ?? "Unable to JSONify"))
//        }
//    }
}
