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

/// A class that handles URL session actions with thread-safe access to mutable state.
/// All mutable properties are accessed on the main actor, and closures are immutable and `@Sendable`.
public final class URLSessionActions: NSObject, Sendable, URLSessionDataDelegate, URLSessionDownloadDelegate, URLSessionStreamDelegate, URLSessionWebSocketDelegate {
    
    @MainActor public var response: URLResponse?
    @MainActor public var data: Data?
    @MainActor public var downloadLocation: URL?
    @MainActor public var error: Error?
    
    
    @MainActor func setResponse(_ response: URLResponse) {
        self.response = response
    }

    @MainActor func appendData(_ data: Data) {
        self.data?.append(data)
    }
    
    @MainActor func setDownloadLocation(_ url: URL?) {
        self.downloadLocation = url
    }
    
    @MainActor func setError(_ error: Error?) {
        self.error = error
    }
    
    public init(
        keepData: Bool = true,
        
        didBecomeInvalid: DidBecomeInvalid? = nil,
        didReceiveChallenge: DidReceiveChallenge? = nil,
        didFinishEvents: DidFinishEvents? = nil,

        taskWillBeginDelayedRequest: TaskWillBeginDelayedRequest? = nil,
        taskIsWaitingForConnectivity: TaskIsWaitingForConnectivity? = nil,
        taskWillPerformHTTPRedirection: TaskWillPerformHTTPRedirection? = nil,
        taskDidReceiveChallenge: TaskDidReceiveChallenge? = nil,
        taskNeedNewBodyStream: TaskNeedNewBodyStream? = nil,
        taskDidSendBodyData: TaskDidSendBodyData? = nil,
        taskDidFinishCollectingMetrics: TaskDidFinishCollectingMetrics? = nil,
        taskDidComplete: TaskDidComplete? = nil,
        
        dataTaskDidReceiveResponse: DataTaskDidReceiveResponse? = nil,
        dataTaskDidBecomeDownloadTask: DataTaskDidBecomeDownloadTask? = nil,
        dataTaskDidBecomeStreamTask: DataTaskDidBecomeStreamTask? = nil,
        dataTaskDidReceiveData: DataTaskDidReceiveData? = nil,
        dataTaskWillCacheResponse: DataTaskWillCacheResponse? = nil,
        
        downloadTaskDidFinishDownloading: DownloadTaskDidFinishDownloading? = nil,
        downloadTaskDidWriteData: DownloadTaskDidWriteData? = nil,
        downloadTaskDidResume: DownloadTaskDidResume? = nil,
        
        streamTaskReadClosed: StreamTaskReadClosed? = nil,
        streamTaskWriteClosed: StreamTaskWriteClosed? = nil,
        streamTaskBetterRouteDiscovered: StreamTaskBetterRouteDiscovered? = nil,
        streamTaskDidBecomeStreams: StreamTaskDidBecomeStreams? = nil,
        
        webSocketTaskDidOpen: WebSocketTaskDidOpen? = nil,
        webSocketDidClose: WebSocketDidClose? = nil

    ) {
        self.didBecomeInvalid = didBecomeInvalid
        self.didReceiveChallenge = didReceiveChallenge
        self.didFinishEvents = didFinishEvents

        self.taskWillBeginDelayedRequest = taskWillBeginDelayedRequest
        self.taskIsWaitingForConnectivity = taskIsWaitingForConnectivity
        self.taskWillPerformHTTPRedirection = taskWillPerformHTTPRedirection
        self.taskDidReceiveChallenge = taskDidReceiveChallenge
        self.taskNeedNewBodyStream = taskNeedNewBodyStream
        self.taskDidSendBodyData = taskDidSendBodyData
        self.taskDidFinishCollectingMetrics = taskDidFinishCollectingMetrics
        self.taskDidComplete = taskDidComplete

        self.dataTaskDidReceiveResponse = dataTaskDidReceiveResponse
        self.dataTaskDidBecomeDownloadTask = dataTaskDidBecomeDownloadTask
        self.dataTaskDidBecomeStreamTask = dataTaskDidBecomeStreamTask
        self.dataTaskDidReceiveData = dataTaskDidReceiveData
        self.dataTaskWillCacheResponse = dataTaskWillCacheResponse
        
        self.downloadTaskDidFinishDownloading = downloadTaskDidFinishDownloading
        self.downloadTaskDidWriteData = downloadTaskDidWriteData
        self.downloadTaskDidResume = downloadTaskDidResume
        
        self.streamTaskReadClosed = streamTaskReadClosed
        self.streamTaskWriteClosed = streamTaskWriteClosed
        self.streamTaskBetterRouteDiscovered = streamTaskBetterRouteDiscovered
        self.streamTaskDidBecomeStreams = streamTaskDidBecomeStreams
        
        self.webSocketTaskDidOpen = webSocketTaskDidOpen
        self.webSocketDidClose = webSocketDidClose

        super.init()

        if keepData {
            data = Data()
        }
    }
    
