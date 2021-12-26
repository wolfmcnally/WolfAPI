//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import Foundation

public struct HTTPError: Error {
    public let request: URLRequest
    public let response: HTTPURLResponse
    public let data: Data?

    public init(request: URLRequest, response: HTTPURLResponse, data: Data? = nil) {
        self.request = request
        self.response = response
        self.data = data
    }

    public var message: String {
        return HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
    }

    public var code: Int {
        return response.statusCode
    }

    public var statusCode: StatusCode {
        return StatusCode(code)
    }

    public var identifier: String {
        return "HTTPError(\(code))"
    }
}

extension HTTPError: CustomStringConvertible {
    public var description: String {
        return "HTTPError(\(code) \(message))"
    }
}
