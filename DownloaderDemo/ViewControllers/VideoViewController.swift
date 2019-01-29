//
//  PDFViewController.swift
//  Downloader
//
//  Created by Glynvile Satago on 27/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import UIKit
import Downloader
import AVKit

class VideoViewController: UIViewController {
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityView.startAnimating()

        let urlString = "http://techslides.com/demos/sample-videos/small.mp4"
        
        let downloadData = DownloadData(urlString: urlString) { (data, error) in
            guard let data = data, error == nil else {
                //update UI for error
                OperationQueue.main.addOperation {
                    self.activityView.stopAnimating()
                    self.present(Utility.alertViewControllerForError(message: error!), animated: true, completion: nil)
                }
                return
            }
            
            // update UI if successfully downloaded the video
            OperationQueue.main.addOperation {
                
                self.activityView.stopAnimating()
                guard let url = data.toVideoUrl(urlString: urlString) else { return }
                
                let player = AVPlayer(url: url)
                let playerController = AVPlayerViewController()
                playerController.player = player
                
                self.addChild(playerController)
                playerController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                self.view.addSubview(playerController.view)
                player.play()

            }
        }
        
        Downloader.shared.startDownload(with: downloadData)
    }


}
