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

public extension URLSession {
    func retrieveData(for request: URLRequest, actions: URLSessionActions? = nil, successStatusCodes: [StatusCode] = [.ok], mock: Mock? = nil) async throws -> Data {
        let statusCode: StatusCode
        let responseData: Data
        let httpResponse: HTTPURLResponse
        
        if let mock = mock {
            try await Task.sleep(nanoseconds: UInt64(mock.delay * 1_000_000_000))
            responseData = mock.data
            statusCode = mock.statusCode
            httpResponse = HTTPURLResponse(url: request.url!, statusCode: statusCode.rawValue, httpVersion: nil, headerFields: nil)!
        } else {
            let (data, response) = try await data(for: request, delegate: actions)
            responseData = data
            httpResponse = response as! HTTPURLResponse
            statusCode = StatusCode(httpResponse.statusCode)
        }
        guard successStatusCodes.contains(statusCode) else {
            throw HTTPError(request: request, response: httpResponse, data: responseData)
        }
        return responseData
    }
}
