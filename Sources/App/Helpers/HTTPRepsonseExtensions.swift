//
//  File.swift
//  
//
//  Created by Anderson David on 7/14/21.
//

import Foundation
import Vapor

extension Data {
    public func encodeResponse(for request: Request, code: HTTPResponseStatus, contentType: String? = nil) -> EventLoopFuture<Response> {
        var headers = HTTPHeaders()
        
        if let content = contentType {
            headers.add(name: .contentType, value: content)
        }
        else {
            headers.add(name: .contentType, value: "application/octet-stream")
        }
        
        return request.eventLoop.makeSucceededFuture(.init(status: code, headers: headers, body: .init(data: self)))
    }
}
