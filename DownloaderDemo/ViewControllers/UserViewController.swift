//
//  UserViewController.swift
//  DownloaderDemo
//
//  Created by Glynvile Satago on 29/01/2019.
//  Copyright © 2019 glynvile satago. All rights reserved.
//

import UIKit
import Downloader

class UserViewController: UIViewController {

    @IBOutlet weak var imgViewUser: UIImageView!
    @IBOutlet weak var imgViewPost: UIImageView!
    @IBOutlet weak var imgViewBackground: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imgViewUser.layer.cornerRadius = 20
        self.imgViewUser.clipsToBounds = true
        
        self.imgViewPost.layer.borderWidth = 4
        self.imgViewPost.layer.cornerRadius = 20
        self.imgViewPost.clipsToBounds = true
        
        if let post = self.post {
            
            if let username = post.user?.username {
                self.lblUsername.text =  "@" + username
            }
            self.lblName.text = post.user?.name
            
            if let color = post.color {
                self.imgViewUser.backgroundColor = Utility.colorFromString(hexString: color)
                self.imgViewBackground.backgroundColor = Utility.colorFromString(hexString: color)
                self.imgViewPost.backgroundColor = Utility.colorFromString(hexString: color)
                
                self.imgViewPost.layer.borderColor = Utility.colorFromString(hexString: color).cgColor
            }
            
            guard let urlPostImage = post.urlRegular else { return }
            let downloadDataPostImage = DownloadData(urlString: urlPostImage) { (data, error) in
                guard let data = data, error == nil else {
                    // update UI with error
                    return
                }
                OperationQueue.main.addOperation {
                    Utility.animateImageView(imageView: self.imgViewPost, with: data.toImage())
                    Utility.animateImageView(imageView: self.imgViewBackground, with: data.toImage())
                }
            }
            guard let urlProfileImage = post.user?.urlLarge else { return }
            let downloadDataProfileImage = DownloadData(urlString: urlProfileImage) { (data, error) in
                guard let data = data, error == nil else {
                    // update UI with error
                    return
                }
                OperationQueue.main.addOperation {
                    Utility.animateImageView(imageView: self.imgViewUser, with: data.toImage())
                }
            }
            Downloader.shared.startDownloads(with: [downloadDataPostImage, downloadDataProfileImage])
        }
    }
    

}
