//
//  TopBarView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-15.

import UIKit
import Foundation

class TopBarView : UIView {
    private var titleLabel : UILabel?
    
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
