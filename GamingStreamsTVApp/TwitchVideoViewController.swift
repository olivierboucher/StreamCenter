//
//  TwitchVideoViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import AVKit
import UIKit
import Foundation

enum StreamSourceQuality: String {
    case Source
    case High
    case Medium
    case Low
}

class TwitchVideoViewController : UIViewController {
    private var videoView : VideoView?
    private var videoPlayer : AVPlayer?
    private var streams : [TwitchStreamVideo]?
    private var currentStream : TwitchStream?
    private var currentStreamVideo: TwitchStreamVideo?
    private var chatView : TwitchChatView?
    private var modalMenu : ModalMenuView?
    private var modalMenuOptions : [String : [MenuOption]]?
    
    private var leftSwipe: UISwipeGestureRecognizer!
    private var rightSwipe: UISwipeGestureRecognizer!
    
    /*
    * init(stream : TwitchStream)
    *
    * Initializes the controller, it's gesture recognizer and modal menu.
    * Loads and prepare the video asset from the stream for display
    */
    convenience init(stream : TwitchStream){
        self.init(nibName: nil, bundle: nil)
        self.currentStream = stream
        
        self.view.backgroundColor = UIColor.blackColor()
        
        //Gestures configuration
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        longPressRecognizer.cancelsTouchesInView = true
        self.view.addGestureRecognizer(longPressRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "pause")
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        self.view.addGestureRecognizer(tapRecognizer)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleMenuPress")
        gestureRecognizer.allowedPressTypes = [UIPressType.Menu.rawValue]
        gestureRecognizer.cancelsTouchesInView = true
        self.view.addGestureRecognizer(gestureRecognizer)
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipe:"))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(leftSwipe)
        
        rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipe:"))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        rightSwipe.enabled = false
        self.view.addGestureRecognizer(rightSwipe)
            
        //Modal menu options
        self.modalMenuOptions = [
            "Live Chat" : [
                MenuOption(enabledTitle: "Turn off", disabledTitle: "Turn on", enabled: false, onClick:self.handleChatOnOff)
            ],
            "Stream Quality" : [
                MenuOption(title: StreamSourceQuality.Source.rawValue, enabled: false, onClick: self.handleQualityChange),
                MenuOption(title: StreamSourceQuality.High.rawValue, enabled: false, onClick: self.handleQualityChange),
                MenuOption(title: StreamSourceQuality.Medium.rawValue, enabled: false, onClick: self.handleQualityChange),
                MenuOption(title: StreamSourceQuality.Low.rawValue, enabled: false, onClick: self.handleQualityChange)
            ]
        ]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        TwitchApi.getStreamsForChannel(self.currentStream!.channel.name) {
            (streams, error) in
            
            if let streams = streams where streams.count > 0 {
                self.streams = streams
                self.currentStreamVideo = streams[0]
                let streamAsset = AVURLAsset(URL: self.currentStreamVideo!.url)
                let streamItem = AVPlayerItem(asset: streamAsset)
                
                self.videoPlayer = AVPlayer(playerItem: streamItem)
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.initializePlayerView()
                })
            } else {
                let alert = UIAlertController(title: "Uh-Oh!", message: "There seems to be an issue with the stream. We're very sorry about that.", preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { (action) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(alert, animated: true, completion: nil)
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
        
        self.chatView?.stopDisplayingMessages()
        self.chatView?.removeFromSuperview()
        self.chatView = nil
        
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
    
    /*
    * initializeChatView()
    *
    * Initializes a chat view for the current channel
    * and displays it
    */
    func initializeChatView() {
        self.chatView = TwitchChatView(frame: CGRect(x: 0, y: 0, width: 400, height: self.view!.bounds.height), channel: self.currentStream!.channel)
        self.chatView!.startDisplayingMessages()
        self.chatView?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.chatView!)
    }
    
    /*
    * handleLongPress()
    *
    * Handler for the UILongPressGestureRecognizer of the controller
    * Presents the modal menu if it is initialized
    */
    func handleLongPress(longPressRecognizer: UILongPressGestureRecognizer) {
        if longPressRecognizer.state == UIGestureRecognizerState.Began {
            if self.modalMenu == nil {
                modalMenu = ModalMenuView(frame: self.view.bounds,
                    options: self.modalMenuOptions!,
                    size: CGSize(width: self.view.bounds.width/3, height: self.view.bounds.height/1.5))
                
                modalMenu!.center = self.view.center
            }
            
            guard let modalMenu = self.modalMenu else {
                return
            }
            
            if modalMenu.isDescendantOfView(self.view) {
                dismissMenu()
            } else {
                modalMenu.alpha = 0
                self.view.addSubview(self.modalMenu!)
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.modalMenu?.alpha = 1
                    self.view.setNeedsFocusUpdate()
                })
            }
        }
    }
    
