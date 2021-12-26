//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import WolfBase

public struct StatusCode: Enumeration, Codable {
    public let rawValue: Int

    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }

    // RawRepresentable
    public init?(rawValue: Int) { self.init(rawValue) }
}

extension StatusCode {
    public static let ok = StatusCode(200)
    public static let created = StatusCode(201)
    public static let accepted = StatusCode(202)
    public static let noContent = StatusCode(204)

    public static let badRequest = StatusCode(400)
    public static let unauthorized = StatusCode(401)
    public static let forbidden = StatusCode(403)
    public static let notFound = StatusCode(404)
    public static let conflict = StatusCode(409)
    public static let tooManyRequests = StatusCode(429)

    public static let internalServerError = StatusCode(500)
    public static let notImplemented = StatusCode(501)
    public static let badGateway = StatusCode(502)
    public static let serviceUnavailable = StatusCode(503)
    public static let gatewayTimeout = StatusCode(504)
}
