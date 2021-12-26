//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import Foundation

extension URL {
    public init(scheme: Scheme, host: String, port: Int? = nil, basePath: String? = nil, pathComponents: [Any]? = nil, query: [String: String]? = nil) {
        let comps = URLComponents(scheme: scheme, host: host, port: port, basePath: basePath, pathComponents: pathComponents, query: query)
        self.init(string: comps.string!)!
    }
}