    /*
    * handleMenuPress()
    *
    * Handler for the UITapGestureRecognizer of the modal menu
    * Dismisses the modal menu if it is present
    */
    func handleMenuPress() {
        if dismissMenu() {
            return
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissMenu() -> Bool {
        if let modalMenu = modalMenu {
            if self.view.subviews.contains(modalMenu) {
                //bkirchner: for some reason when i try to animate the menu fading away, it just goes to the homescreen - really odd
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    modalMenu.alpha = 0
                }, completion: { (finished) -> Void in
                    Logger.Debug("Fade away animation finished: \(finished)")
                    if finished {
                        modalMenu.removeFromSuperview()
                    }
                })
//                modalMenu.removeFromSuperview()
                return true
            }
        }
        return false
    }
    
    /*
    * handleChatOnOff(sender : MenuItemView?)
    *
    * Handler for the chat option from the modal menu
    * Displays or remove the chat view
    */
    func handleChatOnOff(sender : MenuItemView?) {
        //NOTE(Olivier) : 400 width reduction at 16:9 is 225 height reduction
        dispatch_async(dispatch_get_main_queue(), {
            if let menuItem = sender {
                if menuItem.isOptionEnabled() {     //                      Turn chat off
                    
                    self.hideChat()
                    
                    //Set the menu option accordingly
                    menuItem.setOptionEnabled(false)
                }
                else {                              //                      Turn chat on
                    
                    self.showChat()
                    
                    //Set the menu option accordingly
                    menuItem.setOptionEnabled(true)
                }
            }
        })
    }
    
    func showChat() {
        //Resize video view
        var frame = self.videoView?.frame
        frame?.size.width -= 400
        frame?.size.height -= 225
        frame?.origin.y += (225/2)
        
        
        
        //The chat view
        self.chatView = TwitchChatView(frame: CGRect(x: self.view.bounds.width, y: 0, width: 400, height: self.view!.bounds.height), channel: self.currentStream!.channel)
        self.chatView!.startDisplayingMessages()
        if let modalMenu = modalMenu {
            
            self.view.insertSubview(self.chatView!, belowSubview: modalMenu)
        } else {
            self.view.addSubview(self.chatView!)
        }
        
        rightSwipe.enabled = true
        leftSwipe.enabled = false
        
        //animate the showing of the chat view
        UIView.animateWithDuration(0.5) { () -> Void in
            self.chatView!.frame = CGRect(x: self.view.bounds.width - 400, y: 0, width: 400, height: self.view!.bounds.height)
            if let videoView = self.videoView, frame = frame {
                videoView.frame = frame
            }
        }
    }
    
    func hideChat() {
        
        rightSwipe.enabled = false
        leftSwipe.enabled = true
        
        //animate the hiding of the chat view
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.videoView!.frame = self.view.frame
            self.chatView!.frame.origin.x = CGRectGetMaxX(self.view.frame)
        }) { (finished) -> Void in
                //The chat view
                self.chatView!.stopDisplayingMessages()
                self.chatView!.removeFromSuperview()
                self.chatView = nil
        }
    }
    
    func handleQualityChange(sender : MenuItemView?) {
        if let text = sender?.title?.text, quality = StreamSourceQuality(rawValue: text) {
            var qualityIdentifier = "chunked"
            switch quality {
            case .Source:
                qualityIdentifier = "chunked"
            case .High:
                qualityIdentifier = "high"
            case .Medium:
                qualityIdentifier = "medium"
            case .Low:
                qualityIdentifier = "low"
            }
            if let streams = self.streams {
                for stream in streams {
                    if stream.quality == qualityIdentifier {
                        currentStreamVideo = stream
                        let streamAsset = AVURLAsset(URL: stream.url)
                        let streamItem = AVPlayerItem(asset: streamAsset)
                        self.videoPlayer?.replaceCurrentItemWithPlayerItem(streamItem)
                        dismissMenu()
                        return
                    }
                }
            }
        }
    }
    
    func pause() {
        if let player = self.videoPlayer {
            if player.rate == 1 {
                player.pause()
            } else {
                if let currentVideo = currentStreamVideo {
                    //do this to bring it back in sync
                    let streamAsset = AVURLAsset(URL: currentVideo.url)
                    let streamItem = AVPlayerItem(asset: streamAsset)
                    player.replaceCurrentItemWithPlayerItem(streamItem)
                }
                player.play()
            }
        }
    }
    
    func swipe(recognizer: UISwipeGestureRecognizer) {
        if recognizer.state == .Ended {
            if recognizer.direction == .Left {
                showChat()
            } else {
                hideChat()
            }
        }
    }
}
