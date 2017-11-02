//
//  RACancelDownloadingResorucesTest.swift
//  RACaching
//
//  Created by Rashed Al Lahaseh on 11/2/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest

@testable import RACaching

class RACancelDownloadingResorucesTest: RALoaderTests, RAURLObserverProtocol {

    var countCancelled      = 0
    
    var countFinished       = 0
    
    var asyncExpectation:XCTestExpectation!
    
    var resourceManager:RAResourceManager!
    
    override var name: String {
        get{
            return "RACancelDownloadingResorucesTest"
        }
    }

    override func setUp() {
        
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        resourceManager                     = RAResourceManager.init(configuration: nil)
        resourceManager.maxOperationsCount  = 1
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCancelDownload() {
        
        asyncExpectation    = expectation(description: "RACancelDownloadingResorucesTest")
        countFinished       = 0
        countCancelled      = 0
        
        for i in 0..<5 {
            
            let rowKey = pictures.allKeys[i] as! String
            
            let url = (pictures.value(forKey: rowKey) as? String)!
            
            XCTAssertNotNil(url, "URL shouldn't be nil")
            
            print("Download for \(rowKey) = \(url) started")
            
            self.resourceManager.getDataFor(url, withIdentifier: "testingCase", withUrlObserver: self)
            
            self.resourceManager.cancelDataFor(url, withIdentifier: "testingCase")
        }
        
        self.waitForExpectations(timeout: 30) { error in
            if(error != nil ) {
                XCTFail("Time out, download is taking too much time");
            } else {
                XCTAssert(true);
            }
        }
    }
    
    func didFetchURLData(_ urlString: String, data: Data?, errorMessage: String) {
        
        print("Download for \(urlString) ended with data length \(data?.count ?? 0) and with error \(errorMessage) ");
        
        countFinished       += 1
        if errorMessage.contains("cancelled") {
            countCancelled  += 1
        }
        
        print("Finished Downloads Count: \(countFinished), Cancelled Downloads Count: \(countCancelled)");
        
        
        if countFinished == 5 {
            if countCancelled > 1 {
                XCTAssert(true, "Passed")
            } else {
                XCTFail("One of the downloads should canceled")
            }
            
            print("Test Passed")
            asyncExpectation.fulfill()
        }
    }
}
