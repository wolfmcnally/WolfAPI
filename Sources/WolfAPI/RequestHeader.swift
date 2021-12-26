//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import WolfBase

public struct RequestHeader: Enumeration, Codable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    // RawRepresentable
    public init?(rawValue: String) { self.init(rawValue) }
}

extension RequestHeader {
    public static let accept = RequestHeader("Accept")
    public static let contentType = RequestHeader("Content-Type")
    public static let encoding = RequestHeader("Encoding")
    public static let connection = RequestHeader("Connection")
    public static let authorization = RequestHeader("Authorization")
    public static let contentRange = RequestHeader("Content-Range")
    public static let uploadToken = RequestHeader("Upload-Token")
    public static let contentLength = RequestHeader("Content-Length")
    public static let clientRequestID = RequestHeader("X-Client-Request-ID")
    public static let awsRequestID = RequestHeader("x-amzn-RequestId")
}
