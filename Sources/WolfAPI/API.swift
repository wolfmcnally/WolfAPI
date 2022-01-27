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
import UserNotifications
import WolfBase

extension Notification.Name {
    public static let loggedOut = Notification.Name("loggedOut")
}

public enum APIError: Error {
    case credentialsRequired
    case typeMismatch
}

open class API {
    public let endpoint: Endpoint
    public let authorization: Authorization?
    public let session: URLSession

    public var debugPrintRequests = false

    public init(endpoint: Endpoint, authorization: Authorization? = nil, session: URLSession? = nil) {
        self.endpoint = endpoint
        self.authorization = authorization
        self.session = session ?? .shared
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
        authorization?.invalidate()
        NotificationCenter.default.post(name: .loggedOut, object: self)
    }
}

extension API {
    public func newRequest(
        isAuth: Bool,
        method: Method = .get,
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
            authorization?.authorizeRequest(&request)
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
        method: Method = .get,
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
        method: Method = .get,
        scheme: Scheme? = nil,
        path: [Any]? = nil,
        query: KeyValuePairs<String, String?>? = nil,
        body: RequestBody? = nil,
        successStatusCodes: [StatusCode] = [.ok],
        actions: URLSessionActions? = nil,
        mock: Mock? = nil
    ) async throws -> T  {
        let data = try await call(isAuth: isAuth, method: method, scheme: scheme, path: path, query: query, body: body, successStatusCodes: successStatusCodes, actions: actions, mock: mock)
        switch returnType {
        case is String.Type:
            guard let s = data.utf8 else {
                throw APIError.typeMismatch
            }
            return s as! T
        case is Int.Type:
            guard
                let s = data.utf8,
                let i = Int(s)
            else {
                throw APIError.typeMismatch
            }
            return i as! T
        case is Double.Type:
            guard
                let s = data.utf8,
                let d = Double(s)
            else {
                throw APIError.typeMismatch
            }
            return d as! T
        case is Float.Type:
            guard
                let s = data.utf8,
                let d = Float(s)
            else {
                throw APIError.typeMismatch
            }
            return d as! T
        case is Bool.Type:
            guard
                let s = data.utf8,
                let b = Bool(s)
            else {
                throw APIError.typeMismatch
            }
            return b as! T
        case is HexData.Type:
            guard
                let s = data.utf8,
                let d = HexData(hex: s)
            else {
                throw APIError.typeMismatch
            }
            return d as! T
        default:
            return try JSONDecoder().decode(returnType, from: data)
        }
    }
}
