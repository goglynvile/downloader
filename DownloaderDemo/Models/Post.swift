//
//  Post.swift
//  Downloader
//
//  Created by Glynvile Satago on 26/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import Foundation

class Post {
    
    private(set) var id: String
    var color: String?
    var width: Float?
    var height: Float?
    var urlSmall: String?
    var urlRegular: String?
    
    var user: User?
    
    init(id: String) {
        self.id = id
    }
}
