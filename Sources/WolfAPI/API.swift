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

import Foundation
import WolfKeychain
import UserNotifications

extension Notification.Name {
    public static let loggedOut = Notification.Name("loggedOut")
}

public enum APIError: Error {
    case credentialsRequired
}

open class API<Auth: Authorization> {
    public let endpoint: Endpoint
    public let authorizationHeader: RequestHeader
    public let keychain: Keychain?
    public let session: URLSession

    public var debugPrintRequests = false

    public init(endpoint: Endpoint, authorizationHeader: RequestHeader = .authorization, keychain: Keychain? = nil, session: URLSession? = nil) {
        self.endpoint = endpoint
        self.authorizationHeader = authorizationHeader
        self.keychain = keychain
        self.session = session ?? .shared
        guard
            let keychain = keychain,
            let authorization = try? keychain.read(Auth.self),
            authorization.version == Auth.currentVersion
        else {
            return
        }
        self.authorization = authorization
    }
    
    private var _authorization: Auth?

    public var authorization: Auth? {
        get {
            _authorization
        }
        
        set {
            do {
                try setAuthorization(authorization: newValue)
            } catch {
                print("Error updating keychain: \(error).")
            }
        }
    }

    public func setAuthorization(authorization: Auth?) throws {
        if let keychain = keychain {
            if let authorization = authorization {
                try keychain.update(authorization, upsert: true)
            } else {
                try keychain.delete()
            }
        }
        self._authorization = authorization
    }
    
    public var hasAuthorization: Bool {
        authorization != nil
    }
    
    public var token: String {
        get {
            authorization!.token
        }
        
        set {
            var a = authorization!
            a.token = newValue
            try! setAuthorization(authorization: a)
        }
    }
    
    open func handleError(_ error: Error) {
        if
            let e = error as? HTTPError,
            e.statusCode == .unauthorized
        {
            logout()
        }
    }
    
    open func logout() {
        authorization = nil
        NotificationCenter.default.post(name: .loggedOut, object: self)
    }
}

extension API {
    public func newRequest(
        isAuth: Bool,
        method: Method,
        scheme: Scheme? = nil,
        path: [Any]? = nil,
        query: KeyValuePairs<String, String?>? = nil,
        body: RequestBody? = nil
    ) throws -> URLRequest {
        guard !isAuth || authorization != nil else {
            throw APIError.credentialsRequired
        }

        let queryItems: [URLQueryItem]?
        if let query = query {
            queryItems = query.map {
                URLQueryItem(name: $0.0, value: $0.1)
            }
        } else {
            queryItems = nil
        }
        var urlComponents = URLComponents(scheme: scheme ?? endpoint.scheme, host: endpoint.host, port: endpoint.port, basePath: endpoint.basePath, pathComponents: path)
        urlComponents.queryItems = queryItems
        var request = URLRequest(url: urlComponents.url!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setClientRequestID()
        request.setMethod(method)
        request.setConnection(.close)
        if isAuth {
            request.setValue(token, for: authorizationHeader)
        }
        if let body = body {
            request.setBody(body)
        }
        
        if debugPrintRequests {
            request.printRequest()
        }

        return request
    }
}

extension API {
    public func call(
        isAuth: Bool = false,
        method: Method,
        scheme: Scheme? = nil,
        path: [Any]? = nil,
        query: KeyValuePairs<String, String?>? = nil,
        body: RequestBody? = nil,
        successStatusCodes: [StatusCode] = [.ok],
        actions: URLSessionActions? = nil,
        mock: Mock? = nil
    ) async throws -> Data  {
        let request = try newRequest(isAuth: isAuth, method: method, scheme: scheme, path: path, query: query, body: body)
        do {
            return try await session.retrieveData(for: request, actions: actions, successStatusCodes: successStatusCodes, mock: mock)
        } catch {
            handleError(error)
            throw error
        }
    }

    public func call<T: Decodable>(
        returning returnType: T.Type,
        isAuth: Bool = false,
        method: Method,
        scheme: Scheme? = nil,
        path: [Any]? = nil,
        query: KeyValuePairs<String, String?>? = nil,
        body: RequestBody? = nil,
        successStatusCodes: [StatusCode] = [.ok],
        actions: URLSessionActions? = nil,
        mock: Mock? = nil
    ) async throws -> T  {
        let data = try await call(isAuth: isAuth, method: method, scheme: scheme, path: path, query: query, body: body, successStatusCodes: successStatusCodes, actions: actions, mock: mock)
        return try JSONDecoder().decode(returnType, from: data)
    }
}