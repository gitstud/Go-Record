//
//  SongStruct.swift
//  GoRecord
//
//  Created by Max Nelson on 2/27/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

import UIKit


struct Song {
    var artist = ""
    var artist_id = ""
    var createdAt = NSDate()
    var filePath = ""
    var name = ""
    var plays = 0
    var likes = 0
    var id = ""
    var tags = [String]()
    var image = ""
    var pic = UIImage()
}

struct Artist {
    var artist_id = ""
    var name = ""
    var uploads = [String]()
    var likes = [String]()
    var plays = 0
    var tags = [String]()
    var following = [String]()
    var followers = [String]()
    var location = ""
    var imagePath = ""
    var blocked = [String]()
    var pageViews = 0
    var email = ""
    var pic = UIImage()
}
