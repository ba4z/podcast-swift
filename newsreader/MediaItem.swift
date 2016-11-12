//
//  mediaItem.swift
//  newsreader
//
//  Created by Bas on 10/29/16.
//  Copyright © 2016 Bas. All rights reserved.
//

import UIKit

class MediaItem {
    var title: String
    var imageUrl: String?
    var imageView: UIImage?
    var descr: String
    var pubDate: Date?
    var author: String
    var link: String
    var subtitle: String?
    var audioUrl: URL?
    var videoUrl: URL?
    
    init(title: String, description: String, author: String, link:String) {
        self.title = title
        self.descr = description
        self.author = author
        self.link = link
    }
    
    func setImage(imageUrl: String)  {
        self.imageUrl = imageUrl
    }
    
    func setSubTitle(subtitle: String){
        self.subtitle = subtitle
    }
    
    func setEnclosures(enclosureList: [AnyObject]) {
        for item in enclosureList {
            //print(item)
            let type = item["type"] as! String
            if (type.lowercased().range(of: "audio") != nil && item["url"] != nil) {
                self.audioUrl = URL(string: item["url"] as! String)
            }
            if (type.lowercased().range(of: "video") != nil && item["url"] != nil) {
                self.videoUrl = URL(string: item["url"] as! String)
            }
        }
    }
    
    func setImageView(img:UIImage) {
        self.imageView = img
    }
    
    func setPubDate(pubDate: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-ddT.hh.mmSSSZ"
        self.pubDate = dateFormatter.date(from:pubDate)
    }
}
