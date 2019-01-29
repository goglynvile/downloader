//
//  Utility.swift
//  Downloader
//
//  Created by Glynvile Satago on 27/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    class func colorFromString(hexString: String) -> UIColor {
        var rgb: UInt32 = 0
        let hexString = hexString.replacingOccurrences(of: "#", with: "")
        
        guard Scanner(string: hexString).scanHexInt32(&rgb) else { return UIColor.white }
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
       return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    class func animateImageView(imageView: UIImageView, with image: UIImage?) {
        UIView.transition(with: imageView,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: {
                            imageView.image = image },
                          completion: nil)
    }
    class func alertViewControllerForError(message: String) -> UIAlertController {
        let alertViewController = UIAlertController(title: alertDownloadErrorTitle, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: alertDownloadErrorButtonText, style: .cancel, handler: nil))
        return alertViewController
    }
}
