//
//  TableViewController.swift
//  newsreader
//
//  Created by Bas on 10/29/16.
//  Copyright © 2016 Bas. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(TableViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        
        loadData()

    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData()
    }
    
    func loadData() {
        DataService.sharedInstance.mediaItems = []
        RestApiManager.sharedInstance.makeHTTPGetRequest(path: "https://apps.customchurchapps.net/dashboard/parseFeed?url=http://genpod.libsyn.com/rss", onCompletion: { json, err in
            
            for item in json["items"] as! [Dictionary<String, AnyObject>] {
                let mediaItem = MediaItem(title: item["title"] as! String, description: item["description"] as! String, author: item["author"] as! String, link: item["link"] as! String)
                
                if(item["image"] != nil && item["image"]?["url"] != nil){
                    mediaItem.setImage(imageUrl: item["image"]?["url"] as! String)
                }
                if(item["itunes:subtitle"] != nil && item["itunes:subtitle"]!["#"] != nil){
                    mediaItem.setSubTitle(subtitle: item["itunes:subtitle"]!["#"] as! String)
                }
                if(item["enclosures"] != nil){
                    mediaItem.setEnclosures(enclosureList: item["enclosures"] as! [AnyObject])
                }
                
                DataService.sharedInstance.mediaItems.append(mediaItem)
            }
            DispatchQueue.main.async{
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataService.sharedInstance.mediaItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MediaItemViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MediaItemTableViewCell
        
        if(DataService.sharedInstance.mediaItems.indices.contains(indexPath.row)) {
            let item = DataService.sharedInstance.mediaItems[indexPath.row]
            cell.title.text = item.title
            cell.subtitle.text = item.subtitle
            cell.cellImage.image = nil
        
        
            if(item.imageUrl != nil) {
                if(item.imageView != nil) {
                    cell.cellImage.image = item.imageView
                } else {
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: URL(string: item.imageUrl!)!) //make sure your image in this url does exist
                        DispatchQueue.main.async {
                            item.setImageView(img: UIImage(data: data!)!)
                            cell.cellImage.image = item.imageView
                            UIView.animate(withDuration: 1, animations: {
                                cell.cellImage.alpha = 1.0
                            })
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "itemSeque") {
            let viewController = segue.destination as! ItemViewController
            viewController.mediaItemIndex = (tableView.indexPathForSelectedRow?.row)!
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
