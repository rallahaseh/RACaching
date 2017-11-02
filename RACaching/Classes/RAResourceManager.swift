//
//  RAResourceManager.swift
//  Pods
//
//  Created by Rashed Al Lahaseh on 11/1/17.
//
//

import Foundation

/*
    RAResourceManager
    *******************************
    Loads all the resources you need from http/https.
 
    1. Checks where corresponding resource for a URL in cache using cacheManager, if the resource is not found
        it checks if already downloading by the downloadsManager.
    2. If the resource is not found then it creats resource and initialises download for that resource with adding
        observers for that resource
    3. If the resource is found in cache it sends the data back to the observer.
    4. If the resource is found in the downloadsManager then it adds the observer to the list of resource observer
    
    *******************************
    *   Note:                     *
    *******************************
    1. NSURLSessionConfiguration inputs added to set authentication and any other session related parameters.
    2. Asynchronous operations can be controlled using 
        maxOperationsCount  => maximum number of operations
        cacheResourcesCount => number of items in cache
        cacheMaxSize        => maximum number of cache (size limitation)
 */

open class RAResourceManager: NSObject, RADownloadsManagerDelegate {

    fileprivate var downloadsManager:RADownloadsManager!
    
    fileprivate var cacheManager:RACachingManager!
    
    // downloadsManager uses NSURLSessionConfiguration to download the data from a URL
    // Avoid authenication problems by set a details in configuration
    public init(configuration: URLSessionConfiguration?) {
        
        super.init()
        
        if let config = configuration {
            self.downloadsManager = RADownloadsManager.init(downloaderConfig: config, delegate: self)
        } else {
            let configuration = URLSessionConfiguration.default
            self.downloadsManager = RADownloadsManager.init(downloaderConfig: configuration, delegate: self)
        }
        
        cacheManager = RACachingManager.init()
        
        self.cacheResourcesCount    = 50
        self.maxOperationsCount     = 10
    }
    

    // Controls the concurrent operations that downloadsManager can use to download
    open var maxOperationsCount: Int {
        
        get{
            return self.downloadsManager.downloadQueue.maxConcurrentOperationCount
        }
        
        set(value){
            self.downloadsManager.downloadQueue.maxConcurrentOperationCount = value
        }
    }
    
    
    // Controls the resources count of storing cache
    open var cacheResourcesCount: Int {
        
        get{
            return self.cacheManager.cache.countLimit
        }
        set(value){
            self.cacheManager.setSizeLimit(value)
        }
    }
    
    
    // Controls the resources size of cache
    open var cacheMaxSize: Int {
        
        get{
            return self.cacheManager.cache.totalCostLimit
        }
        set(value){
            self.cacheManager.cache.totalCostLimit = value
        }
    }
    
    
    //doNeedfulIfResourceExists

    // Checks for a given urlString whether a resource exists with cacheManager or downloadsManager
    // if founded in cache it sends that data back using observer or add to the observer if founded in download queue.
    fileprivate func checkResourceExists(_ urlString: String,
                                         _ identifier: String,
                                         _ observer:RAURLObserverProtocol)-> Bool {
        
        var resourceFound = false
        
        if let resource = self.downloadsManager.downloadsInProgress[urlString] {
            resource.addObserver(identifier, observer: observer)
            resourceFound = true
        } else if let resource = self.cacheManager.getResource(urlString) {
            let data =  NSData.init(data: resource.data!) as Data
            DispatchQueue.main.async{
                observer.didFetchURLData(urlString, data: data, errorMessage: "")
            }
            resourceFound = true
        }
        
        return resourceFound
    }
    
    
    // urlString: check whether a resource exists or not to creates new resource if not
    // identifier: to add observers to a resource and delete it if object does not need data
    // observer: communicate the status of data fetch from Cache or Server
    open func getDataFor(_ urlString: String, withIdentifier identifier: String,
                                              withUrlObserver observer: RAURLObserverProtocol) {
        
        if let url = URL(string: urlString) {
            if !checkResourceExists(urlString, identifier, observer) {
                let resource = RAURLResource.init(urlRequest: URLRequest.init(url: url))
                resource.addObserver(identifier, observer: observer)
                self.downloadsManager.startDataTask(resource)
            }
        } else {
            DispatchQueue.main.async{
                observer.didFetchURLData(urlString,data: nil,errorMessage: "Improper url")
            }
        }
    }
    
