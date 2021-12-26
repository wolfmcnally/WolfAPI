//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import WolfBase

public struct Method: Enumeration, Codable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    // RawRepresentable
    public init?(rawValue: String) { self.init(rawValue) }
}

extension Method {
    public static let get = Method("GET")
    public static let post = Method("POST")
    public static let patch = Method("PATCH")
    public static let head = Method("HEAD")
    public static let options = Method("OPTIONS")
    public static let put = Method("PUT")
    public static let delete = Method("DELETE")
    public static let trace = Method("TRACE")
    public static let connect = Method("CONNECT")
}
