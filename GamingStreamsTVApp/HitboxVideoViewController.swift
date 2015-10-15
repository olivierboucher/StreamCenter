//
//  HitboxVideoViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/15/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//



/*
http://edge.hls.dt.hitbox.tv/hls/ectvlol_480p/index.m3u8?st=fKoXPaIpOaK8SNRUI4F-0A;ci=TWfD9r2gQqGXWXXg_lRv5Q
Scheme	http
Host	edge.hls.dt.hitbox.tv
Path	/hls/ectvlol_480p/index.m3u8
Query String	st=fKoXPaIpOaK8SNRUI4F-0A;ci=TWfD9r2gQqGXWXXg_lRv5Q
*/

import UIKit
import AVKit

class HitboxVideoViewController : UIViewController {
    private var videoView : VideoView?
    private var videoPlayer : AVPlayer?
    
    private var media: HitboxMedia!
    private var streamVideos: [HitboxStreamVideo]?
    private var currentStreamVideo: HitboxStreamVideo?
    
    private var leftSwipe: UISwipeGestureRecognizer!
    private var rightSwipe: UISwipeGestureRecognizer!
    
    /*
    * init(stream : TwitchStream)
    *
    * Initializes the controller, it's gesture recognizer and modal menu.
    * Loads and prepare the video asset from the stream for display
    */
    convenience init(media: HitboxMedia){
        self.init(nibName: nil, bundle: nil)
        self.media = media
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "pause")
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        self.view.addGestureRecognizer(tapRecognizer)
        
        HitboxAPI.getStreamInfo(forMediaId: self.media.userMediaId) { (streamVideos, error) -> () in
            
            if let streamVideos = streamVideos where streamVideos.count > 0 {
                self.streamVideos = streamVideos
                self.currentStreamVideo = streamVideos[0]
                let streamAsset = AVURLAsset(URL: self.currentStreamVideo!.url)
                let streamItem = AVPlayerItem(asset: streamAsset)
                
                self.videoPlayer = AVPlayer(playerItem: streamItem)
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.initializePlayerView()
                })
            }
        }
    }
    
    /*
    * viewWillDisappear(animated: Bool)
    *
    * Overrides the default method to shut off the chat connection if present
    * and the free video assets
    */
    override func viewWillDisappear(animated: Bool) {
        
        self.videoView?.removeFromSuperview()
        self.videoView?.setPlayer(nil)
        self.videoView = nil
        self.videoPlayer = nil
        
        super.viewWillDisappear(animated)
    }
    
    /*
    * initializePlayerView()
    *
    * Initializes a player view with the current video player
    * and displays it
    */
    func initializePlayerView() {
        self.videoView = VideoView(frame: self.view.bounds)
        self.videoView?.setPlayer(self.videoPlayer!)
        self.videoView?.setVideoFillMode(AVLayerVideoGravityResizeAspect)
        
        self.view.addSubview(self.videoView!)
        self.videoPlayer?.play()
    }
    
    func pause() {
        if let player = self.videoPlayer {
            if player.rate == 1 {
                player.pause()
            } else {
                if let url = self.currentStreamVideo?.url {
                    //do this to bring it back in sync
                    let streamAsset = AVURLAsset(URL: url)
                    let streamItem = AVPlayerItem(asset: streamAsset)
                    player.replaceCurrentItemWithPlayerItem(streamItem)
                }
                player.play()
            }
        }
    }
}
