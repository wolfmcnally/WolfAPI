//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import WolfBase

public struct ConnectionType: Enumeration, Codable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init?(rawValue: String) { self.init(rawValue) }
}

extension ConnectionType {
    public static let close = ConnectionType("close")
    public static let keepAlive = ConnectionType("keep-alive")
}
