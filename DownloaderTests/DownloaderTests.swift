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
        
        let downloadData = DownloadData(urlString: url) { (data, error) in
            
            XCTAssertNil(error, "Unexpected error occured: \(String(describing: error?.debugDescription))")
            XCTAssertNotNil(data, "No data returned.")
            
            let jsonArray = data?.toJSONArray()
            XCTAssertNotNil(jsonArray, "Not JSON format.")
            
            expect.fulfill()
        }
        
        Downloader.shared.startDownload(with: downloadData)
        
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, "Test timed out.")
        }
    }
    func testImageDownload() {
        let url = "https://images.unsplash.com/photo-1464550883968-cec281c19761"
        let expect = expectation(description: "Successfully fetched image")
        
        let downloadData = DownloadData(urlString: url) { (data, error) in
            XCTAssertNil(error, "Unexpected error occured: \(String(describing: error?.debugDescription))")
            XCTAssertNotNil(data, "No data returned.")
            
            let jsonArray = data?.toImage()
            XCTAssertNotNil(jsonArray, "Not correct image format.")
            
            expect.fulfill()
        }
        Downloader.shared.startDownload(with: downloadData)
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, "Test timed out.")
        }
    }
    
    func testCancelDownload() {
        let url = "https://images.unsplash.com/photo-1464550883968-cec281c19761"
        let expect = expectation(description: "Successfully fetched image")
        
        let downloadData = DownloadData(urlString: url) { (data, error) in
            
        }
        Downloader.shared.startDownload(with: downloadData)
        
        let success = Downloader.shared.cancelDownload(for: downloadData)
        
        XCTAssertTrue(success, "Did not able to cancel the download.")
        expect.fulfill()
        
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