    public override convenience init() {
        self.init(keepData: true)
    }

    // MARK: - Callback Closures
    
    
    // MARK: URLSessionDelegate

    public typealias DidBecomeInvalid = (@Sendable (URLSessionActions, URLSession, Error?) -> Void)
    public typealias DidReceiveChallenge = (@Sendable (URLSessionActions, URLSession, URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?))
    public typealias DidFinishEvents = (@Sendable (URLSessionActions, URLSession) -> Void)

    public let didBecomeInvalid: DidBecomeInvalid?
    public let didReceiveChallenge: DidReceiveChallenge?
    public let didFinishEvents: DidFinishEvents?

    
    // MARK: URLSessionTaskDelegate

    public typealias TaskWillBeginDelayedRequest = (@Sendable (URLSessionActions, URLSession, URLSessionTask, URLRequest) async -> (URLSession.DelayedRequestDisposition, URLRequest?))
    public typealias TaskIsWaitingForConnectivity = (@Sendable (URLSessionActions, URLSession, URLSessionTask) -> Void)
    public typealias TaskWillPerformHTTPRedirection = (@Sendable (URLSessionActions, URLSession, URLSessionTask, _ response: HTTPURLResponse, _ newRequest: URLRequest) async -> URLRequest?)
    public typealias TaskDidReceiveChallenge = (@Sendable (URLSessionActions, URLSession, URLSessionTask, URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?))
    public typealias TaskNeedNewBodyStream = (@Sendable (URLSessionActions, URLSession, URLSessionTask) async -> InputStream?)
    public typealias TaskDidSendBodyData = (@Sendable (URLSessionActions, URLSession, URLSessionTask, _ bytesSent: Int64, _ totalBytesSent: Int64, _ totalBytesExpectedToSend: Int64) -> Void)
    public typealias TaskDidFinishCollectingMetrics = (@Sendable (URLSessionActions, URLSession, URLSessionTask, _ metrics: URLSessionTaskMetrics) -> Void)
    public typealias TaskDidComplete = (@Sendable (URLSessionActions, URLSession, URLSessionTask, Error?) -> Void)

    public let taskWillBeginDelayedRequest: TaskWillBeginDelayedRequest?
    public let taskIsWaitingForConnectivity: TaskIsWaitingForConnectivity?
    public let taskWillPerformHTTPRedirection: TaskWillPerformHTTPRedirection?
    public let taskDidReceiveChallenge: TaskDidReceiveChallenge?
    public let taskNeedNewBodyStream: TaskNeedNewBodyStream?
    public let taskDidSendBodyData: TaskDidSendBodyData?
    public let taskDidFinishCollectingMetrics: TaskDidFinishCollectingMetrics?
    public let taskDidComplete: TaskDidComplete?

    
    // MARK: URLSessionDataDelegate

    public typealias DataTaskDidReceiveResponse = (@Sendable (URLSessionActions, URLSession, URLSessionDataTask, URLResponse) async -> (URLSession.ResponseDisposition))
    public typealias DataTaskDidBecomeDownloadTask = (@Sendable (URLSessionActions, URLSession, URLSessionDataTask, URLSessionDownloadTask) -> Void)
    public typealias DataTaskDidBecomeStreamTask = (@Sendable (URLSessionActions, URLSession, URLSessionDataTask, URLSessionStreamTask) -> Void)
    public typealias DataTaskDidReceiveData = (@Sendable (URLSessionActions, URLSession, URLSessionDataTask, Data) -> Void)
    public typealias DataTaskWillCacheResponse = (@Sendable (URLSessionActions, URLSession, URLSessionDataTask, _ proposedResponse: CachedURLResponse) async -> CachedURLResponse?)

