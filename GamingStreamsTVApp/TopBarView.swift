//
//  TopBarView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-15.

import UIKit
import Foundation

class TopBarView : UIVisualEffectView {
    private var titleLabel : UILabel!
    
    init (frame : CGRect, withMainTitle title : String, leftView: UIView? = nil, rightView: UIView? = nil) {
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
        
        if let leftView = leftView {
            let viewDict = ["title" : titleLabel, "left" : leftView]
            self.contentView.addSubview(leftView)
            self.contentView.addConstraint(NSLayoutConstraint(item: leftView, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 0.275, constant: 1.0))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[left]->=15-[title]", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|->=10-[left]->=10-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: leftView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        }
        
        if let rightView = rightView {
            let viewDict = ["title" : titleLabel, "right" : rightView]
            self.contentView.addSubview(rightView)
            self.contentView.addConstraint(NSLayoutConstraint(item: rightView, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 0.275, constant: 1.0))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[title]->=15-[right]-30-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|->=10-[right]->=10-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: rightView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        }
        
        let viewDict = ["title" : titleLabel]
        if leftView == nil && rightView == nil {
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[title]|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[title]|", options: [], metrics: nil, views: viewDict))
        } else {
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[title]|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
