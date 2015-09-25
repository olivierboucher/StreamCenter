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
    private var gestureRecognizer : UILongPressGestureRecognizer?
    private var videoView : VideoView?
    private var videoPlayer : AVPlayer?
    private var stream : TwitchStream?
    private var chatView : TwitchChatView?
    
    convenience init(stream : TwitchStream){
        self.init(nibName: nil, bundle: nil)
        self.stream = stream;
        
        //Gestures configuration
        self.gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress")
        //self.gestureRecognizer!.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)];
        self.view.addGestureRecognizer(self.gestureRecognizer!)
        
        TwitchApi.getStreamsForChannel(self.stream!.channel.name) {
            (streams, error) in
            
            if(error != nil) {
                NSLog("Error getting stream video data")
            }
            
            if(streams != nil) {
                let streamObject = streams?.objectAtIndex(0) as! TwitchStreamVideo
                let streamAsset = AVURLAsset(URL: streamObject.url!)
                let streamItem = AVPlayerItem(asset: streamAsset)
                
                self.videoPlayer = AVPlayer(playerItem: streamItem)
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.initializePlayerView()
                    //self.initializeChatView()
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
        self.videoView = VideoView(frame: self.view.bounds)
        self.videoView?.setPlayer(self.videoPlayer!)
        self.videoView?.setVideoFillMode(AVLayerVideoGravityResizeAspect)
        
        self.view.addSubview(self.videoView!)
        self.videoPlayer?.play()
    }
    
    func initializeChatView() {
        self.chatView = TwitchChatView(frame: CGRect(x: 0, y: 0, width: 400, height: self.view!.bounds.height), channel: self.stream!.channel)
        self.chatView!.startDisplayingMessages()
        self.chatView?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.chatView!)
    }
    
    func handleLongPress() {
        if self.gestureRecognizer!.state == UIGestureRecognizerState.Began {
            //Pop modal menu
            //Live chat
            //      Display/Hide
            //Quality
            //      Source
            //      High
            //      Medium
            //      Low
            
            let modalMenu = ModalMenuView(frame: self.view.bounds,
                options: [
                    "Title1" : [
                        MenuOption(title: "test1-1", enabled: false),
                        MenuOption(title: "test1-2", enabled: false)
                    ],
                    "Title2" : [
                        MenuOption(title: "test2-1", enabled: false),
                        MenuOption(title: "test2-2", enabled: false),
                        MenuOption(title: "test2-3", enabled: false)
                    ]
                ],
                size: CGSize(width: self.view.bounds.width/2, height: self.view.bounds.height/2))
            
            modalMenu.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
            
            modalMenu.layer.borderColor = UIColor.blueColor().CGColor
            modalMenu.layer.borderWidth = 1
            
            self.view.addSubview(modalMenu)
        }
    }
}
