//
//  TopBarView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import UIKit
import Foundation

class TopBarView : UIView {
    private var backButton : BackButton?
    private var titleLabel : UILabel?
    
    init (frame : CGRect, withMainTitle title : String, backButtonTitle backTitle : String, andBackButtonCallback callback : (() -> ())) {
        super.init(frame: frame)
        
        //Place title
        let titleBounds = CGRect(x: 0, y: 0, width: frame.size.width/2, height: frame.size.height)
        self.titleLabel = UILabel(frame: titleBounds)
        self.titleLabel?.text = title
        self.titleLabel?.font = UIFont(name: "Helvetica", size: 50)
        self.titleLabel?.textAlignment = NSTextAlignment.Center
        self.titleLabel?.textColor = UIColor.whiteColor()
        self.titleLabel?.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        self.addSubview(self.titleLabel!)
        
        //Place button
        let buttonBounds = CGRect(x: 20, y: frame.height/4, width : frame.size.width/4, height: frame.size.height/2)
        self.backButton = BackButton(frame: buttonBounds, withTitle: backTitle, andCallback: callback)
        //self.backButton?.layer.borderColor = UIColor.redColor().CGColor;
        //self.backButton?.layer.borderWidth = 1;
        
        self.addSubview(self.backButton!)
    }
    init (frame : CGRect, withMainTitle title : String) {
        super.init(frame: frame)
    
        //Place title
        let titleBounds = CGRect(x: 0, y: 0, width: frame.size.width/2, height: frame.size.height)
        self.titleLabel = UILabel(frame: titleBounds)
        self.titleLabel?.text = title
        self.titleLabel?.font = UIFont(name: "Helvetica", size: 50)
        self.titleLabel?.textAlignment = NSTextAlignment.Center
        self.titleLabel?.textColor = UIColor.whiteColor()
        self.titleLabel?.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        self.addSubview(self.titleLabel!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
