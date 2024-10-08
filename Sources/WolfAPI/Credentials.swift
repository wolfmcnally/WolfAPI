//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import WolfBase

public struct CredentialsType: Enumeration, Codable, Sendable {
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
