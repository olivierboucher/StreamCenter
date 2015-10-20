//
//  TopBarView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-15.

import UIKit
import Foundation

class TopBarView : UIVisualEffectView {
    private var titleView : UIView!
    
    init (frame : CGRect, withMainTitle title : String?, centerView: UIView? = nil, leftView: UIView? = nil, rightView: UIView? = nil) {
        let effect = UIBlurEffect(style: .Dark)
        super.init(effect: effect)
    
        if let centerView = centerView {
            //just make sure that translatesAutoresizingMaskIntoConstraints is set to false because it is required to be false for autolayout
            centerView.translatesAutoresizingMaskIntoConstraints = false
            self.titleView = centerView
        } else {
            //Place title
            let titleLabel = UILabel(frame: CGRectZero)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = title
            titleLabel.font = UIFont(name: "Helvetica", size: 50)
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.adjustsFontSizeToFitWidth = true
            
            self.titleView = titleLabel
        }
        
        self.contentView.addSubview(self.titleView)
        
        if let leftView = leftView {
            leftView.translatesAutoresizingMaskIntoConstraints = false
            let viewDict = ["title" : titleView, "left" : leftView]
            self.contentView.addSubview(leftView)
            self.contentView.addConstraint(NSLayoutConstraint(item: leftView, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 0.275, constant: 1.0))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[left]->=15-[title]", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|->=10-[left]->=10-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: leftView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        }
        
        if let rightView = rightView {
            rightView.translatesAutoresizingMaskIntoConstraints = false
            let viewDict = ["title" : titleView, "right" : rightView]
            self.contentView.addSubview(rightView)
            self.contentView.addConstraint(NSLayoutConstraint(item: rightView, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 0.275, constant: 1.0))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[title]->=15-[right]-30-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|->=10-[right]->=10-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: rightView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        }
        
        let viewDict = ["title" : titleView]
        if leftView == nil && rightView == nil {
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[title]|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[title]-10-|", options: [], metrics: nil, views: viewDict))
        } else {
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[title]-10-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: self.titleView, attribute: .CenterX, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
