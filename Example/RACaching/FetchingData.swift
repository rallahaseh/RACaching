//
//  FetchingData.swift
//  RACaching
//
//  Created by Rashed Al Lahaseh on 11/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class FetchingData {
    
    let url: String = "http://pastebin.com/raw/wgkJgazE"
    
    func loadPinterestData(completion:@escaping (_ photos: NSDictionary?, _ error:NSError?)->()) {
        let request = URLRequest(url: NSURL(string: url)! as URL)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {(data, response, error) in
            if error != nil {
                print("API-Request-Error:\n\(String(describing: error))")
            } else {
                let requestObjects = try? JSONSerialization.jsonObject(with: data!, options: [])
                let returnedArray = requestObjects as! NSArray
                let photosArray = NSMutableArray()
                for value in returnedArray {
                    let object = value as! NSDictionary
                    let photos = object["urls"] as! [String:String]
                    let regular_photo_url = photos["regular"]!
                    photosArray.add(regular_photo_url)
                }
                DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.async {
                        let pinterestPhotos = NSMutableDictionary()
                        for photo in photosArray {
                            let object = photo as! String
                            let name = "\(object.hashValue)"
                            let url  = object
                            pinterestPhotos.setValue(url, forKey: name)
                        }
                        completion(pinterestPhotos, nil)
                    }
                }
            }
        }
        task.resume()
    }
}
