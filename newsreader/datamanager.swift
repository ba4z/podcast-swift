//
//  datamanager.swift
//  newsreader
//
//  Created by Bas on 10/23/16.
//  Copyright © 2016 Bas. All rights reserved.
//

import UIKit
import Foundation
import XCPlayground

class DataManager {
    
        func getData(completionHandler: ((NSArray!, NSError!) -> Void)!) -> Void {
            let url: NSURL = NSURL(string: "https://apps.customchurchapps.net/dashboard/parseFeed?url=http://genpod.libsyn.com/rss")
            let ses = NSURLSession.sharedSession()
            let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                if (error != nil) {
                    return completionHandler(nil, error)
                }
                
                var error: NSError?
                let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                
                if (error != nil) {
                    return completionHandler(nil, error)
                } else {
                    return completionHandler(json["results"] as [NSDictionary], nil)
                }
            })
            task.resume()
        }
    
}
