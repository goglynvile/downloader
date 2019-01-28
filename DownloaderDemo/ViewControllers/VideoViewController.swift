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

        print("Cache Memory before movie download: \(URLCache.shared.currentMemoryUsage)")
        
        self.activityView.startAnimating()
        
        //let urlString = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        let urlString = "http://techslides.com/demos/sample-videos/small.mp4"
        Downloader.shared.download(urlString: urlString ) { (data, error) in
            
            if let error = error {
                
            }
            else {
                guard let data = data else { return }
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
                    
                    print("Cache Memory after movie download: \(URLCache.shared.currentMemoryUsage)")
                    
                }
                
            }
        }
        // Do any additional setup after loading the view.
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
