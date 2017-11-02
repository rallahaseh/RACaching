//
//  RACachingManager.swift
//  Pods
//
//  Created by Rashed Al Lahaseh on 11/1/17.
//
//

import Foundation

/*
    RACachingManager
    *******************************
    Manages cache for URLString, it uses NSCache which let the system free the memory when it is tight.
 
    LRUCacheArray
    *******************************
    Stands for <Least React Used Caches> and helps in implementing it.
*/
class RACachingManager: NSObject, NSCacheDelegate {
    
    var cache: NSCache <AnyObject, AnyObject>
    
    var LRUCacheArray: [String]

    override init() {
        
        self.cache = NSCache.init()
        self.LRUCacheArray = [String]()
        super.init()
        self.cache.delegate = self
    }
    
    // Finds out whether the resource of the URL exists or not.
    func getResource(_ urlString:String)-> RAURLResource? {
        
        if let resource = self.cache.object(forKey: urlString as AnyObject) as? RAURLResource {
            if(self.LRUCacheArray.contains(urlString)) {
                let index = self.LRUCacheArray.index(of: urlString)
                self.LRUCacheArray.remove(at: index!)
                self.LRUCacheArray.insert(urlString, at: 0)
            }
            return resource
        }
        
        return nil
    }
    
    // Adding resource to the Cache, but if the limit exceeds the last element added to the Cache will be deleted.
    func addObject(_ resource: RAURLResource) {
        
        let urlString = resource.urlRequest.url?.absoluteString
        if let resourceCache = getResource(urlString!), resource.data != nil {
            resourceCache.data = resource.data
        } else if getResource(urlString!) == nil {
            // reached the limit
            if self.LRUCacheArray.count == self.cache.countLimit {
                let url = self.LRUCacheArray.removeLast()
                self.cache.removeObject(forKey: url as AnyObject)
            }
            
            self.cache.setObject(resource, forKey: urlString! as AnyObject)
            self.LRUCacheArray.insert(urlString!, at: 0)
        }
    }
    
    // Removes an object from cache and update LRUCacheArray(Least React Used Cache Array)
    func removeObject(_ resource: RAURLResource) {
        
        let urlString = resource.urlRequest.url?.absoluteString
        self.cache.removeObject(forKey: urlString! as AnyObject)
        if(self.LRUCacheArray.contains(urlString!)) {
            let index = self.LRUCacheArray.index(of: urlString!)
            self.LRUCacheArray.remove(at: index!)
        }
    }
    
    // Remove all objects from Cache and update LRUCacheArray(Least React Used Cache Array)
    func clearCache() {
        
        self.cache.removeAllObjects()
        self.LRUCacheArray.removeAll()
    }
    
    // Set a size limit to the Cache and LRUCacheArray(Least React Used Cache Array).
    // The count entered will be the new size of the Cache with respective number of elements.
    func setSizeLimit(_ count: Int) {
        
        var size = count
        while(self.LRUCacheArray.count > size) {
            let url = self.LRUCacheArray.removeLast()
            self.cache.removeObject(forKey: url as AnyObject)
            size = size - 1
        }
        
        self.cache.countLimit = count
    }
    
    // When the system clears element from Cache this method is called with deleted Object 
    // and update LRUCacheArray(Least React Used Cache Array).
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject object: Any) {
        
        if object is RAURLResource {
            let resource: RAURLResource = object as! RAURLResource
            let urlString = resource.urlRequest.url?.absoluteString
            if self.LRUCacheArray.contains(urlString!) {
                let index = self.LRUCacheArray.index(of: urlString!)
                self.LRUCacheArray.remove(at: index!)
            }
        }
    }

}
