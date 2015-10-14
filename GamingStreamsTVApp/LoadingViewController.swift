//
//  LoadingViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-29.

import UIKit
import Foundation

//NOTE(Olivier):
//Swift doesn't provide any way to abstract a class like Java or C#
//This is not a protocol because I don't want to copy this code in each controller

class LoadingViewController : UIViewController {
    
    internal let TOP_BAR_HEIGHT : CGFloat = 100
    internal let ITEMS_INSETS_Y : CGFloat = 0
    internal let GAME_IMG_HEIGHT_RATIO : CGFloat = 1.39705882353 //Computed from sampled image from twitch api
    internal let STREAM_IMG_HEIGHT_RATIO : CGFloat = 1.777777777 //Computed from sampled image from twitch api
    
    internal var collectionView : UICollectionView!
    internal var topBar : TopBarView!
    
    internal var loadingView : LoadingView?
    internal var errorView : ErrorView?
    private var reloadLabel : UILabel?
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(white: 0.4, alpha: 1)
    }
    
    /*
    * displayLoadingView()
    *
    * Initializes a loading view in the center of the screen and displays it
    *
    */
    func displayLoadingView(loading: String = "Loading...")  {
        self.loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width/5, height: self.view.bounds.height/5), text: loading)
        self.loadingView?.center = self.view.center
        self.view.addSubview(self.loadingView!)
    }
    
    /*
    * removeLoadingView()
    *
    * Removes the loading view if existant
    *
    */
    func removeLoadingView() {
        if self.loadingView != nil {
            self.loadingView?.removeFromSuperview()
            self.loadingView = nil
        }
    }
    
    /*
    * displayErrorView(title : String)
    *
    * Initializes an error view in the center of the screen and displays it
    *
    */
    func displayErrorView(title : String) {
        self.errorView = ErrorView(dimension: 450, andTitle: title)
        self.errorView?.center = self.view.center
        self.view.addSubview(self.errorView!)
        
        self.reloadLabel = UILabel()
        self.reloadLabel?.text = "Press and hold to reload the content"
        self.reloadLabel?.font = self.reloadLabel?.font.fontWithSize(25)
        self.reloadLabel?.sizeToFit()
        self.reloadLabel?.center = CGPoint(x: CGRectGetMidX(self.errorView!.frame), y: CGRectGetMaxY(self.errorView!.frame))
        self.reloadLabel?.center.y += 10
        self.reloadLabel?.textColor = UIColor.whiteColor()
        self.view.addSubview(self.reloadLabel!)
        self.view.bringSubviewToFront(self.reloadLabel!)
        
        //Gestures configuration
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        longPressRecognizer.cancelsTouchesInView = true
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    /*
    * removeErrorView()
    *
    * Removes the error view if existant
    *
    */
    func removeErrorView() {
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
            self.errorView = nil
        }
        if self.reloadLabel != nil {
            self.reloadLabel?.removeFromSuperview()
            self.reloadLabel = nil
        }
    }
    
    /*
    *
    * Implement this on the child view controller to reload content if there was an error
    *
    */
    func reloadContent() {
        print("we are reloading the content now: \(self)")
    }
    
    /*
    * handleLongPress(recognizer: UILongPressGestureRecognizer)
    *
    * This is so that if the content doesn't load the first time around, we can load it again
    *
    */
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .Began {
            self.view.removeGestureRecognizer(recognizer)
            reloadContent()
        }
    }
}