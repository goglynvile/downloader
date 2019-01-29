//
//  PostCollectionViewCell.swift
//  Downloader
//
//  Created by Glynvile Satago on 26/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import UIKit
import Downloader

class PostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 10
    }
    weak var post: Post? {
        didSet {
            guard let _post = post, let url = _post.urlSmall else { return }
            
            if let color = _post.color {
                self.imageView.backgroundColor = Utility.colorFromString(hexString: color)
            }
            self.imageView.image = nil
        
            let downloadData = DownloadData(urlString: url) { (data, error) in
                guard let data = data, error == nil else { return }
                OperationQueue.main.addOperation {
                    Utility.animateImageView(imageView: self.imageView, with: data.toImage())
                }
            }
            Downloader.shared.startDownload(with: downloadData)
            
//            Downloader.shared.download(urlString: url) { (data, error) in
//                guard let data = data else { return }
//                OperationQueue.main.addOperation {
//                    Utility.animateImageView(imageView: self.imageView, with: data.toImage())
//                }
//
//            }
        }
    }
    
    
}
