//
//  YoutubeVideoViewController.swift
//  GamingStreamsTVApp
//
//  Created by Chayel Heinsen on 10/10/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class YoutubeVideoViewController : UIViewController {
    private var videoView : VideoView?
    private var videoPlayer : AVPlayer?
    private var currentStream : YoutubeStream!
 
    /*
    * init(stream : YoutubeStream)
    *
    * Initializes the controller, it's gesture recognizer and modal menu.
    * Loads and prepare the video asset from the stream for display
    */
    convenience init(stream : YoutubeStream) {
        self.init(nibName: nil, bundle: nil)
        self.currentStream = stream;
        
        self.view.backgroundColor = UIColor.blackColor()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        YoutubeGaming.getLiveStreamURL(forVideo: self.currentStream.id) { (url, error) -> () in
            guard let url = url else {
                print("no url for youtube stream - error: \(error?.errorDescription)")
                return
            }
            let streamAsset = AVURLAsset(URL: url)
            let streamItem = AVPlayerItem(asset: streamAsset)
            
            self.videoPlayer = AVPlayer(playerItem: streamItem)
            
            dispatch_async(dispatch_get_main_queue(),{
                self.initializePlayerView()
            })
        }
    }
    
    /*
    * viewWillDisappear(animated: Bool)
    *
    * Overrides the default method to shut off the chat connection if present
    * and the free video assets
    */
    override func viewWillDisappear(animated: Bool) {
        self.videoView!.removeFromSuperview()
        self.videoView!.setPlayer(nil)
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
    
}