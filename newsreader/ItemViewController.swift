//
//  ItemViewController.swift
//  newsreader
//
//  Created by Bas on 10/31/16.
//  Copyright © 2016 Bas. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer

class ItemViewController: UIViewController {

    var mediaItemIndex:Int!
    var mediaItem:MediaItem?
    var isMediaLoading: Bool = false;
    var moviePlayer:AVPlayer!
    
    
    @IBOutlet weak var itemImg: UIImageView!
    @IBOutlet weak var itemHeader: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    
    @IBOutlet weak var playVideoBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mediaItem = DataService.sharedInstance.mediaItems[self.mediaItemIndex]
        self.playBtn.alpha = 0

        if(self.mediaItem != nil){
            self.itemHeader.text = self.mediaItem!.title
        
            let html = "<span style=\"font-family: Helvetica; font-size: 17\">\(self.mediaItem!.descr)</span>"
            let attrStr = try! NSAttributedString(
                data: html.data(using: String.Encoding.utf8)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
            
            
            self.itemDescription.attributedText = attrStr
            
            DispatchQueue.global().async {
                if(self.mediaItem?.imageView != nil){
                    self.itemImg.image = self.mediaItem?.imageView
                } else if(self.mediaItem?.imageUrl != nil) {
                    self.itemImg.alpha = 0
                    let data = try? Data(contentsOf: URL(string: (self.mediaItem?.imageUrl!)!)!) //make sure your image in this url does exist
                    DispatchQueue.main.async {
                        self.itemImg.image = UIImage(data: data!)
                        UIView.animate(withDuration: 1, animations: {
                            self.itemImg.alpha = 1.0
                        })
                    }
                }
            }
            
            if(self.mediaItem != nil && self.mediaItem?.audioUrl != nil) {
                if(MediaService.sharedInstance.getMediaItemUrl() == self.mediaItem?.audioUrl && MediaService.sharedInstance.isCurrentlyPlaying()){
                    mediaPlaying()
                }
                
                UIView.animate(withDuration: 1, animations: {
                    self.playBtn.alpha = 1.0
                })
                self.playVideoBtn.isHidden = true;
            } else if(self.mediaItem != nil && self.mediaItem?.videoUrl != nil) {
                self.playBtn.isHidden = true;
                UIView.animate(withDuration: 1, animations: {
                    self.playVideoBtn.alpha = 1.0
                })
            }
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(onStatusChange), name: NSNotification.Name(rawValue: MediaService.sharedInstance.STATUS_CHANGE_NOTIFICATION), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(onPlayingChange), name: NSNotification.Name(rawValue: MediaService.sharedInstance.PLAYING_CHANGE_NOTIFICATION), object: nil)

        }
        
    }
    
    func onStatusChange(notification: Notification) {
        switch notification.userInfo!["status"]! {
        case AVPlayerItemStatus.readyToPlay:
            print("ready to play!")
            self.isMediaLoading = false;
            MediaService.sharedInstance.play()
            break
        case AVPlayerItemStatus.failed:
            print("error")
            break
        default:
            print("not yet ready to play")
            break
        }
    }
    
    func onPlayingChange(notification:Notification) {
        let isPlaying = notification.userInfo!["isPlaying"]! as! Bool
        if(isPlaying) {
            mediaPlaying()
        } else if(!isMediaLoading && !isPlaying){
            mediaPaused()
        }
    }
    
    func mediaPlaying() {
        self.playBtn.isEnabled = true;
        self.spinner.isHidden = true
        self.playBtn.setTitle("Pause", for: UIControlState.normal)
    }
    
    func mediaPaused() {
        self.playBtn.isEnabled = true;
        self.spinner.isHidden = true
        self.playBtn.setTitle("Play", for: UIControlState.normal)
    }
    
    func mediaLoading() {
        self.isMediaLoading = true;
        self.playBtn.isEnabled = false;
        self.spinner.isHidden = false
        self.playBtn.setTitle("Pause", for: UIControlState.normal)
    }
    
    
    @IBAction func playBtnTouchDown(_ sender: Any) {
        if(self.mediaItem != nil && self.mediaItem?.audioUrl != nil){
            if(MediaService.sharedInstance.isCurrentlyPlaying()){
                MediaService.sharedInstance.pause()
                mediaPaused()
            } else {
                mediaLoading()
                MediaService.sharedInstance.playUrl(url: self.mediaItem!.audioUrl!)
                MediaService.sharedInstance.setMediaItem(item: self.mediaItem!)
            }
        }
    }
    
    @IBAction func playVideoBtnTouchDown(_ sender: Any) {
        let player = AVPlayer(url: self.mediaItem!.videoUrl!)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.addChildViewController(playerController)
        self.view.subviews[0].addSubview(playerController.view)
        playerController.player!.allowsExternalPlayback = true
        playerController.player!.usesExternalPlaybackWhileExternalScreenIsActive = true
        
        //let y = (self.tabBarController?.tabBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        
        playerController.view.frame = CGRect(x: 0, y: -65, width: self.itemImg.frame.size.width, height: self.itemImg.frame.size.height)
        player.play()
        
        let volumeView = MPVolumeView(frame: CGRect(x: 50, y: 300, width: 100, height: self.itemImg.frame.size.height))
        
        volumeView.showsVolumeSlider = false
        volumeView.sizeToFit()
        volumeView.backgroundColor = UIColor.black
        volumeView.showsRouteButton = true
        //self.view.addSubview(volumeView)
        
        self.itemImg.isHidden = true
        self.playVideoBtn.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
