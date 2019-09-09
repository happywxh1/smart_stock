//
//  DownloadManager.swift
//  SmartStock
//
//  Created by Xiaohong Wang on 9/8/19.
//  Copyright © 2019 project.stock.com.xiaohong. All rights reserved.
//

import Foundation

/** https://stackoverflow.com/questions/32322386/how-to-download-multiple-files-sequentially-using-nsurlsession-downloadtask-in-s **/

/// Asynchronous operation base class
///
/// This is abstract to class performs all of the necessary KVN of `isFinished` and
/// `isExecuting` for a concurrent `Operation` subclass. You can subclass this and
/// implement asynchronous operations. All you must do is:
///
/// - override `main()` with the tasks that initiate the asynchronous task;
///
/// - call `completeOperation()` function when the asynchronous task is done;
///
/// - optionally, periodically check `self.cancelled` status, performing any clean-up
///   necessary and then ensuring that `finish()` is called; or
///   override `cancel` method, calling `super.cancel()` and then cleaning-up
///   and ensuring `finish()` is called.

class AsynchronousOperation: Operation {
    
    /// State for this operation.
    
    @objc private enum OperationState: Int {
        case ready
        case executing
        case finished
    }
    
    /// Concurrent queue for synchronizing access to `state`.
    
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".rw.state", attributes: .concurrent)
    
    /// Private backing stored property for `state`.
    
    private var rawState: OperationState = .ready
    
    /// The state of the operation
    
    @objc private dynamic var state: OperationState {
        get { return stateQueue.sync { rawState } }
        set { stateQueue.sync(flags: .barrier) { rawState = newValue } }
    }
    
    // MARK: - Various `Operation` properties
    
    open         override var isReady:        Bool { return state == .ready && super.isReady }
    public final override var isExecuting:    Bool { return state == .executing }
    public final override var isFinished:     Bool { return state == .finished }
    
    // KVN for dependent properties
    
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady", "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(state)]
        }
        
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    // Start
    
    public final override func start() {
        if isCancelled {
            finish()
            return
        }
        state = .executing
        main()
    }
    
    /// Subclasses must implement this to perform their work and they must not call `super`. The default implementation of this function throws an exception.
    
    open override func main() {
        fatalError("Subclasses must implement `main`.")
    }
    
    /// Call this function to finish an operation that is currently executing
    
    public final func finish() {
        if !isFinished { state = .finished }
    }
}

/// Asynchronous Operation subclass for downloading

typealias completionHandler = (Data?, URLResponse?, Error?) -> Void

class DownloadOperation : AsynchronousOperation {
    var task: URLSessionTask!
    
    init(session: URLSession, url: URL, completionHandler: @escaping completionHandler) {
        super.init()
        
        task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            defer { self.finish() }
            completionHandler(data, response, error)
        })
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    override func main() {
        task.resume()
    }
}

class DownloadManager: NSObject {
    /// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
    
    fileprivate var tasks = Set<URL>()

    /// Serial OperationQueue for downloads
    
    private let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "download"
        _queue.maxConcurrentOperationCount = 3
        return _queue
    }()
    
    lazy var session: URLSession = {
        return URLSession(configuration: .default)
    }()
    
    func queueDownload(_ url: URL, completionHandler: @escaping completionHandler) {
        if tasks.contains(url){
            return
        }
        tasks.insert(url)
        let operation = DownloadOperation(session: session, url: url, completionHandler:{ (data, response, error) in
            self.tasks.remove(url)
            completionHandler(data, response, error)
        })
        queue.addOperation(operation)
    }
    
    /// Cancel all queued operations
    
    func cancelAll() {
        queue.cancelAllOperations()
    }

}
