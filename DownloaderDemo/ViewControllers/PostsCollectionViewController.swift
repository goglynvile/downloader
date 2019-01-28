//
//  PostCollectionViewController.swift
//  Downloader
//
//  Created by Glynvile Satago on 26/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import UIKit
import Downloader

private let reuseIdentifier = "cell"

class PostsCollectionViewController: UICollectionViewController {

    //initialize the array of posts
    var arrayPosts = Array<Post>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Multiple Downloads"
        
        //add the pull to refresh view
        self.collectionView.refreshControl = self.refreshControl

        //set the margin
        collectionView?.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        
        //set the delegate of the layout
        if let layout = collectionView?.collectionViewLayout as? CustomCollectionViewLayout {
            layout.delegate = self
        }

        self.fetchPosts()
    }

    func fetchPosts() {
        
        // remove the posts from the array and reload the data
        self.arrayPosts.removeAll()
        OperationQueue.main.addOperation {
            
            self.collectionView.reloadData()
        }
        
        
        //call the service
        Downloader.shared.download(urlString: serverUrl) { (data, error) in
            //parse the json array
            guard let posts = data?.toJSONArray() as? Array<Dictionary<String, Any>> else { return }
            
            for post in posts {
                guard let id = post["id"] as? String else { return }
                let postObj = Post(id: id)
                postObj.color = post["color"] as? String
                postObj.width = post["width"] as? Float
                postObj.height = post["height"] as? Float
                
                if let user = post["user"] as? Dictionary<String, Any> {
                    guard let id = user["id"] as? String, let username = user["username"] as? String  else { return }
                    
                    let userObj = User(id: id, username: username)
                    userObj.name = user["name"] as? String
                    
                    if let urls = user["profile_image"] as? Dictionary<String, String> {
                        userObj.urlSmall = urls["small"]
                        userObj.urlLarge = urls["large"]
                    }
                    
                    postObj.user = userObj
                }
                
                if let urls = post["urls"] as? Dictionary<String, String> {
                    postObj.urlSmall = urls["small"]
                    postObj.urlRegular = urls["regular"]
                }
                
                self.arrayPosts.append(postObj)
            }
            OperationQueue.main.addOperation {
                self.collectionView.reloadData()
                
            }
            
        }
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items

        return arrayPosts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCollectionViewCell
        
        cell.post = arrayPosts[indexPath.item]
        // Configure the cell
    
        return cell
    }
    
    // MARK: Add Pull to Refresh
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {

        refreshControl.endRefreshing()
        self.fetchPosts()
    }
}
extension PostsCollectionViewController: CustomCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        if let origWidth = arrayPosts[indexPath.item].width, let origHeight =  arrayPosts[indexPath.item].height {
            
            //calculate the ratio of the original image
            let ratio = origWidth / origHeight
            
            //calculate the width of the cell
            let newWidth = collectionView.bounds.width / 2 - (collectionView.layoutMargins.left + collectionView.layoutMargins.right)
            let newHeight = newWidth / CGFloat(ratio)
            
            // multiply 2 to have longer display
            // add 28 for the button height
            // max height set to 300
            let height = newHeight * 2 + 28
            return height < 300 ? height : 300 // button space
        }
        return 0
    }
}
