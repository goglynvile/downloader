//
//  ProfileViewController.swift
//  Downloader
//
//  Created by Glynvile Satago on 27/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import UIKit
import Downloader

class CancelableDownloadViewController: UIViewController {

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var imgViewSample: UIImageView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblError: UILabel!
    
    var downloadData: DownloadData?
    
    //let sampleUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Pizigani_1367_Chart_10MB.jpg/1600px-Pizigani_1367_Chart_10MB.jpg"
    
    //larger image
    let sampleUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Clocktower_Panorama_20080622_20mb.jpg/1591px-Clocktower_Panorama_20080622_20mb.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Cancelable Download"

        // Do any additional setup after loading the view.
        self.clickedCancel(self.btnCancel)
    }

    @IBAction func clickedCancel(_ sender: Any) {
        
        lblError.text = ""
        if btnCancel.titleLabel?.text == "Cancel" {
            //cancel the downloading process
            guard let downloadData = downloadData else { return }
            
            DownloadManager.shared.cancelDownload(for: downloadData)
            /*
            Downloader.shared.cancel(urlString: sampleUrl, identifier: taskIdentifier) { (success) in
                if success {
                    OperationQueue.main.addOperation {
                        //success cancelling change UI state
                        Utility.animateImageView(imageView: self.imgViewSample, with: UIImage(named: "placeholder"))
                        self.activityView.stopAnimating()
                        self.btnCancel.setTitle("Download", for: .normal)
                    }
                }
            }
             */
 
        }
        else if btnCancel.titleLabel?.text == "Remove" {
            //remove the image from memory and UI
            self.btnCancel.setTitle("Download", for: .normal)
            Utility.animateImageView(imageView: self.imgViewSample, with: UIImage(named: "placeholder"))
            
            //uncache
            Downloader.shared.removeCacheForUrl(urlString: sampleUrl)
        }
        else if btnCancel.titleLabel?.text == "Download" {
            
            //change UI state
            self.activityView.startAnimating()
            self.imgViewSample.image = nil
            self.btnCancel.setTitle("Cancel", for: .normal)
            
            let downloadData = DownloadData(urlString: sampleUrl) { (data, error) in
                guard let data = data, error == nil else {
                    // update UI with error
                    OperationQueue.main.addOperation {
                        self.activityView.stopAnimating()
                        self.btnCancel.setTitle("Try Again", for: .normal)
                        self.lblError.text = error!
                        Utility.animateImageView(imageView: self.imgViewSample, with: UIImage(named: "placeholder"))
                    }
                    return
                }
                OperationQueue.main.addOperation {
                    self.activityView.stopAnimating()
                    self.btnCancel.setTitle("Remove", for: .normal)
                    Utility.animateImageView(imageView: self.imgViewSample, with: data.toImage())
                }
            }
            
            DownloadManager.shared.startDownload(with: downloadData)
            
            /*
            downloadTaskIdentifier = Downloader.shared.cancelableDownload(urlString: sampleUrl) { (data, error) in
                if let error = error {
                    OperationQueue.main.addOperation {
                        self.activityView.stopAnimating()
                        self.btnCancel.setTitle("Try Again", for: .normal)
                        self.lblError.text = error
                        Utility.animateImageView(imageView: self.imgViewSample, with: UIImage(named: "placeholder"))
                    }
                }
                else {
                    guard let data = data else { return }
                    
                    OperationQueue.main.addOperation {
                        self.activityView.stopAnimating()
                        self.btnCancel.setTitle("Remove", for: .normal)
                        Utility.animateImageView(imageView: self.imgViewSample, with: data.toImage())
                    }
                }
            }
             */
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
