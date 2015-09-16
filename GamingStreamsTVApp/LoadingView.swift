//
//  LoadingView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-16.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import UIKit
import Foundation

class LoadingView : UIView {
    
    private var _label : UILabel?
    private var _activityIndicator : UIActivityIndicatorView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.layer.backgroundColor = UIColor(white: 0.25, alpha: 0.7).CGColor
        //self.
        
//        self.layer.borderColor = UIColor.redColor().CGColor
//        self.layer.borderWidth = 1
        
        let labelBounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.bounds.width, height: self.bounds.height * 0.3))
        self._label = UILabel(frame: labelBounds)
        self._label!.font = UIFont.systemFontOfSize(45)
        self._label!.text = "Loading..."
        self._label!.textColor = UIColor.whiteColor()
        self._label!.textAlignment = NSTextAlignment.Center
        
        let indicatorBounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.bounds.width, height: self.bounds.height * 0.7))
        self._activityIndicator = UIActivityIndicatorView(frame: indicatorBounds)
        self._activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self._activityIndicator?.sizeToFit()
        self._activityIndicator?.startAnimating()
        
        //Center the views correctly
        self._activityIndicator?.center = CGPoint(x: self.bounds.width/2, y: self._activityIndicator!.bounds.height/2)
        self._label?.center = CGPoint(x: self.bounds.width/2 + 10, y: self._activityIndicator!.bounds.height + self._label!.bounds.height/2)
        
        self.addSubview(self._activityIndicator!)
        self.addSubview(self._label!)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}