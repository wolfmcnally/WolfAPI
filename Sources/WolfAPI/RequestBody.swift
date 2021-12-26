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
