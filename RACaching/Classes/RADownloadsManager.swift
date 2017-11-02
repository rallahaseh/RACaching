//
//  RADownloadsManager.swift
//  Pods
//
//  Created by Rashed Al Lahaseh on 11/1/17.
//
//

import Foundation

/*
    RADownloadsManagerDelegate
    *******************************
    Collects info from (NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate)
     and sends back to implemementer the download information of urlString
 */
protocol RADownloadsManagerDelegate {
    func downloadComplete(_ resource:RAURLResource, errorMessage:String)
}

/*
    RADownloadsManager
    *******************************
    Fetches all types of data from the server and controls the download tasks 
     and the operations can be controlled through downloadQueue
 */
class RADownloadsManager: NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    lazy var downloadsInProgress = [String:RAURLResource]()
    
    let queueName: String? = "download_queue"
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = self.queueName
        return queue
    }()
    
    let downloaderConfig: URLSessionConfiguration
    
    let delegate: RADownloadsManagerDelegate
    
    // Init with session info from downloaderConfig
    init(downloaderConfig: URLSessionConfiguration, delegate: RADownloadsManagerDelegate) {
        
        self.downloaderConfig = downloaderConfig
        self.delegate = delegate
    }
    
    // Init download operations for urlString and pushes the resource to downloadsInProgress
    // for a access to the status of the resource
    func startDataTask(_ resource: RAURLResource) {
        
        let session = Foundation.URLSession(configuration: downloaderConfig, delegate: self, delegateQueue: downloadQueue)
        resource.dataTask = session.dataTask(with: resource.urlRequest)
        downloadsInProgress[(resource.urlRequest.url?.absoluteString)!] = resource
        resource.dataTask!.resume()
        resource.state = .isDownloading
    }
    
    
    // Cancel downloading from server and notifies the delegate
    func cancelDataTask(_ resource: RAURLResource) {
        
        if let dataTask = resource.dataTask {
            dataTask.cancel()
            resource.state = .cancelled
            if let urlString  = resource.urlRequest.url?.absoluteString {
                downloadsInProgress.removeValue(forKey: urlString)
            }
        }
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        let urlString = dataTask.originalRequest?.url?.absoluteString
        if let resource = downloadsInProgress[urlString!] {
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else
            {
                let error = "API call failed with status code: \(String(describing: (response as? HTTPURLResponse)?.statusCode)) for URL: \(urlString ?? "")"
                dataTask.cancel()
                resource.resumeData = NSMutableData()
                resource.state = .failed
                downloadsInProgress.removeValue(forKey: urlString!)
                self.delegate.downloadComplete(resource, errorMessage:error)
                
                return
            }
            completionHandler(Foundation.URLSession.ResponseDisposition.allow)
        } else {
            // Stop Download
            dataTask.cancel()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let urlString = task.originalRequest?.url?.absoluteString
        if let resource = downloadsInProgress[urlString!] {
            downloadsInProgress.removeValue(forKey: urlString!)
            if(error == nil) {
                resource.data = NSData.init(data: resource.resumeData as Data) as Data as Data
                resource.resumeData = NSMutableData()
                resource.state = .downloaded
                self.delegate.downloadComplete(resource, errorMessage: "")
            } else {
                resource.resumeData = NSMutableData()
                resource.state = .failed
                let error = "API call failed with internal error for URL: \(urlString ?? "")"
                self.delegate.downloadComplete(resource, errorMessage: error)
            }
        }
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        let urlString = dataTask.originalRequest?.url?.absoluteString
        if let resource = downloadsInProgress[urlString!] {
            resource.resumeData.append(data)
        } else {
            dataTask.cancel()
        }
    }
}
