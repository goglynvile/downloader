//
//  Downloader.swift
//  Downloader
//
//  Created by Glynvile Satago on 26/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import Foundation
import UIKit

/// 'Downloader' is an easy to use library in downloading any type of files.
open class Downloader {
    
    /// A singleton object that will be returned everytime Downloader is used.
    public static let shared = Downloader()
    
    /// Initialize the OperationQueue
    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "OperationQueue.downloadManager"
        operationQueue.maxConcurrentOperationCount = 10
        return operationQueue
    }()
    
    
    /// Sets the size in MB of the shared URLCache
    ///
    /// - Parameters:
    ///  - sizeInMb: An int to set
    open class func setCacheSizeInMb(sizeInMb: Int) {
        let urlCache = URLCache(memoryCapacity: sizeInMb * 1024 * 1024, diskCapacity: 0, diskPath: nil)
        URLCache.shared = urlCache
    }
    
    // Mark: - Downloader operation methods
    
    /// Starts the download of the data. Adds 'DownloadData' to the OperationQueue.
    ///
    /// - Parameters:
    ///  - downloadData: A 'DownloadData' to be downloaded.
    open func startDownload(with downloadData: DownloadData) {
        let operation = BlockOperation {
            downloadData.start()
        }
        operation.name = downloadData.urlString
        operationQueue.addOperation(operation)
    }
    
    /// Starts the download of the array of data. Adds array of 'DownloadData' to the OperationQueue.
    ///
    /// - Parameters:
    ///  - downloadDataArray: An 'DownloadData' array to be downloaded.
    open func startDownloads(with downloadDataArray: [DownloadData]) {
        for downloadData in downloadDataArray {
            let operation = BlockOperation {
                downloadData.start()
            }
            operation.name = downloadData.urlString
            operationQueue.addOperation(operation)
        }
    }
    
    
    /// Cancel the download of the data. Cancels the operation.
    ///
    /// - Parameters:
    ///  - downloadData: A 'DownloadData' to be canceled.
    open func cancelDownload(for downloadData: DownloadData) -> Bool {
        
        let operation = operationQueue.operations.first { (operation) -> Bool in
            operation.name == downloadData.urlString
        }
        operation?.cancel()
        
        return downloadData.cancel()
    }
}

/// An extension to Data
public typealias DownloadedData = Data
public extension DownloadedData {

    // MARK: - Declaration of typealias
    
    typealias ReadableImage = UIImage
    typealias ReadableJSONDictionary = Dictionary<String, Any>
    typealias ReadableJSONArray = Array<Any>
    typealias ReadableVideoURL = URL
    
    // MARK: - Data to Readable format methods
    
    /// Returns the image object from reading the data.
    ///
    /// - Returns: A 'ReadableImage' converted from 'DownloadedData'
    func toImage() -> ReadableImage? {
        let image = UIImage(data: self)
        return image
    }
    
    /// Returns the JSON dictionary object from reading the data.
    ///
    /// - Returns: A 'ReadableJSONDictionary' converted from 'DownloadedData'
    func toJSONDictionary() -> ReadableJSONDictionary? {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: self, options: [])
            return jsonResponse as? Dictionary<String, Any>
        }
        catch {
            return nil
        }
        
    }
    
    /// Returns the JSON array object from reading the data.
    ///
    /// - Returns: A 'ReadableJSONArray' converted from 'DownloadedData'
    func toJSONArray() -> ReadableJSONArray? {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: self, options: [])
            return jsonResponse as? ReadableJSONArray
        }
        catch {
            return nil
        }
    }

    /// Returns the JSON array object from reading the data.
    ///
    /// - Parameters:
    ///  - urlString: The url string of the video to be downloaded.
    /// - Returns: A 'ReadableVideoURL' of the video in disk from 'DownloadedData'
    func toVideoUrl(urlString: String) -> ReadableVideoURL? {
        
        // get the url of the disk directory
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let videoURL = documentsURL.appendingPathComponent((urlString as NSString).lastPathComponent)
        
        //Check if the video is already in the disk
        if FileManager.default.fileExists(atPath: videoURL.path) {
            return videoURL
        }
        do {
            
            //write the video to the location
            try self.write(to: videoURL)
            
            //remove the cached video response
            if let url = URL(string: urlString)  {
                let urlRequest = URLRequest(url: url)
                URLCache.shared.removeCachedResponse(for: urlRequest)
            }
            return videoURL
        }
        catch {
            return nil
        }
    }
}

/// A class that manages the data to be downloaded.
public class DownloadData {
    
    // MARK: fileprivate properties
    fileprivate let urlString: String
    fileprivate var dataTask: URLSessionDataTask!
    
    // MARK: public properties
    public typealias completion = ((DownloadedData?, String?) -> Void)
    public var completionHandler: completion

    // MARK: Initializer methods
    public init(urlString: String, completionHandler: @escaping completion) {
        self.urlString = urlString
        self.completionHandler = completionHandler
    }

    // MARK: fileprivate methods

    /// Execute the download. Instantiate the 'dataTask' and begin the download.
    fileprivate func start() {
        
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
        
        if self.dataTask == nil {
            self.dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        self.completionHandler(nil, error?.localizedDescription )
                        return }

                self.completionHandler(dataResponse, nil)
            })
        }
        
        self.dataTask.resume()
    }
    
    /// Cancel the download. Remove the response from the shared Cache.
    ///
    /// Returns: Boolean if it is a success.
    fileprivate func cancel() -> Bool {
        
        if self.dataTask.state == URLSessionTask.State.running {
            self.dataTask?.cancel()
            self.removeFromCache()
        }
        return self.dataTask.state == URLSessionTask.State.canceling
    }
    
    // MARK: public methods

    /// Remove the response from the shared Cache.
    public func removeFromCache() {
        URLCache.shared.removeCachedResponse(for: self.dataTask)
    }
}


