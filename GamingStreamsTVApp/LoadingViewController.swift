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
    
    internal var collectionView : UICollectionView!
    internal var topBar : TopBarView!
    
    internal var loadingView : LoadingView?
    internal var errorView : ErrorView?
    private var reloadButton : UIButton?
    
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
        if((self.loadingView != nil) && (self.loadingView!.isDescendantOfView(self.view))){
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
        let errorViewFrame = CGRect(x: 0, y: 0, width: 300, height: 300)
        self.errorView = ErrorView(frame: errorViewFrame, andTitle: title)
        self.errorView?.center = self.view.center
        self.view.addSubview(self.errorView!)
        
        self.reloadButton = UIButton(frame: CGRectMake(0, 0, 300, 20))
        self.reloadButton?.center = self.view.center
        self.reloadButton?.center.y += 200
        self.reloadButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        //just for debugging
//        self.reloadButton?.setTitleColor(UIColor.redColor(), forState: .Focused)
        self.reloadButton?.setTitle("Reload", forState: .Normal)
        self.reloadButton?.addTarget(self, action: Selector("reloadContent"), forControlEvents: .PrimaryActionTriggered)
        self.view.addSubview(self.reloadButton!)
        
        self.view.setNeedsFocusUpdate()
    }
    
    /*
    * removeErrorView()
    *
    * Removes the error view if existant
    *
    */
    func removeErrorView() {
        if((self.errorView != nil) && (self.errorView!.isDescendantOfView(self.view))){
            self.errorView?.removeFromSuperview()
            self.errorView = nil
        }
        if((self.reloadButton != nil) && (self.reloadButton!.isDescendantOfView(self.view))){
            self.reloadButton?.removeFromSuperview()
            self.reloadButton = nil
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
}