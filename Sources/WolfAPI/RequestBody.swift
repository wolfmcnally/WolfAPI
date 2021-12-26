//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import Foundation

public struct RequestBody {
    public let data: Data
    public let isJSON: Bool
    
    public init(data: Data, isJSON: Bool = false) {
        self.data = data
        self.isJSON = isJSON
    }
    
    public init(string: String) {
        self.init(data: string.utf8Data)
    }
    
    public init<T: Encodable>(obj: T) {
        try! self.init(data: JSONEncoder().encode(obj), isJSON: true)
    }
}

extension URLRequest {
    public mutating func setBody(_ b: RequestBody) {
        httpBody = b.data
        setContentLength(b.data.count)
        if b.isJSON {
            setContentType(.json, charset: .utf8)
        }
    }
}
