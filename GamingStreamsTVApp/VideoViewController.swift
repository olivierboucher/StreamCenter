//
//  VideoViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import AVKit
import UIKit
import Foundation

class VideoViewController : UIViewController {
    private var _videoView : VideoView?
    private var _videoPlayer : AVPlayer?
    private var _stream : TwitchStream?
    private var chatView : TwitchChatView?
    
    convenience init(stream : TwitchStream){
        self.init(nibName: nil, bundle: nil);
        self._stream = stream;
        
        TwitchApi.getStreamsForChannel(_stream!.channel.name) {
            (streams, error) in
            
            if(error != nil) {
                NSLog("Error getting stream video data")
            }
            
            if(streams != nil) {
                let streamObject = streams?.objectAtIndex(0) as! TwitchStreamVideo
                let streamAsset = AVURLAsset(URL: streamObject.url!)
                let streamItem = AVPlayerItem(asset: streamAsset)
                
                self._videoPlayer = AVPlayer(playerItem: streamItem)
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.initializePlayerView()
                    self.initializeChatView()
                })

            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializePlayerView() {
        self._videoView = VideoView(frame: self.view.bounds)
        self._videoView?.setPlayer(self._videoPlayer!)
        self._videoView?.setVideoFillMode(AVLayerVideoGravityResizeAspect)
        
        self.view.addSubview(self._videoView!);
        self._videoPlayer?.play()
    }
    
    func initializeChatView() {
        self.chatView = TwitchChatView(frame: CGRect(x: 0, y: 0, width: 400, height: self.view!.bounds.height), channel: self._stream!.channel)
        self.chatView!.startDisplayingMessages()
        self.chatView?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.chatView!)
    }
}
