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
import WolfBase

extension URLRequest {
    public func value(for header: RequestHeader) -> String? {
        return value(forHTTPHeaderField: header.rawValue)
    }

    public mutating func setMethod(_ method: Method) {
        httpMethod = method.rawValue
    }

    public mutating func setValue(_ value: String?, for header: RequestHeader) {
        setValue(value, forHTTPHeaderField: header.rawValue)
    }

    public mutating func addValue(_ value: String, for header: RequestHeader) {
        addValue(value, forHTTPHeaderField: header.rawValue)
    }

    public mutating func setAcceptContentType(_ contentType: ContentType) {
        setValue(contentType.rawValue, for: .accept)
    }

    public mutating func setContentType(_ contentType: ContentType, charset: Charset? = nil) {
        if let charset = charset {
            setValue("\(contentType.rawValue); charset=\(charset.rawValue)", for: .contentType)
        } else {
            setValue(contentType.rawValue, for: .contentType)
        }
    }

    public mutating func setContentTypeJSON() {
        setValue("\(ContentType.json.rawValue); charset=utf-8", for: .contentType)
    }

    public mutating func setContentLength(_ length: Int) {
        setValue(String(length), for: .contentLength)
    }

    public mutating func setConnection(_ connection: ConnectionType) {
        setValue(connection.rawValue, for: .connection)
    }

    public mutating func setAuthorization(_ value: String) {
        setValue(value, for: .authorization)
    }

    public mutating func setClientRequestID() {
        setValue(UUID().uuidString, for: .clientRequestID)
    }

    public var name: String {
        var name = [String]()
        name.append(httpMethod†)
        if let url = self.url {
            name.append(url.path)
        }
        return name.joined(separator: " ")
    }
}

extension URLRequest {
    public func printRequest(includeAuxFields: Bool = false, level: Int = 0) {
        print("➡️ \(httpMethod†) \(url†)".indented(level))

        let level = level + 1

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers {
                print("\(key): \(value)".indented(level))
            }
        }

        if let data = httpBody, data.count > 0 {
            print("body:".indented(level))

            let level = level + 1
            if let s = data.jsonString(options: .prettyPrinted) {
                print(s.indented(level))
            } else {
                print("Non-JSON Data: \(data)".indented(level))
            }
        }

        guard includeAuxFields else { return }

        let cachePolicyStrings: [URLRequest.CachePolicy: String] = [
            .useProtocolCachePolicy: ".useProtocolCachePolicy",
            .reloadIgnoringLocalCacheData: ".reloadIgnoringLocalCacheData",
            .returnCacheDataElseLoad: ".returnCacheDataElseLoad",
            .returnCacheDataDontLoad: ".returnCacheDataDontLoad"
            ]
        let networkServiceTypes: [URLRequest.NetworkServiceType: String]
        networkServiceTypes = [
            .`default`: ".default",
            .video: ".video",
            .background: ".background",
            .voice: ".voice",
            .callSignaling: ".callSignaling"
        ]

        print("timeoutInterval: \(timeoutInterval)".indented(level))
        print("cachePolicy: \(cachePolicyStrings[cachePolicy]!)".indented(level))
        print("allowsCellularAccess: \(allowsCellularAccess)".indented(level))
        print("httpShouldHandleCookies: \(httpShouldHandleCookies)".indented(level))
        print("httpShouldUsePipelining: \(httpShouldUsePipelining)".indented(level))
        print("mainDocumentURL: \(mainDocumentURL†)".indented(level))
        print("networkServiceType: \(networkServiceTypes[networkServiceType]!)".indented(level))
    }
}
