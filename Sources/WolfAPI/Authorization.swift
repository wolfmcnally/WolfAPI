//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import Foundation
import WolfKeychain

public protocol Authorization: Codable {
    static var currentVersion: Int { get }
    var version: Int { get }
    var token: String { get set }
}

public struct CredentialsAuthorization: Authorization {
    public static var currentVersion = 1
    public var version: Int = 1
    public var token: String
    public var credentials: Credentials
    
    public var id: String {
        credentials.id
    }
}

public struct APIKeyAuthorization: Authorization {
    public static var currentVersion = 1
    public var version: Int = 1
    public var token: String
}

public struct NoAuthorization: Authorization {
    public static var currentVersion = 1
    public var version: Int = 1
    public var token: String {
        get {
            fatalError("Unimplemented.")
        }
        
        set {
            fatalError("Unimplemented.")
        }
    }
}
