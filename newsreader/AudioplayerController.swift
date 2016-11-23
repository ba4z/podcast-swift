//
//  SecondViewController.swift
//  newsreader
//
//  Created by Bas on 10/22/16.
//  Copyright © 2016 Bas. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayerController: UIViewController {
    
    @IBOutlet weak var playerImg: UIImageView!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var beginTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerSlider.minimumValue = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayingChange), name: NSNotification.Name(rawValue: MediaService.sharedInstance.PLAYING_CHANGE_NOTIFICATION), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(mediaItemUpdated), name: NSNotification.Name(rawValue: MediaService.sharedInstance.ITEM_CHANGE_NOTIFICATION), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playingTimeUpdated), name: NSNotification.Name(rawValue: MediaService.sharedInstance.TIME_CHANGE_NOTIFICATION), object: nil)
        
        mediaItemUpdated()
        onPlayingChange(notification: nil)
        
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = false;
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = false;
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = false;
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = false;
    }
    
    func onPlayingChange(notification:Notification?) {
        print("playing changed")
        if(MediaService.sharedInstance.isCurrentlyPlaying()){
            self.playBtn.setTitle("Pause", for: UIControlState.normal)
        } else {
            self.playBtn.setTitle("Play", for: UIControlState.normal)
        }
    }
    
    func mediaItemUpdated() {
        let mediaItem = MediaService.sharedInstance.getMediaItem()
        
        if(mediaItem == nil) {
            self.playerSlider.isEnabled = false
            self.playBtn.isHidden = true
            self.emptyLabel.isHidden = false
            self.playerImg.image = #imageLiteral(resourceName: "placeholder.png")
            
        } else {
            self.playerImg.image = mediaItem?.imageView
            UIView.animate(withDuration: 1, animations: {
                self.playerSlider.isEnabled = true
                self.playBtn.isHidden = false
                self.emptyLabel.isHidden = true
            })
            self.playerSlider.maximumValue = Float((MediaService.sharedInstance.getDuration()?.seconds)!)
        }
        self.playerSlider.value = 0
        
        if(MediaService.sharedInstance.getMediaItem() != nil) {
        
            let totalDuration = MediaService.sharedInstance.getDuration()!.seconds
            let seconds = floor(totalDuration.truncatingRemainder(dividingBy: 60))
            let minutes = floor(totalDuration/60)
        
            self.endTimeLabel.text = String(format: "%.0f:%.0f", minutes, seconds)
        
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : "Artist!",  MPMediaItemPropertyTitle : "Title!"]
        }
    }
    
    func playingTimeUpdated() {
        self.playerSlider.value = Float((MediaService.sharedInstance.getTime()?.seconds)!)
        
        let secondsPassed = MediaService.sharedInstance.getTime()!.seconds
        let seconds = floor(secondsPassed.truncatingRemainder(dividingBy: 60))
        let minutes = floor(secondsPassed/60)
        
        self.beginTimeLabel.text = String(format: "%.0f:%.0f", minutes, seconds)
    }

    @IBAction func playBtnDown(_ sender: Any) {
        if(MediaService.sharedInstance.isCurrentlyPlaying()) {
            MediaService.sharedInstance.pause()
        } else {
            MediaService.sharedInstance.play()
        }
    }
    
    @IBAction func sliderDragged(_ sender: Any) {
        MediaService.sharedInstance.setTime(time: self.playerSlider.value)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

