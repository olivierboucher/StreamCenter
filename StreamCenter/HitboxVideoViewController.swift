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
    private var modalMenu : ModalMenuView?
    
    private var media: HitboxMedia!
    private var streamVideos: [HitboxStreamVideo]?
    private var currentStreamVideo: HitboxStreamVideo?
    private var modalMenuOptions : [String : [MenuOption]]?
    
    
    private var chatView : HitboxChatView?
    
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Logger.Debug("Media transcoding: \(media.transcoding)")
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
        
        if let streams = self.streamVideos {
            var menuOptions = [MenuOption]()
            for stream in streams {
                menuOptions.append(MenuOption(title: stream.label, enabled: false, parameters: ["bitrate" : stream.bitrate], onClick: self.handleQualityChange))
            }
            self.modalMenuOptions = [
                "Live Chat" : [
                MenuOption(enabledTitle: "Turn off", disabledTitle: "Turn on", enabled: false, onClick:self.handleChatOnOff)
                ],
                "Quality" : menuOptions]
            //Gestures configuration
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
            longPressRecognizer.cancelsTouchesInView = true
            self.view.addGestureRecognizer(longPressRecognizer)
        }
        
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
    
    func itemFailed(notification: NSNotification) {
        Logger.Error("Item failed: \(notification)")
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
        
        HitboxChatAPI.getFirstAvailableWebSocket(){ socketURL, error in
            guard error == nil else {
                Logger.Error(error!.developerSuggestion)
                return
            }
            
            guard let socketURL = socketURL else {
                Logger.Error("Could not get a chat server socket url")
                return
            }
            
            if let url = NSURL(string: socketURL) {
                //The chat view
                self.chatView = HitboxChatView(frame: CGRect(x: self.view.bounds.width, y: 0, width: 400, height: self.view!.bounds.height), socketURL: url, channel: self.media, chatMessageDelegate: self)
                self.chatView!.startDisplayingMessages()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let modalMenu = self.modalMenu {
                        self.view.insertSubview(self.chatView!, belowSubview: modalMenu)
                    } else {
                        self.view.addSubview(self.chatView!)
                    }
                    
                    self.rightSwipe.enabled = true
                    self.leftSwipe.enabled = false
                    
                    //animate the showing of the chat view
                    UIView.animateWithDuration(0.5) { () -> Void in
                        self.chatView!.frame = CGRect(x: self.view.bounds.width - 400, y: 0, width: 400, height: self.view!.bounds.height)
                        if let videoView = self.videoView, frame = frame {
                            videoView.frame = frame
                        }
                    }
                })
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
    
    func swipe(recognizer: UISwipeGestureRecognizer) {
        if recognizer.state == .Ended {
            if recognizer.direction == .Left {
                showChat()
            } else {
                hideChat()
            }
        }
    }
    
    func handleQualityChange(sender : MenuItemView?) {
        
        if let bitrate = sender?.option.parameters?["bitrate"] as? Int {
            if let streamVideos = self.streamVideos {
                for stream in streamVideos {
                    if stream.bitrate == bitrate {
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
}

extension HitboxVideoViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        Logger.Debug("Value: \(textField.text)")
        guard let text = textField.text else {
            return
        }
        textField.text = nil
        self.chatView?.chatMgr?.sendMessage(text)
    }
    
}
