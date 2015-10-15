//
//  CustomViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/14/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import AVKit

class CustomVideoViewController: UIViewController {
    
    private var videoView : VideoView?
    private var videoPlayer : AVPlayer?
    private var customURLString: String!
    
    convenience init(url: String) {
        self.init(nibName: nil, bundle: nil)
        self.customURLString = url
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "pause")
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.videoPlayer == nil {
            if let url = NSURL(string: customURLString) {
                let streamAsset = AVURLAsset(URL: url)
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
                if let url = NSURL(string: customURLString) {
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
