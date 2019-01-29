//
//  User.swift
//  Downloader
//
//  Created by Glynvile Satago on 27/01/2019.
//  Copyright © 2019 Glynvile Satago. All rights reserved.
//

import Foundation

class User {
    
    private(set) var id: String
    var username: String
    
    var name: String?
    var urlSmall: String?
    var urlLarge: String?
    
    init(id: String, username: String) {
        self.id = id
        self.username = username
    }
}
