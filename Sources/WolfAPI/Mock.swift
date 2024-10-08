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

public struct Mock: Sendable {
    public let statusCode: StatusCode
    public let delay: TimeInterval
    public let data: Data

    public init(statusCode: StatusCode = .ok, delay: TimeInterval = 0.5, data: Data? = nil) {
        self.statusCode = statusCode
        self.delay = delay
        self.data = data ?? Data()
    }
    
    public init(statusCode: StatusCode = .ok, delay: TimeInterval = 0.5, string: String) {
        self.init(statusCode: statusCode, delay: delay, data: string.utf8Data)
    }
    
    public init<T: Encodable>(statusCode: StatusCode = .ok, delay: TimeInterval = 0.5, object: T) {
        self.init(statusCode: statusCode, delay: delay, data: try! JSONEncoder().encode(object))
    }

    public static let internalServerError = Mock(statusCode: .internalServerError)
    public static let unauthorized = Mock(statusCode: .unauthorized)
    public static let notFound = Mock(statusCode: .notFound)
}
