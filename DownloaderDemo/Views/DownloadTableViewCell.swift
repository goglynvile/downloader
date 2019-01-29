//
//  DownloadTableViewCell.swift
//  Downloader
//
//  Created by Glynvile Satago on 27/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import UIKit
import Downloader

class DownloadTableViewCell: UITableViewCell {

    @IBOutlet weak var imgViewDownload: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblError: UILabel!
    
    var downloadData: DownloadData?
    
    var imageUrl: String? {
        didSet {
             self.clickedCancel(self.btnCancel)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func clickedCancel(_ sender: Any) {
        
        self.lblError.text = ""
        

        if btnCancel.titleLabel?.text == "Cancel" {
            //cancel the downloading process
            guard let downloadData = downloadData else { return }
            if DownloadManager.shared.cancelDownload(for: downloadData) {
                OperationQueue.main.addOperation {
                    //update UI when success
                    Utility.animateImageView(imageView: self.imgViewDownload, with: UIImage(named: "placeholder"))
                    self.activityView.stopAnimating()
                    self.btnCancel.setTitle("Download", for: .normal)
                }
            }
            else {
                //when cancelling returns error
            }
            
        }
        else if btnCancel.titleLabel?.text == "Remove" {
            //remove the image from memory and UI
            self.btnCancel.setTitle("Download", for: .normal)
            Utility.animateImageView(imageView: self.imgViewDownload, with: UIImage(named: "placeholder"))
            
            //uncache
            guard let imageUrl = imageUrl else { return }
            
            Downloader.shared.removeCacheForUrl(urlString: imageUrl)
            
        }
        else if btnCancel.titleLabel?.text == "Download" || btnCancel.titleLabel?.text == "Try Again" {
            
            //change UI state
            self.activityView.startAnimating()
            self.imgViewDownload.image = nil
            self.btnCancel.setTitle("Cancel", for: .normal)
            
            guard let imageUrl = imageUrl else { return }
            downloadData = DownloadData(urlString: imageUrl) { (data, error) in
                guard let data = data, error == nil else {
                    //update UI when error
                    OperationQueue.main.addOperation {
                        self.activityView.stopAnimating()
                        self.btnCancel.setTitle("Try Again", for: .normal)
                        self.lblError.text = error!
                        Utility.animateImageView(imageView: self.imgViewDownload, with: UIImage(named: "placeholder"))
                    }
                    return
                }
                //update UI when success
                OperationQueue.main.addOperation {
                    self.activityView.stopAnimating()
                    self.btnCancel.setTitle("Remove", for: .normal)
                    Utility.animateImageView(imageView: self.imgViewDownload, with: data.toImage())
                }
            }
            DownloadManager.shared.startDownload(with: downloadData!)
          
        }
    }
    
}
