//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import WolfBase

public struct Charset: Enumeration, Codable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    // RawRepresentable
    public init?(rawValue: String) { self.init(rawValue) }
}

extension Charset {
    public static let utf8 = Charset("utf-8")
}
