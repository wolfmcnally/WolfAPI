import WolfBase

public struct CredentialsType: Enumeration, Codable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    // RawRepresentable
    public init?(rawValue: String) { self.init(rawValue) }
}

extension CredentialsType {
    public static let username = CredentialsType("username")
    public static let email = CredentialsType("email")
    public static let facebook = CredentialsType("facebook")
    public static let instagram = CredentialsType("instagram")
}

public struct Credentials: Codable {
    public let type: CredentialsType
    public let id: String
    public let token: String
    
    public init(type: CredentialsType, id: String, token: String) {
        self.type = type
        self.id = id
        self.token = token
    }
}

extension Credentials {
    public init(username: String, password: String) {
        self.init(type: .username, id: username, token: password)
    }

    public init(email: String, password: String) {
        self.init(type: .email, id: email, token: password)
    }

    public init(facebookID: String, token: String) {
        self.init(type: .facebook, id: facebookID, token: token)
    }

    public init(instagramID: String, token: String) {
        self.init(type: .instagram, id: instagramID, token: token)
    }
}
