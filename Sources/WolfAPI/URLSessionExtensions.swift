//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

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
