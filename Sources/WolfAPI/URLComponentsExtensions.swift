//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import Foundation

extension URLComponents {
    public var queryDictionary: [String: String] {
        get {
            var dict = [String: String]()
            guard let queryItems = queryItems else { return dict }
            for item in queryItems {
                if let value = item.value {
                    dict[item.name] = value
                }
            }
            return dict
        }

        set {
            let queryItems: [URLQueryItem] = newValue.map {
                return URLQueryItem(name: $0.0, value: $0.1)
            }
            self.queryItems = queryItems
        }
    }

    public static func parametersDictionary(from string: String?) -> [String: String] {
        var dict = [String: String]()
        guard let string = string else { return dict }
        let items = string.components(separatedBy: "&")
        for item in items {
            let parts = item.components(separatedBy: "=")
            assert(parts.count == 2)
            dict[parts[0]] = parts[1]
        }
        return dict
    }
}

extension URLComponents {
    public init(scheme: Scheme, host: String, port: Int? = nil, basePath: String? = nil, pathComponents: [Any]? = nil, query: [String: String]? = nil) {
        self.init()

        self.scheme = scheme.rawValue
        self.host = host
        self.port = port

        var components = [String]()
        if let basePath = basePath {
            components.append(basePath)
        }
        if let pathComponents = pathComponents {
            for c in pathComponents {
                components.append(String(describing: c))
            }
        }
        self.path = "/" + components.joined(separator: "/")

        if let query = query {
            queryDictionary = query
        }
    }
}
