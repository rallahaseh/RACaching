//
//  RADownloadResorucesTest.swift
//  RACaching
//
//  Created by Rashed Al Lahaseh on 11/2/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest

@testable import RACaching

class RADownloadResorucesTest: RALoaderTests, RAURLObserverProtocol {
    
    var countDowloaded  = 0
    
    var countFailed     = 0
    
    var asyncExpectation:XCTestExpectation!
    
    var resourceManager:RAResourceManager!
    
    override var name: String {
        get{
            return "RADownloadResorucesTest"
        }
    }

    override func setUp() {
        
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        resourceManager                     = RAResourceManager.init(configuration: nil)
        resourceManager.maxOperationsCount  = 2
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
    
    func testDownloads() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        asyncExpectation    = expectation(description: "RADownloadResorucesTest")
        countDowloaded      = 0
        countFailed         = 0
        
        for i in 0..<5 {
            
            let rowKey = pictures.allKeys[i] as! String
            
            let url = (pictures.value(forKey: rowKey) as? String)!
            
            XCTAssertNotNil(url, "URL shouldn't be nil")
            
            print("Download for \(rowKey) = \(url) started")
        
            self.resourceManager.getDataFor(url, withIdentifier: "testingCase", withUrlObserver: self)
        }
        
        self.waitForExpectations(timeout: 100) { error in
            if(error != nil ) {
                XCTFail("Time out, download is taking too much time");
            } else {
                XCTAssert(true);
            }
        }
    }
    
    func didFetchURLData(_ urlString: String, data: Data?, errorMessage: String) {
        
        print("Download for \(urlString) ended with data length \(data?.count ?? 0) and with error \(errorMessage) ");
        
        if (data?.count)! > 0 {
            countDowloaded  += 1
        } else {
            countFailed     += 1
        }
        
        print("Downloads Count: \(countDowloaded), Falied Count: \(countFailed)");
        
        if countDowloaded + countFailed == 5 {
            if countDowloaded == 4 && countFailed == 1 {
                XCTAssert(true, "Passed")
            } else {
                XCTFail("Problem with input source URLs or RAResourceManager, one of the downloads should fail")
            }
            
            print("Test Passed")
            asyncExpectation.fulfill()
        }
    }
}
