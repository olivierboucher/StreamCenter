//
//  UILabel.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class ScrollingLabel: UIView {
    
    private var scrollSpeed = 0.5 {
        didSet {
            if scrollSpeed > 1 {
                scrollSpeed = 1
            } else if scrollSpeed < 0 {
                scrollSpeed = 0
            }
        }
    }
    private var textLayer = CATextLayer()
    private var gradientLayer = CAGradientLayer()
    private var isScrolling = false
    
    private var offset = CGFloat(0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        self.font = UIFont.systemFontOfSize(17)
        self.textColor = UIColor.blackColor()
        super.init(frame: frame)
        self.setupLayers()
    }
    
    convenience init(scrollSpeed speed: Double) {
        self.init(frame: CGRectZero)
        scrollSpeed = speed
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.font = UIFont.systemFontOfSize(17)
        self.textColor = UIColor.blackColor()
        super.init(coder: aDecoder)
        self.setupLayers()
    }
    
    func setupLayers() {
        self.clipsToBounds = true
        
        self.textLayer.string = "Hello World"
        self.textLayer.fontSize = 30
        self.textLayer.foregroundColor = UIColor.whiteColor().CGColor
        self.textLayer.frame = self.bounds
        self.textLayer.frame.size.width = 500
        self.textLayer.wrapped = false
        self.textLayer.alignmentMode = kCAAlignmentLeft
        self.layer.addSublayer(self.textLayer)
        
        self.gradientLayer.colors = [
            UIColor(white: 0.4, alpha: 0).CGColor,
            UIColor(white: 0.4, alpha: 0.9).CGColor,
            UIColor.whiteColor().CGColor,
            UIColor(white: 0.4, alpha: 0.9).CGColor,
            UIColor(white: 0.4, alpha: 0).CGColor
        ]
        self.gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        self.gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        self.gradientLayer.locations = [
            NSNumber(double: 0.0),
            NSNumber(double: 0.05),
            NSNumber(double: 0.5),
            NSNumber(double: 0.95),
            NSNumber(double: 1.0),
        ]
    }
    
    override func layoutSubviews() {
        self.textLayer.frame = self.bounds
        self.textLayer.frame.size.width = self.textLayer.preferredFrameSize().width
        self.gradientLayer.frame = self.bounds
    }
    
    /*
    * beginScrolling()
    *
    * tell the label to start scrolling
    *
    */
    func beginScrolling() {
        let bounds = self.bounds
        let size = textSize
        guard size.width > bounds.width && self.scrollSpeed > 0 else {
            return
        }
        let moveAmount = (size.width - bounds.width)
        let initialPoint = self.textLayer.position
        let animation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = 10 * (1.1 - scrollSpeed)
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: initialPoint)
        animation.toValue = NSValue(CGPoint: CGPoint(x: initialPoint.x - (moveAmount + 5), y: initialPoint.y))
        self.textLayer.addAnimation(animation, forKey: nil)
        self.layer.mask = self.gradientLayer
        isScrolling = true
    }
    
    /*
    * endScrolling()
    *
    * tell the label to stop scrolling
    *
    */
    func endScrolling() {
        if !isScrolling {
            return
        }
        self.textLayer.removeAllAnimations()
        self.layer.mask = nil
        isScrolling = false
    }
    
    var font: UIFont {
        didSet {
            textLayer.font = font.fontName
            textLayer.fontSize = font.pointSize
        }
    }
    
    var textColor: UIColor {
        didSet {
            textLayer.foregroundColor = textColor.CGColor
        }
    }
    
    var text: String? {
        didSet {
            self.textLayer.string = text
        }
    }
    
    var textSize: CGSize {
        get {
            return self.textLayer.preferredFrameSize()
        }
    }
}