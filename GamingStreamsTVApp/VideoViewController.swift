//
//  VideoViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.

import AVKit
import UIKit
import Foundation

enum StreamSourceQuality: String {
    case Chunked = "Source"
    case High
    case Medium
    case Low
}

class VideoViewController : UIViewController {
    private var longPressRecognizer : UILongPressGestureRecognizer?
    private var videoView : VideoView?
    private var videoPlayer : AVPlayer?
    private var streams : [TwitchStreamVideo]?
    private var currentStream : TwitchStream?
    private var chatView : TwitchChatView?
    private var modalMenu : ModalMenuView?
    private var modalMenuOptions : Dictionary<String, Array<MenuOption>>?
    
    /*
    * init(stream : TwitchStream)
    *
    * Initializes the controller, it's gesture recognizer and modal menu.
    * Loads and prepare the video asset from the stream for display
    */
    convenience init(stream : TwitchStream){
        self.init(nibName: nil, bundle: nil)
        self.currentStream = stream;
        
        self.view.backgroundColor = UIColor.blackColor()
        
        //Gestures configuration
        self.longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress")
        self.longPressRecognizer?.cancelsTouchesInView = false
        self.view.addGestureRecognizer(self.longPressRecognizer!)
        
        //Modal menu options
        self.modalMenuOptions = [
            "Live Chat" : [
                MenuOption(enabledTitle: "Turn off", disabledTitle: "Turn on", enabled: false, onClick:self.handleChatOnOff)
            ],
            "Stream Quality" : [
                MenuOption(title: "Source", enabled: false, onClick: self.handleQualityChange),
                MenuOption(title: "High", enabled: false, onClick: self.handleQualityChange),
                MenuOption(title: "Medium", enabled: false, onClick: self.handleQualityChange),
                MenuOption(title: "Low", enabled: false, onClick: self.handleQualityChange)
            ]
        ]
        
        TwitchApi.getStreamsForChannel(self.currentStream!.channel.name) {
            (streams, error) in
            
            if(error != nil) {
                NSLog("Error getting stream video data")
            }
            
            if let streams = streams {
                self.streams = streams
                let streamObject = streams[0]
                let streamAsset = AVURLAsset(URL: streamObject.url!)
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
        
        if self.chatView != nil && self.view.subviews.contains(self.chatView!) {
            self.chatView!.stopDisplayingMessages()
            self.chatView!.removeFromSuperview()
            self.chatView = nil
        }
        
        self.videoView!.removeFromSuperview()
        self.videoView!.setPlayer(nil)
        self.videoView = nil
        self.videoPlayer = nil

        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func handleLongPress() {
        if self.longPressRecognizer!.state == UIGestureRecognizerState.Began {
            if self.modalMenu == nil {
                modalMenu = ModalMenuView(frame: self.view.bounds,
                    options: self.modalMenuOptions!,
                    size: CGSize(width: self.view.bounds.width/3, height: self.view.bounds.height/1.5))
                
                modalMenu!.center = self.view.center
                
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleMenuPress")
                gestureRecognizer.allowedPressTypes = [UIPressType.Menu.rawValue]
                gestureRecognizer.cancelsTouchesInView = false
                
                modalMenu?.addGestureRecognizer(gestureRecognizer)
            }
            
            self.view.addSubview(self.modalMenu!)
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
                modalMenu.removeFromSuperview()
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
                    
                    //The chat view
                    self.chatView!.stopDisplayingMessages()
                    self.chatView!.removeFromSuperview()
                    self.chatView = nil
                    
                    //Resize video view
                    self.videoView!.frame = self.view.frame
                    
                    //Set the menu option accordingly
                    menuItem.setOptionEnabled(false)
                }
                else {                              //                      Turn chat on
                    
                    //Resize video view
                    var frame = self.videoView!.frame
                    frame.size.width -= 400
                    frame.size.height -= 225
                    frame.origin.y += (225/2)
                    
                    self.videoView!.frame = frame
                    
                    //The chat view
                    self.chatView = TwitchChatView(frame: CGRect(x: self.view.bounds.width - 400, y: 0, width: 400, height: self.view!.bounds.height), channel: self.currentStream!.channel)
                    self.chatView!.startDisplayingMessages()
                    self.view.insertSubview(self.chatView!, belowSubview: self.modalMenu!)
                    
                    //Set the menu option accordingly
                    menuItem.setOptionEnabled(true)
                }
            }
        })
    }
    
    func handleQualityChange(sender : MenuItemView?) {
        
        
        
        
    }
}
