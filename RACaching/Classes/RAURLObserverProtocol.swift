//
//  RAURLObserverProtocol.swift
//  Pods
//
//  Created by Rashed Al Lahaseh on 11/1/17.
//
//

import Foundation

/*
    RAURLObserverProtocol
    *******************************
    The protocol specifies the methods that URLResourceManager
    Responding to classes that requesting a resource

 */

@objc public protocol RAURLObserverProtocol:NSObjectProtocol {
    
    /*
        didFetchURLData
        *******************************
        1. Called when the resource data available for an URL either from Server or from Cache.
        2. Used to catch errors while fetching data for the Resource.
    */
    func didFetchURLData(_ urlString:String, data:Data?, errorMessage:String)
    
    
    
    /*
        didFetchUrlData
        *******************************
        1. For compressions on the data received from Server before caching implement this method.
        2. urlString data is passed through data and expects the data returned by type.
        3. Single compression technique used for an URL
        
        *******************************
        *   Note:                     *
        *******************************
        If your using diffrenet compression techniques on multiple classes then,
        this Method will not be able to guarantee which one it will implement.
     */
    @objc optional func compressData(_ urlString:String, data:Data) -> Data
    
    
    
    /*
        shouldStoreDataInCache
        *******************************
        Bool expression for caching data for a particular URL.
        True -> use cache | False -> do not use cache

        *******************************
        *   Note:                     *
        *******************************
        If there is multiple classes have requested the same URL data, then all classes should implement the method
        and return false to avoid storing data in Cache.
    */
    @objc optional func shouldStoreDataInCache(_ urlString:String, data:Data) -> Bool
    
    
    
}
