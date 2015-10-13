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
    
    private var scrollSpeed = CGFloat(0.5)
    private var textLayer = CATextLayer()
    private var isAnimating = false
    
    private var offset = CGFloat(0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        self.font = UIFont.systemFontOfSize(17)
        self.textColor = UIColor.blackColor()
        super.init(frame: frame)
        self.setupTextLayer()
    }
    
    convenience init(scrollSpeed speed: CGFloat) {
        self.init(frame: CGRectZero)
        scrollSpeed = speed
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.font = UIFont.systemFontOfSize(17)
        self.textColor = UIColor.blackColor()
        super.init(coder: aDecoder)
        self.setupTextLayer()
    }
    
    func setupTextLayer() {
        self.clipsToBounds = true
        self.textLayer.string = "Hello World"
        self.textLayer.fontSize = 30
        self.textLayer.foregroundColor = UIColor.whiteColor().CGColor
        self.textLayer.frame = self.bounds
        self.textLayer.frame.size.width = 500
        self.textLayer.wrapped = false
        self.textLayer.alignmentMode = kCAAlignmentLeft
        self.layer.addSublayer(self.textLayer)
    }
    
    override func layoutSubviews() {
        print(self.frame)
        self.textLayer.frame = self.bounds
        self.textLayer.frame.size.width = 500
    }
    
    /*
    * beginScrolling()
    *
    * tell the label to start scrolling
    *
    */
    func beginScrolling() {
        let bounds = self.bounds
        guard let size = textSize where size.width > bounds.width && self.scrollSpeed > 0 else {
            return
        }
        let moveAmount = (size.width - bounds.width)
        let initialPoint = self.textLayer.position
        let animation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = max(2.5, (2.5 / 150) * Double(moveAmount) / 0.5)
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: initialPoint)
        animation.toValue = NSValue(CGPoint: CGPoint(x: initialPoint.x - (moveAmount + 5), y: initialPoint.y))
        self.textLayer.addAnimation(animation, forKey: nil)
        isAnimating = true
    }
    
    /*
    * endScrolling()
    *
    * tell the label to stop scrolling
    *
    */
    func endScrolling() {
        self.textLayer.removeAllAnimations()
        isAnimating = false
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
    
    var textSize: CGSize? {
        get {
            return self.textLayer.preferredFrameSize()
        }
    }
    
//    var realSize: CGSize? {
//        guard let text = text else {
//            return nil
//        }
//        let attrString = CFAttributedStringCreate(nil, text, [NSFontAttributeName : font] as [String : AnyObject])
//        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
//        let targetSize = CGSizeMake(CGFloat.max, self.bounds.height);
//        let fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, text.characters.count), nil, targetSize, nil)
//        return fitSize
//    }
    
}