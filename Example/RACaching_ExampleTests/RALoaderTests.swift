//
//  RALoaderTests.swift
//  RACaching
//
//  Created by Rashed Al Lahaseh on 11/2/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest


class RALoaderTests: XCTestCase {
    
    var pictures:NSDictionary!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        pictures = getPhotos()
        
        print("________________");
        print("test case started for \(String(describing: self.name))")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        print("test case ended for \(String(describing: self.name))")
        print("________________");
        print(" ");
    }
    
    func getPhotos() -> NSDictionary{
        let dictionary = NSMutableDictionary()
        dictionary.setValue("https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Letter_c.svg/1200px-Letter_c.svg.png", forKey: "C")
        dictionary.setValue("https://isocpp.org/files/img/cpp_logo.png", forKey: "C++")
        dictionary.setValue("https://pluralsight.imgix.net/paths/path-icons/csharp-e7b8fcd4ce.png", forKey: "C#")
        dictionary.setValue("http://www.ondeweb.in/wp-content/uploads/2013/02/Masterclass-in-HTML5-and-0061-1.jpg", forKey: "HTML")
        dictionary.setValue("https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/PHP-logo.svg/1200px-PHP-logo.svg.png", forKey: "PHP")
        dictionary.setValue("https://images.contentful.com/fo9twyrwpveg/6LpZ8WIScMKQsAi0EoosMy/63ff0a4b40687a1ca58f7e78c970a4c5/Objective-c-logo.png", forKey: "Objective-C")
        dictionary.setValue("https://blog.tomasmahrik.com/wp-content/uploads/2015/06/swift.jpg", forKey: "Swift")
        dictionary.setValue("https://pluralsight.imgix.net/paths/python-7be70baaac.png", forKey: "Python")
        
        return dictionary
        /*
        var returnedDictionary = NSDictionary()
        let url: String = "http://rashed.site.swiftengine.net/images.ssp/"
        let request = URLRequest(url: NSURL(string: url)! as URL)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {(data, response, error) in
            if error != nil {
                print("API-Request-Error:\n\(String(describing: error))")
            } else {
                let requestObjects = try? JSONSerialization.jsonObject(with: data!, options: [])
                DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.async {
                        returnedDictionary = requestObjects as! NSDictionary
                    }
                }
            }
        }
        task.resume()
        
        return returnedDictionary
         */
    }
}
