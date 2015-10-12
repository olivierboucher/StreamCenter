//
//  TopBarView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-15.

import UIKit
import Foundation

class TopBarView : UIView {
    private var titleLabel : UILabel!
    
    init (frame : CGRect, withMainTitle title : String) {
        super.init(frame: frame)
    
        //Place title
        self.titleLabel = UILabel(frame: CGRectZero)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.text = title
        self.titleLabel.font = UIFont(name: "Helvetica", size: 50)
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.textColor = UIColor.whiteColor()
        
        self.addSubview(self.titleLabel)
        
        let viewDict = ["title" : titleLabel]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[title]|", options: [], metrics: nil, views: viewDict))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[title]|", options: [], metrics: nil, views: viewDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
