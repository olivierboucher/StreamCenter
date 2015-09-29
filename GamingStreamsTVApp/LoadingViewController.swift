//
//  LoadingViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-29.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import Foundation

//NOTE(Olivier):
//Swift doesn't provide any way to abstract a class like Java or C#
//This is not a protocol because I don't want to copy this code in each controller

class LoadingViewController : UIViewController {
    internal var loadingView : LoadingView?
    internal var errorView : ErrorView?
    
    
    func displayLoadingView()  {
        self.loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width/5, height: self.view.bounds.height/5))
        self.loadingView?.center = self.view.center
        self.view.addSubview(self.loadingView!)
    }
    
    func removeLoadingView() {
        if((self.loadingView != nil) && (self.loadingView!.isDescendantOfView(self.view))){
            self.loadingView?.removeFromSuperview()
            self.loadingView = nil
        }
    }
    
    func displayErrorView(title : String) {
        let errorViewFrame = CGRect(x: 0, y: 0, width: 300, height: 300)
        self.errorView = ErrorView(frame: errorViewFrame, andTitle: title)
        self.errorView?.center = self.view.center
        self.view.addSubview(self.errorView!)
    }
    
    func removeErrorView() {
        if((self.errorView != nil) && (self.errorView!.isDescendantOfView(self.view))){
            self.errorView?.removeFromSuperview()
            self.errorView = nil
        }
    }
}