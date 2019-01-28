//
//  PDFViewController.swift
//  Downloader
//
//  Created by Glynvile Satago on 27/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import UIKit
import Downloader
import WebKit

class PDFViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Downloader.shared.download(urlString: "http://www.africau.edu/images/default/sample.pdf") { (data, error) in
            
            if let error = error {
                
            }
            else {
                guard let data = data else { return }
                OperationQueue.main.addOperation {
                    
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
