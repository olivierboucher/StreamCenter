//
//  TopBarView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-15.

import UIKit
import Foundation

class TopBarView : UIVisualEffectView {
    private var titleLabel : UILabel!
    
    init (frame : CGRect, withMainTitle title : String, supplementalView: UIView? = nil) {
        let effect = UIBlurEffect(style: .Dark)
        super.init(effect: effect)
    
        //Place title
        self.titleLabel = UILabel(frame: CGRectZero)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.text = title
        self.titleLabel.font = UIFont(name: "Helvetica", size: 50)
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.adjustsFontSizeToFitWidth = true
        
        self.contentView.addSubview(self.titleLabel)
        
        if let supplementalView = supplementalView {
            let viewDict = ["title" : titleLabel, "supp" : supplementalView]
            self.contentView.addSubview(supplementalView)
            self.contentView.addConstraint(NSLayoutConstraint(item: supplementalView, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 0.275, constant: 1.0))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[supp]", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[title]|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            self.contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: supplementalView, attribute: .Trailing, multiplier: 1.0, constant: 15.0))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|->=10-[supp]->=10-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: supplementalView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        } else {
            let viewDict = ["title" : titleLabel]
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[title]|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[title]|", options: [], metrics: nil, views: viewDict))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