    // Remove observer for a URL resource is no more needed
    open func cancelDataFor(_ urlString: String, withIdentifier identifier: String) {
        
        if let resource = self.downloadsManager.downloadsInProgress[urlString] {
            if let observer = resource.removeObserver(identifier) {
                let error = "Download is cancelled for URL: \(urlString)"
                DispatchQueue.main.async {
                    observer.didFetchURLData(urlString, data: nil, errorMessage: error)
                }
            }
            if(resource.observers.count == 0 ) {
                self.downloadsManager.cancelDataTask(resource)
            }
            self.downloadsManager.downloadsInProgress.removeValue(forKey: urlString)
        }
    }
    
    
    // urlRequest: for control the request by adding custom headrs or change the request method
    open func getDataForNSURLRequest(_ urlRequest: URLRequest, withIdentifier identifier: String,
                                                               withUrlObserver observer: RAURLObserverProtocol) {
        
        if let urlString = urlRequest.url?.absoluteString {
            if let resource = self.downloadsManager.downloadsInProgress[urlString] {
                resource.addObserver(identifier, observer: observer)
            } else {
                let resource = RAURLResource.init(urlRequest: urlRequest)
                resource.addObserver(identifier, observer: observer)
                self.downloadsManager.startDataTask(resource)
            }
        }
    }
    
    
    // Remove observer for a NSURLRequest is no more needed
    open func cancelDataForNSURLRequest(_ urlRequest:URLRequest, withIdentifier identifier:String)
    {
        if let urlString = urlRequest.url?.absoluteString
        {
            cancelDataFor(urlString, withIdentifier: identifier)
        }
        
    }
    
    // Fetching data from the Server and if the resource exists in cache, the new data overrites the resource data in cache
    open func getDataFromServer(_ urlString: String, withIdentifier identifier: String,
                                                     withUrlObserver observer: RAURLObserverProtocol) {
        
        if let url =  URL(string:urlString) {
            if let resource = self.downloadsManager.downloadsInProgress[urlString] {
                resource.addObserver(identifier, observer: observer)
                
            } else {
                let resource = RAURLResource.init(urlRequest: URLRequest.init(url: url))
                resource.addObserver(identifier, observer: observer)
                self.downloadsManager.startDataTask(resource)
            }
        } else {
            DispatchQueue.main.async{
                observer.didFetchURLData(urlString, data: nil, errorMessage: "Improper URL")
            }
        }
    }
    
    
    // Return data related to the urlString if found
    open func getDataFromCache(_ urlString:String)-> Data? {
        
        var cachedData:Data?
        if let resource = self.cacheManager.getResource(urlString) {
            cachedData =  NSData.init(data: resource.data!) as Data
        }
        return cachedData
    }
    
    
    // Clear Cache
    open func clearCache() {
        self.cacheManager.clearCache()
    }
    
    
    // Clear all pending downloads and the resources associated with URLs
    open func cancelAllDownloads()
    {
        self.downloadsManager.downloadQueue.cancelAllOperations()
        self.downloadsManager.downloadsInProgress.removeAll()
    }
}

extension RAResourceManager: URLSessionDelegate {
    
    func downloadComplete(_ resource:RAURLResource, errorMessage:String) {
        
        let urlString = (resource.urlRequest.url?.absoluteString)!
        if let data = resource.data, resource.state == .downloaded {
            var compressedData:Data!
            for (_,observer) in resource.observers {
                compressedData = observer.compressData?(urlString, data: data)
                if compressedData != nil && compressedData.count > 0 {
                    break
                }
            }
            
            if compressedData == nil {
                compressedData = data
            }
            
            var storeInCache = false
            for (_,observer) in resource.observers {
                if !storeInCache {
                    if observer.shouldStoreDataInCache == nil {
                        storeInCache = true
                    } else if observer.shouldStoreDataInCache!(urlString, data: data) {
                        storeInCache = true
                    }
                }
                observer.didFetchURLData(urlString,data:compressedData,errorMessage: errorMessage)
            }
            
            if(storeInCache) {
                resource.state =  .cached
                resource.data = compressedData
                self.cacheManager.addObject(resource)
            }
            
        } else {
            
            var msg = errorMessage
            if msg.isEmpty {
                msg = "Some internal error occured, did not downlaoded data for URL: \(urlString)"
            }
            
            for (_,observer) in resource.observers {
                observer.didFetchURLData(urlString, data: nil, errorMessage: msg)
            }
        }
        resource.observers.removeAll()
    }
}