    public let dataTaskDidReceiveResponse: DataTaskDidReceiveResponse?
    public let dataTaskDidBecomeDownloadTask: DataTaskDidBecomeDownloadTask?
    public let dataTaskDidBecomeStreamTask: DataTaskDidBecomeStreamTask?
    public let dataTaskDidReceiveData: DataTaskDidReceiveData?
    public let dataTaskWillCacheResponse: DataTaskWillCacheResponse?
    
    
    // MARK: URLSessionDownloadDelegate

    public typealias DownloadTaskDidFinishDownloading = (@Sendable (URLSessionActions, URLSession, URLSessionDownloadTask, _ to: URL) -> Void)
    public typealias DownloadTaskDidWriteData = (@Sendable (URLSessionActions, URLSession, URLSessionDownloadTask, _ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void)
    public typealias DownloadTaskDidResume = (@Sendable (URLSessionActions, URLSession, URLSessionDownloadTask, _ fileOffset: Int64, _ expectedTotalBytes: Int64) -> Void)

    public let downloadTaskDidFinishDownloading: DownloadTaskDidFinishDownloading?
    public let downloadTaskDidWriteData: DownloadTaskDidWriteData?
    public let downloadTaskDidResume: DownloadTaskDidResume?
    
    
    // MARK: URLSessionStreamDelegate
    
    public typealias StreamTaskReadClosed = (@Sendable (URLSessionActions, URLSession, URLSessionStreamTask) -> Void)
    public typealias StreamTaskWriteClosed = (@Sendable (URLSessionActions, URLSession, URLSessionStreamTask) -> Void)
    public typealias StreamTaskBetterRouteDiscovered = (@Sendable (URLSessionActions, URLSession, URLSessionStreamTask) -> Void)
    public typealias StreamTaskDidBecomeStreams = (@Sendable (URLSessionActions, URLSession, URLSessionStreamTask, InputStream, OutputStream) -> Void)

    public let streamTaskReadClosed: StreamTaskReadClosed?
    public let streamTaskWriteClosed: StreamTaskWriteClosed?
    public let streamTaskBetterRouteDiscovered: StreamTaskBetterRouteDiscovered?
    public let streamTaskDidBecomeStreams: StreamTaskDidBecomeStreams?
    
    
    // MARK: URLSessionWebSocketDelegate

    public typealias WebSocketTaskDidOpen = (@Sendable (URLSessionActions, URLSession, URLSessionWebSocketTask, _ protocol: String?) -> Void)
    public typealias WebSocketDidClose = (@Sendable (URLSessionActions, URLSession, URLSessionWebSocketTask, _ closeCode: URLSessionWebSocketTask.CloseCode, _ reason: Data?) -> Void)

    public let webSocketTaskDidOpen: WebSocketTaskDidOpen?
    public let webSocketDidClose: WebSocketDidClose?
    
    
    // MARK: - Delegate Functions

    
    // MARK: URLSessionDelegate

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        Task {
            await setError(error)
            didBecomeInvalid?(self, session, error)
        }
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

    public func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest) async -> (URLSession.DelayedRequestDisposition, URLRequest?) {
        if let taskWillBeginDelayedRequest = taskWillBeginDelayedRequest {
            return await taskWillBeginDelayedRequest(self, session, task, request)
        } else {
            return (.continueLoading, nil)
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
        Task {
            await setError(error)
            session.finishTasksAndInvalidate()
            taskDidComplete?(self, session, task, error)
        }
    }

    
    // MARK: URLSessionDataDelegate
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        await setResponse(response)
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
        Task {
            await appendData(newData)
            dataTaskDidReceiveData?(self, session, dataTask, newData)
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) async -> CachedURLResponse? {
        await dataTaskWillCacheResponse?(self, session, dataTask, proposedResponse)
    }
    
    
    // MARK: URLSessionDownloadDelegate
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        Task {
            await setDownloadLocation(location)
            downloadTaskDidFinishDownloading?(self, session, downloadTask, location)
        }
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
