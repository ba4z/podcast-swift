//
//  RestApiManager.swift
//  newsreader
//
//  Created by Bas on 10/23/16.
//  Copyright © 2016 Bas. All rights reserved.
//

import Foundation

typealias ServiceResponse = (NSDictionary, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    
    func makeHTTPGetRequest(path: String, onCompletion: @escaping ServiceResponse) {
        let url = URL(string: path)
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            if error != nil {
                print(error ?? "error")
            } else {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    //print(parsedData)
                    onCompletion(parsedData as! NSDictionary, nil)
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
        }).resume()
    }
}

class DataService: NSObject {
    static let sharedInstance = DataService()
    
    var mediaItems = [MediaItem]()
    
    
}
