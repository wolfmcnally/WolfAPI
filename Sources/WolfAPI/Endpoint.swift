//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import Foundation

public struct Endpoint {
    public let scheme: Scheme
    public let host: String
    public let port: Int?
    public let basePath: String?

    public init(scheme: Scheme = .https, host: String, port: Int? = nil, basePath: String? = nil) {
        self.scheme = scheme
        self.host = host
        self.port = port
        self.basePath = basePath
    }
}
