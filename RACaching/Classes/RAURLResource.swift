//
//  RAURLResource.swift
//  Pods
//
//  Created by Rashed Al Lahaseh on 11/1/17.
//
//

import Foundation

enum URLResourceState {
    case new
    case isDownloading
    case downloaded
    case failed
    case cancelled
    case cached
}

/*
    RAURLResource
    *******************************
    Stores all the data related to a URL, alse includes information about the observing resource.
 */
class RAURLResource: NSObject {
    
    let urlRequest: URLRequest
    
    var data: Data?
    
    var state: URLResourceState = .new
    
    var dataTask: URLSessionDataTask?
    
    var resumeData = NSMutableData()
    
    var observers = [String:RAURLObserverProtocol]()
    
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
    /*
        addObserver
        *******************************
        Sends information about the data to observer once the download manager finish the operation
     */
    func addObserver(_ identifier:String, observer:RAURLObserverProtocol) {
        observers[identifier] = observer
    }
    
    
    
    /*
        removeObserver
        *******************************
        When the observer no longer needs resource then this method will be called using the 
        same identifer used while creating.
     */
    func removeObserver(_ identifer:String)-> RAURLObserverProtocol? {
        let observer =  observers.removeValue(forKey: identifer)
        return observer
    }
}
