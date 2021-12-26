//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/26/21.
//

import Foundation

public class URLSessionActions: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate, URLSessionStreamDelegate, URLSessionWebSocketDelegate {
    
    public var response: URLResponse?
    public var data: Data?
    public var downloadLocation: URL?
    public var error: Error?
    
    public init(keepData: Bool = true) {
        super.init()
        if keepData {
            data = Data()
        }
//        dataTaskDidReceiveResponse = { (actions, session, dataTask, response, completionHandler) in
//            completionHandler(.allow)
//        }
//        dataTaskWillCacheResponse = { (actions, session, dataTask, proposedResponse, completionHandler) in
//            completionHandler(proposedResponse)
//        }
    }
    
    public override convenience init() {
        self.init(keepData: true)
    }

    // MARK: - Callback Closures
    
    
    // MARK: URLSessionDelegate
    
    public var didBecomeInvalid: ((URLSessionActions, URLSession, Error?) -> Void)?
    
    public var didReceiveChallenge: ((URLSessionActions, URLSession, URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?))?
    
    public var didFinishEvents: ((URLSessionActions, URLSession) -> Void)?

    
    // MARK: URLSessionTaskDelegate
    
    public var taskWillBeginDelayedRequest: ((URLSessionActions, URLSession, URLSessionTask, URLRequest) async -> (URLSession.DelayedRequestDisposition, URLRequest?))?
    
    public var taskIsWaitingForConnectivity: ((URLSessionActions, URLSession, URLSessionTask) -> Void)?
    
    public var taskWillPerformHTTPRedirection: ((URLSessionActions, URLSession, URLSessionTask, _ response: HTTPURLResponse, _ newRequest: URLRequest) async -> URLRequest?)?
    
    public var taskDidReceiveChallenge: ((URLSessionActions, URLSession, URLSessionTask, URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?))?
    
    public var taskNeedNewBodyStream: ((URLSessionActions, URLSession, URLSessionTask) async -> InputStream?)?

    public var taskDidSendBodyData: ((URLSessionActions, URLSession, URLSessionTask, _ bytesSent: Int64, _ totalBytesSent: Int64, _ totalBytesExpectedToSend: Int64) -> Void)?
    
    public var taskDidFinishCollectingMetrics: ((URLSessionActions, URLSession, URLSessionTask, _ metrics: URLSessionTaskMetrics) -> Void)?
    
    public var taskDidComplete: ((URLSessionActions, URLSession, URLSessionTask, Error?) -> Void)?

    
    // MARK: URLSessionDataDelegate
    
    public var dataTaskDidReceiveResponse: ((URLSessionActions, URLSession, URLSessionDataTask, URLResponse) async -> (URLSession.ResponseDisposition))?
    
    public var dataTaskDidBecomeDownloadTask: ((URLSessionActions, URLSession, URLSessionDataTask, URLSessionDownloadTask) -> Void)?
    
    public var dataTaskDidBecomeStreamTask: ((URLSessionActions, URLSession, URLSessionDataTask, URLSessionStreamTask) -> Void)?
    
    public var dataTaskDidReceiveData: ((URLSessionActions, URLSession, URLSessionDataTask, Data) -> Void)?
    
    public var dataTaskWillCacheResponse: ((URLSessionActions, URLSession, URLSessionDataTask, _ proposedResponse: CachedURLResponse) async -> CachedURLResponse?)?
    
    
    // MARK: URLSessionDownloadDelegate
    
    public var downloadTaskDidFinishDownloading: ((URLSessionActions, URLSession, URLSessionDownloadTask, _ to: URL) -> Void)?
    
