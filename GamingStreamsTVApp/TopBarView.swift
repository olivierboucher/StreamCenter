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
    private var _backButton : BackButton?
    private var _titleLabel : UILabel?
    
    init (frame : CGRect, withMainTitle title : String, andBackButtonTitle backButtonTitle : String) {
        super.init(frame: frame)
        
        //Place title
        let titleBounds = CGRect(x: 0, y: 0, width: frame.size.width/2, height: frame.size.height)
        self._titleLabel = UILabel(frame: titleBounds)
        self._titleLabel?.text = title
        self._titleLabel?.font = UIFont(name: "Helvetica", size: 50)
        self._titleLabel?.textAlignment = NSTextAlignment.Center
        self._titleLabel?.textColor = UIColor.whiteColor()
        self._titleLabel?.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        self.addSubview(self._titleLabel!)
        
        //Place button
        let buttonBounds = CGRect(x: 20, y: frame.height/4, width : frame.size.width/4, height: frame.size.height/2)
        self._backButton = BackButton(frame: buttonBounds, withTitle: backButtonTitle)
        //self._backButton?.layer.borderColor = UIColor.redColor().CGColor;
        //self._backButton?.layer.borderWidth = 1;
        
        self.addSubview(self._backButton!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
