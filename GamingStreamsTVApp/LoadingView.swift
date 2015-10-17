//
//  LoadingView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-16.

import UIKit
import Foundation

class LoadingView : UIView {
    
    private var label : UILabel!
    private var activityIndicator : UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let labelBounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.bounds.width, height: self.bounds.height * 0.3))
        self.label = UILabel(frame: labelBounds)
        self.label.font = UIFont.systemFontOfSize(45)
        self.label.text = "Loading..."
        self.label.textColor = UIColor.whiteColor()
        self.label.textAlignment = NSTextAlignment.Center
        
        let indicatorBounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.bounds.width, height: self.bounds.height * 0.7))
        self.activityIndicator = UIActivityIndicatorView(frame: indicatorBounds)
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator.sizeToFit()
        self.activityIndicator.startAnimating()
        
        //Center the views correctly
        self.activityIndicator.center = CGPoint(x: self.bounds.width/2, y: self.activityIndicator.bounds.height/2)
        self.label.center = CGPoint(x: self.bounds.width/2 + 10, y: self.activityIndicator.bounds.height + self.label!.bounds.height/2)
        
        self.addSubview(self.activityIndicator)
        self.addSubview(self.label)
    }
    
    convenience init(frame: CGRect, text: String) {
        self.init(frame: frame)
        self.label.text = text
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}