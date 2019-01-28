//
//  FetchedData.swift
//  Downloader
//
//  Created by Glynvile Satago on 26/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import Foundation
import UIKit

public typealias ReadableData = Data
public extension ReadableData {
    /*
    func toImage() -> UIImage? {
        let image = UIImage(data: self)
        return image
    }
    func toJSONDictionary() -> Dictionary<String, Any>? {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: self, options: [])
            return jsonResponse as? Dictionary<String, Any>
        }
        catch {
            return nil
        }
        
    }
    func toJSONArray() -> Array<Any>? {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: self, options: [])
            return jsonResponse as? Array<Any>
        }
        catch {
            return nil
        }
    }
    func toXML() {
        
    }
    func toVideoUrl(urlString: String) -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let videoURL = documentsURL.appendingPathComponent((urlString as NSString).lastPathComponent)
    
        if FileManager.default.fileExists(atPath: videoURL.path) {
            print("check if the url existed: \(videoURL.path)")
            return videoURL
        }
        do {
            try self.write(to: videoURL)
            Downloader.shared.removeCacheForUrl(urlString: urlString)
            return videoURL
        }
        catch {
            return nil
        }
    }
     */
    
    
}
//class Session {
//
//    let shared: URLSession
//
//    init() {
//        shared = URLSession(configuration: .default)
//    }
//}
public typealias DownloadedData = Data
public extension DownloadedData {

    typealias ReadableImage = UIImage
    typealias ReadableJSONDictionary = Dictionary<String, Any>
    typealias ReadableJSONArray = Array<Any>
    typealias ReadableVideoURL = URL
    
    
    func toImage() -> ReadableImage? {
        let image = UIImage(data: self)
        return image
    }
    func toJSONDictionary() -> ReadableJSONDictionary? {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: self, options: [])
            return jsonResponse as? Dictionary<String, Any>
        }
        catch {
            return nil
        }
        
    }
    func toJSONArray() -> ReadableJSONArray? {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: self, options: [])
            return jsonResponse as? ReadableJSONArray
        }
        catch {
            return nil
        }
    }
    func toXML() {
        
    }
    func toVideoUrl(urlString: String) -> ReadableVideoURL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let videoURL = documentsURL.appendingPathComponent((urlString as NSString).lastPathComponent)
        
        if FileManager.default.fileExists(atPath: videoURL.path) {
            print("check if the url existed: \(videoURL.path)")
            return videoURL
        }
        do {
            try self.write(to: videoURL)
            Downloader.shared.removeCacheForUrl(urlString: urlString)
            return videoURL
        }
        catch {
            return nil
        }
    }
}

public typealias DownloadedImage = DownloadedData

public class DownloadData {
    
    let urlString: String
    var dataTask: URLSessionDataTask!
    public typealias completion = ((DownloadedData?, String?) -> Void)
    var completionHandler: completion
    //var data: DownloadedData?
    
//    func result<T>() -> T? {
//        return nil
//    }
    
    public init(urlString: String, completionHandler: @escaping completion) {
        self.urlString = urlString
        self.completionHandler = completionHandler
    }

    func start() {
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
        self.dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    self.completionHandler(nil, error?.localizedDescription )
                    return }
            print("downloaded data: \(data), error: \(error)")
            self.completionHandler(dataResponse, nil)
        })
        self.dataTask.resume()
    }
    func cancel() {
        self.dataTask?.cancel()
    }
}

open class DownloadManager {
    
    public static let shared = DownloadManager()
    
    lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        return operationQueue
    }()
    
    open func startDownloads(with downloadDataArray:[DownloadData]) {

        for downloadData in downloadDataArray {
            operationQueue.addOperation {
                downloadData.start()
            }
        }
    }
    open func startDownload(with downloadData: DownloadData) {
        operationQueue.addOperation {
            downloadData.start()
        }
    }
    open func cancelDownload(for downloadData: DownloadData) {
        downloadData.cancel()
        for operation in operationQueue.operations {
            print("operation: \(operation)")
        }
    }
    open func cancelDownloads(for downloadDataArray: [DownloadData]) {
        for downloadData in downloadDataArray {
            downloadData.cancel()
        }
    }
}
open class Downloader {
    public static let shared = Downloader()
    
    // to be called in AppDelegate
    open class func setCacheSizeInMb(sizeInMb: Int) {
        
        //set cache
        //500 * 1024 * 1024 500Mb
        let urlCache = URLCache(memoryCapacity: sizeInMb * 1024 * 1024, diskCapacity: 0, diskPath: nil)
        
        URLCache.shared = urlCache
    }
    
    open func download(urlString: String, completion: @escaping (_ result: ReadableData?, _ error: String?) -> Void ) {
        _ = self.cancelableDownload(urlString: urlString, completion: completion)
        /*
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            print("response: \(response), error: \(error?.localizedDescription), result: \(data)")
            //check the file type
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    completion(nil, error?.localizedDescription ?? "Response Error")
                    return }
            
            completion(dataResponse, nil)
        }
        task.resume()
         */
    }
    open func cancelableDownload(urlString: String, completion: @escaping (_ result: ReadableData?, _ error: String?) -> Void ) -> Int? {
        guard let url = URL(string: urlString) else { return nil }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    completion(nil, error?.localizedDescription)
                    return }

            completion(dataResponse, nil)
        }
        print("taskDescription: \(task.taskDescription), identifier: \(task.taskIdentifier)")
        task.resume()
        
        return task.taskIdentifier
    }
    open func cancel(urlString: String, identifier: Int, completion: @escaping (_ success: Bool) -> Void ) {

        URLSession.shared.getAllTasks { (tasks) in
            let task = tasks.last(where: { (task) -> Bool in
                print("task.url : \(task.currentRequest?.url?.absoluteString) == urlString: \(urlString), identifier: \(identifier)")
                return task.currentRequest?.url?.absoluteString == urlString && task.taskIdentifier == identifier
            })
            
            if task != nil {
                if task?.state == URLSessionTask.State.running {
                    task!.cancel()
                    completion(true)
                    print("Successfully canceled the download.")
                }
               
            }
            else {
               completion(false)
            
            }
        }
    }
    open func removeCacheForUrl(urlString: String) {
        print("Removing cache for : \(urlString), current memory size: \(URLCache.shared.currentMemoryUsage)")
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest(url: url)
        URLCache.shared.removeCachedResponse(for: urlRequest)
        print("Successfully removed the cache. New Memory size is : \(URLCache.shared.currentMemoryUsage)")
    }
}
