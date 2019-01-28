//
//  DownloaderTests.swift
//  DownloaderTests
//
//  Created by Glynvile Satago on 28/01/2019.
//  Copyright © 2019 glynvile satago. All rights reserved.
//

import XCTest
@testable import Downloader

class DownloaderTests: XCTestCase {

    func testJSONDownload()  {
        let url = "http://pastebin.com/raw/r1CN6JxN"
        let expect = expectation(description: "Successfully fetched JSON data.")
        
        Downloader.shared.download(urlString: url) { (data, error) in
            XCTAssertNil(error, "Unexpected error occured: \(String(describing: error?.debugDescription))")
            XCTAssertNotNil(data, "No data returned.")
            
            let jsonArray = data?.toJSONArray()
            XCTAssertNotNil(jsonArray, "Not JSON format.")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, "Test timed out.")
        }
    }
    func testImageDownload() {
        let url = "https://images.unsplash.com/photo-1464550883968-cec281c19761"
        let expect = expectation(description: "Successfully fetched image")
        
        Downloader.shared.download(urlString: url) { (data, error) in
            XCTAssertNil(error, "Unexpected error occured: \(String(describing: error?.debugDescription))")
            XCTAssertNotNil(data, "No data returned.")
            
            let jsonArray = data?.toImage()
            XCTAssertNotNil(jsonArray, "Not correct image format.")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, "Test timed out.")
        }
    }
    
    func testCancelDownload() {
        let url = "https://images.unsplash.com/photo-1464550883968-cec281c19761"
        let expect = expectation(description: "Successfully fetched image")
        
        let identifier = Downloader.shared.cancelableDownload(urlString: url) { (data, error) in
            
            
        }
        Downloader.shared.cancel(urlString: url, identifier: identifier!) { (success) in
            
            XCTAssertTrue(success, "Did not able to cancel the download.")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, "Test timed out.")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