    public var downloadTaskDidWriteData: ((URLSessionActions, URLSession, URLSessionDownloadTask, _ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void)?
    
    public var downloadTaskDidResume: ((URLSessionActions, URLSession, URLSessionDownloadTask, _ fileOffset: Int64, _ expectedTotalBytes: Int64) -> Void)?
    
    
    // MARK: URLSessionStreamDelegate
    
    public var streamTaskReadClosed: ((URLSessionActions, URLSession, URLSessionStreamTask) -> Void)?
    
    public var streamTaskWriteClosed: ((URLSessionActions, URLSession, URLSessionStreamTask) -> Void)?
    
    public var streamTaskBetterRouteDiscovered: ((URLSessionActions, URLSession, URLSessionStreamTask) -> Void)?
    
    public var streamTaskDidBecomeStreams: ((URLSessionActions, URLSession, URLSessionStreamTask, InputStream, OutputStream) -> Void)?
    
    
    // MARK: URLSessionWebSocketDelegate
    
    public var webSocketTaskDidOpen: ((URLSessionActions, URLSession, URLSessionWebSocketTask, _ protocol: String?) -> Void)?
    
    public var webSocketDidClose: ((URLSessionActions, URLSession, URLSessionWebSocketTask, _ closeCode: URLSessionWebSocketTask.CloseCode, _ reason: Data?) -> Void)?
    
    
    // MARK: - Delegate Functions

    
    // MARK: URLSessionDelegate

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        self.error = error
        didBecomeInvalid?(self, session, error)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        if let didReceiveChallenge = didReceiveChallenge {
            return await didReceiveChallenge(self, session, challenge)
        } else {
            return (.useCredential, challenge.proposedCredential)
        }
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        didFinishEvents?(self, session)
    }
    
    // MARK: URLSessionTaskDelegate

    //
    // KLUDGE: As of December 26, 2021 (Xcode 13.2) the commented-out async code below is causing a compiler segmentation fault. The workaround appears to be to use the callback-style delegate method below.
    //
    
    //    public func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest) async -> (URLSession.DelayedRequestDisposition, URLRequest?) {
    //        if let taskWillBeginDelayedRequest = taskWillBeginDelayedRequest {
    //            return await taskWillBeginDelayedRequest(self, session, task, request)
    //        } else {
    //            return (.continueLoading, nil)
    //        }
    //    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        if let taskWillBeginDelayedRequest = taskWillBeginDelayedRequest {
            Task {
                let (disposition, request) = await taskWillBeginDelayedRequest(self, session, task, request)
                completionHandler(disposition, request)
            }
        } else {
            completionHandler(.continueLoading, nil)
        }
    }
    
    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        taskIsWaitingForConnectivity?(self, session, task)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        if let taskWillPerformHTTPRedirection = taskWillPerformHTTPRedirection {
            return await taskWillPerformHTTPRedirection(self, session, task, response, request)
        } else {
            return nil
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        if let taskDidReceiveChallenge = taskDidReceiveChallenge {
            return await taskDidReceiveChallenge(self, session, task, challenge)
        } else {
            return (.useCredential, challenge.proposedCredential)
        }
    }
    
    public func urlSession(_ session: URLSession, needNewBodyStreamForTask task: URLSessionTask) async -> InputStream? {
        if let taskNeedNewBodyStream = taskNeedNewBodyStream {
            return await taskNeedNewBodyStream(self, session, task)
        } else {
            return nil
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        taskDidSendBodyData?(self, session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        taskDidFinishCollectingMetrics?(self, session, task, metrics)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.error = error
        session.finishTasksAndInvalidate()
        taskDidComplete?(self, session, task, error)
    }

    
    // MARK: URLSessionDataDelegate
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        self.response = response
        if let dataTaskDidReceiveResponse = dataTaskDidReceiveResponse {
            return await dataTaskDidReceiveResponse(self, session, dataTask, response)
        } else {
            return .allow
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        dataTaskDidBecomeDownloadTask?(self, session, dataTask, downloadTask)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        dataTaskDidBecomeStreamTask?(self, session, dataTask, streamTask)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive newData: Data) {
        data?.append(newData)
        dataTaskDidReceiveData?(self, session, dataTask, newData)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) async -> CachedURLResponse? {
        await dataTaskWillCacheResponse?(self, session, dataTask, proposedResponse)
    }
    
    
    // MARK: URLSessionDownloadDelegate
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        downloadLocation = location
        downloadTaskDidFinishDownloading?(self, session, downloadTask, location)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloadTaskDidWriteData?(self, session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        downloadTaskDidResume?(self, session, downloadTask, fileOffset, expectedTotalBytes)
    }

    
    // MARK: URLSessionStreamDelegate
    
    public func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask) {
        streamTaskReadClosed?(self, session, streamTask)
    }
    
    public func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask) {
        streamTaskWriteClosed?(self, session, streamTask)
    }
    
    public func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream) {
        streamTaskDidBecomeStreams?(self, session, streamTask, inputStream, outputStream)
    }

    // MARK: URLSessionWebSocketDelegate
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocl: String?) {
        webSocketTaskDidOpen?(self, session, webSocketTask, protocl)
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        webSocketDidClose?(self, session, webSocketTask, closeCode, reason)
    }
}
