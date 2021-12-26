//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import Foundation

public struct Mock {
    public let statusCode: StatusCode
    public let delay: TimeInterval
    public let data: Data

    public init(statusCode: StatusCode = .ok, delay: TimeInterval = 0.5, data: Data? = nil) {
        self.statusCode = statusCode
        self.delay = delay
        self.data = data ?? Data()
    }
    
    public init<T: Encodable>(statusCode: StatusCode = .ok, delay: TimeInterval = 0.5, object: T) {
        self.init(statusCode: statusCode, delay: delay, data: try! JSONEncoder().encode(object))
    }

    public static var internalServerError = Mock(statusCode: .internalServerError)
    public static var unauthorized = Mock(statusCode: .unauthorized)
    public static var notFound = Mock(statusCode: .notFound)
}
