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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let urlString = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        Downloader.shared.download(urlString: urlString ) { (data, error) in
            
            if let error = error {
                
            }
            else {
                guard let data = data else { return }
                OperationQueue.main.addOperation {
                    guard let url = data.toVideoUrl(fileName: (urlString as NSString).lastPathComponent) else { return }
                    let player = AVPlayer(url: url)
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    
                    self.present(playerController, animated: true, completion: {
                        player.play()
                    })
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
