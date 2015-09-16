//
//  BackButton.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import QuartzCore
import UIKit
import Foundation


class BackButton : UIView {
    
    private var _gestureRecognizer : UIGestureRecognizer?
    private var _label : UILabel?
    private var _imageView : UIImageView?
    private var _callback : (() -> ())?
    
    init(frame : CGRect, withTitle title : NSString, andCallback callback : (() -> ())) {
        super.init(frame: frame)
        
        //UI Configuration
        let font = UIFont.systemFontOfSize(30)
        let maxLabelSize = CGSize(width: frame.width * 0.9, height: frame.height)
        let labelBounds = CGRect(origin: CGPoint(x: 0,y: 0), size: maxLabelSize)
        
        _label = UILabel(frame: labelBounds)
        _label!.font = font
        _label!.text = title as String
        _label!.textColor = UIColor.whiteColor()
        _label!.textAlignment = NSTextAlignment.Left
        //label.layer.borderColor = UIColor.redColor().CGColor;
        //label.layer.borderWidth = 1;
        
        _imageView = UIImageView(frame: CGRect(x: 0,y: 0, width: frame.width * 0.1, height: frame.height))
        _imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        _imageView!.image = self.getBackImageOfColor(UIColor.whiteColor())
        //imageView.layer.borderColor = UIColor.greenColor().CGColor;
        //imageView.layer.borderWidth = 1;
        
        _imageView!.center = CGPoint(x: _imageView!.bounds.width/2, y: frame.origin.y)
        _label!.center = CGPoint(x: _imageView!.bounds.width + _label!.bounds.width/2, y: frame.origin.y)
        
        //Gestures configuration
        self._gestureRecognizer = UIGestureRecognizer(target: self, action: "tapped:")
        self._gestureRecognizer!.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)];
        self.addGestureRecognizer(self._gestureRecognizer!)
        //Callback attribution
        self._callback = callback
        
        self.addSubview(_imageView!)
        self.addSubview(_label!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func getBackImageOfColor(color : UIColor) -> UIImage {
        
        let size = CGSizeMake(50, 75);
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let ctx = UIGraphicsGetCurrentContext();
        
        let pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, nil, 47.5, 7.594);
        CGPathAddLineToPoint(pathRef, nil, 39.93, -0);
        CGPathAddLineToPoint(pathRef, nil, 2.5, 37.5);
        CGPathAddLineToPoint(pathRef, nil, 2.5, 37.5);
        CGPathAddLineToPoint(pathRef, nil, 2.5, 37.5);
        CGPathAddLineToPoint(pathRef, nil, 39.93, 75);
        CGPathAddLineToPoint(pathRef, nil, 47.5, 67.406);
        CGPathAddLineToPoint(pathRef, nil, 17.664, 37.5);
        CGPathCloseSubpath(pathRef);
        
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextAddPath(ctx, pathRef);
        CGContextFillPath(ctx);
        
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img;
    }
    
    override func canBecomeFocused() -> Bool {
        return true;
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        if(context.nextFocusedView == self){
            coordinator.addCoordinatedAnimations({
                self._label!.textColor = UIColor.blackColor()
                self._imageView!.image = self.getBackImageOfColor(UIColor.blackColor())
                
                self._label!.font = self._label!.font.fontWithSize(40)
                self._imageView!.frame = CGRect(x: 0, y: 0, width: self._imageView!.bounds.width * 1.25, height: self._imageView!.bounds.height * 1.25)
                self._imageView!.center = CGPoint(x: self._imageView!.bounds.width/2, y: self.frame.origin.y)
                self._label!.center = CGPoint(x: self._imageView!.bounds.width + self._label!.bounds.width/2, y: self.frame.origin.y)
                
                self.layoutIfNeeded()
                
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                self._label!.textColor = UIColor.whiteColor()
                self._imageView!.image = self.getBackImageOfColor(UIColor.whiteColor())
                
                self._label!.font = self._label!.font.fontWithSize(30)
                self._imageView!.frame = CGRect(x: 0, y: 0, width: self._imageView!.bounds.width / 1.25, height: self._imageView!.bounds.height / 1.25)
                self._imageView!.center = CGPoint(x: self._imageView!.bounds.width/2, y: self.frame.origin.y)
                self._label!.center = CGPoint(x: self._imageView!.bounds.width + self._label!.bounds.width/2, y: self.frame.origin.y)
                
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
        
    }
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        for item in presses
        {
            if item.type == UIPressType.Select
            {
                self._callback!()
                break;
            }
        }
    }
}
