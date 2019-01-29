//
//  PostCollectionViewController.swift
//  Downloader
//
//  Created by Glynvile Satago on 26/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import UIKit
import Downloader

fileprivate let reuseIdentifier = "cell"
fileprivate let minCellWidth: CGFloat = 160
fileprivate let maxCellHeight: CGFloat = 300

class PostsCollectionViewController: UICollectionViewController {

    //initialize the array of posts
    fileprivate var arrayPosts = Array<Post>()
    fileprivate var layout: CustomCollectionViewLayout?
    fileprivate var selectedIndexItem: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Multiple Downloads"
        
        //add the pull to refresh view
        self.collectionView.refreshControl = self.refreshControl

        //set the margin
        collectionView?.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        
        //set the delegate of the layout
        if let layout = collectionView?.collectionViewLayout as? CustomCollectionViewLayout {
            
            self.layout = layout
            layout.numberOfColumns = Int(self.collectionView.bounds.width / minCellWidth)
            layout.delegate = self
        }

        self.fetchPosts()
    }
    func fetchPosts() {
        
        self.arrayPosts.removeAll()
        OperationQueue.main.addOperation {
            self.collectionView.reloadData()
        }
        let downloadData = DownloadData(urlString: serverUrl) { (data, error) in
            
            //parse the json array
            guard let posts = data?.toJSONArray() as? Array<Dictionary<String, Any>>, error == nil else {
                //display alert error here
                OperationQueue.main.addOperation {
                    self.present(Utility.alertViewControllerForError(message: error!), animated: true, completion: nil)
                }
                return }
            
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
        
        Downloader.shared.startDownload(with: downloadData)
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayPosts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCollectionViewCell
        
        cell.post = arrayPosts[indexPath.item]

        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexItem = indexPath
        self.performSegue(withIdentifier: "showProfile", sender: nil)
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
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile", let userViewController = segue.destination as? UserViewController {
            guard let selectedIndexItem = selectedIndexItem else { return }
            userViewController.post = arrayPosts[selectedIndexItem.item]
        }
    }
    
}

extension PostsCollectionViewController: CustomCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        if let origWidth = arrayPosts[indexPath.item].width, let origHeight =  arrayPosts[indexPath.item].height {
            
            //calculate the ratio of the original image
            let ratio = origWidth / origHeight
            
            //calculate the width of the cell
            let numColumns = Int(collectionView.bounds.width / minCellWidth)
            let newWidth = collectionView.bounds.width / CGFloat(numColumns) - (collectionView.layoutMargins.left + collectionView.layoutMargins.right)
            let newHeight = newWidth / CGFloat(ratio)
            
            // multiply 2 to have longer display
            let height = newHeight * 2
            return height < maxCellHeight ? height : maxCellHeight
        }
        return 0
    }
}

extension PostsCollectionViewController {
    /// Change the number of columns in the collectionview
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        if let layout = self.layout {
            let numColumns = Int(size.width / minCellWidth)
            //layout.invalidateLayout()
            layout.numberOfColumns = numColumns
           
            self.collectionView.reloadData()
            
        }
    }
}
