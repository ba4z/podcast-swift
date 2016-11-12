//
//  MediaService.swift
//  newsreader
//
//  Created by Bas on 11/6/16.
//  Copyright © 2016 Bas. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class MediaService: NSObject {
    static let sharedInstance = MediaService()
    
    public let STATUS_CHANGE_NOTIFICATION: String = "PlayerStatusChanged"
    public let PLAYING_CHANGE_NOTIFICATION: String = "PlayingStatusChanged"
    public let ITEM_CHANGE_NOTIFICATION: String = "ItemStatusChanged"
    public let TIME_CHANGE_NOTIFICATION: String = "PlayTimeChanged"
    
    private var player: AVPlayer?
    private var url: URL?
    private var mediaItem:MediaItem? {
        didSet {
            mediaItemChanged()
        }
    }
    private var isPlaying:Bool = false {
        didSet {
            notifyPlayingChanged()
        }
    }
    private var status:AVPlayerItemStatus? {
        didSet {
            notifyStatusChanged()
        }
    }
    
    private var timer: Timer?
    
    private override init() {}
    
    func playUrl(url:URL) {
        self.isPlaying = false;
        if(self.player != nil && self.player?.rate != 0 && (self.player?.error == nil)){
            print("already playing")
            self.pause()
        } else if (self.player != nil && self.player?.rate == 0 && (self.player?.error == nil)) {
            print("resuming playback playing")
            self.play()
        } else {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                let playerItem = AVPlayerItem(url: url)
                self.player = AVPlayer(playerItem:playerItem)
                self.player!.currentItem!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
                self.url = url;
                
                self.player!.play()
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            
            //https://developer.apple.com/reference/avfoundation/avplayeritem#//apple_ref/c/tdef/AVPlayerItemStatus
            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            self.status = status
        }
    }
    
    func play()  {
        self.player?.play()
        self.isPlaying = true
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: notifyTimeChange)
    }
    
    func pause() {
        self.player?.pause()
        self.isPlaying = false
        self.timer?.invalidate()
    }
    
    func getTime() -> CMTime? {
        return self.player?.currentItem?.currentTime()
    }
    
    func getMediaItemUrl() -> URL? {
        return self.url
    }
    
    func isCurrentlyPlaying() -> Bool{
        return self.isPlaying
    }
    
    func setTime(time: Float) {
        let cmTime = CMTimeMake(Int64(time), 1)
        self.player?.currentItem?.seek(to: cmTime)
    }
    
    func setMediaItem(item:MediaItem)  {
        self.mediaItem = item;
        updateNowPlayingInfo()
    }
    
    func getMediaItem() -> (MediaItem)?  {
        return self.mediaItem
    }
    
    func getDuration() -> CMTime? {
        return player?.currentItem?.asset.duration
    }
    
    private func notifyStatusChanged(){
        let notificationName = Notification.Name(self.STATUS_CHANGE_NOTIFICATION)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["status":self.status!])
    }
    
    private func notifyPlayingChanged(){
        let notificationName = Notification.Name(self.PLAYING_CHANGE_NOTIFICATION)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["isPlaying":self.isPlaying])
    }
    
    private func mediaItemChanged() {
        let notificationName = Notification.Name(self.ITEM_CHANGE_NOTIFICATION)
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    
    private func updateNowPlayingInfo() {
        if(self.mediaItem != nil){
            let artworkProperty = MPMediaItemArtwork(image: self.mediaItem!.imageView!)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : self.mediaItem!.title, MPMediaItemPropertyArtist : self.mediaItem!.author, MPMediaItemPropertyArtwork : artworkProperty, MPNowPlayingInfoPropertyDefaultPlaybackRate : NSNumber(value: 1), MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds((player!.currentItem?.asset.duration)!)]

        }
    }
    
    private func notifyTimeChange(timer:Timer) -> Void {
        print("tick... tock")
        let notificationName = Notification.Name(self.TIME_CHANGE_NOTIFICATION)
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    
    
    
}
