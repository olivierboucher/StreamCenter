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
    private var longPressRecognizer : UILongPressGestureRecognizer?
    private var videoView : VideoView?
    private var videoPlayer : AVPlayer?
    private var stream : TwitchStream?
    private var chatView : TwitchChatView?
    private var modalMenu : ModalMenuView?
    private var modalMenuOptions : Dictionary<String, Array<MenuOption>>?
    
    convenience init(stream : TwitchStream){
        self.init(nibName: nil, bundle: nil)
        self.stream = stream;
        
        //Gestures configuration
        self.longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress")
        self.view.addGestureRecognizer(self.longPressRecognizer!)
        
        //Modal menu options
        self.modalMenuOptions = [
            "Live Chat" : [
                MenuOption(enabledTitle: "Turn off", disabledTitle: "Turn on", enabled: false)
            ],
            "Stream Quality" : [
                MenuOption(title: "Source", enabled: false),
                MenuOption(title: "High", enabled: false),
                MenuOption(title: "Medium", enabled: false),
                MenuOption(title: "Low", enabled: false)
            ]
        ]
        
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
        if self.longPressRecognizer!.state == UIGestureRecognizerState.Began {
            modalMenu = ModalMenuView(frame: self.view.bounds,
                options: self.modalMenuOptions!,
                size: CGSize(width: self.view.bounds.width/3, height: self.view.bounds.height/1.5))
            
            modalMenu!.center = self.view.center
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleMenuPress")
            gestureRecognizer.allowedPressTypes = [UIPressType.Menu.rawValue]
            
            modalMenu?.addGestureRecognizer(gestureRecognizer)
            
            self.view.addSubview(modalMenu!)
        }
    }
    
    func handleMenuPress() {
        if let modalMenu = modalMenu {
            if self.view.subviews.contains(modalMenu) {
                modalMenu.removeFromSuperview()
                return
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
