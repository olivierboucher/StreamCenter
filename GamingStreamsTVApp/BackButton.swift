//
//  BackButton.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import UIKit
import Foundation


class BackButton : UIView {
    
    private var gestureRecognizer : UIGestureRecognizer?
    private var label : UILabel?
    private var imageView : UIImageView?
    private var callback : (() -> ())?
    
    init(frame : CGRect, withTitle title : NSString, andCallback callback : (() -> ())) {
        super.init(frame: frame)
        
        //UI Configuration
        let font = UIFont.systemFontOfSize(30)
        let maxLabelSize = CGSize(width: frame.width * 0.9, height: frame.height)
        let labelBounds = CGRect(origin: CGPoint(x: 0,y: 0), size: maxLabelSize)
        
        self.label = UILabel(frame: labelBounds)
        self.label!.font = font
        self.label!.text = title as String
        self.label!.textColor = UIColor.whiteColor()
        self.label!.textAlignment = NSTextAlignment.Left
        //label.layer.borderColor = UIColor.redColor().CGColor;
        //label.layer.borderWidth = 1;
        
        self.imageView = UIImageView(frame: CGRect(x: 0,y: 0, width: frame.width * 0.1, height: frame.height))
        self.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView!.image = self.getBackImageOfColor(UIColor.whiteColor())
        //imageView.layer.borderColor = UIColor.greenColor().CGColor;
        //imageView.layer.borderWidth = 1;
        
        self.imageView!.center = CGPoint(x: self.imageView!.bounds.width/2, y: frame.origin.y)
        self.label!.center = CGPoint(x: self.imageView!.bounds.width + self.label!.bounds.width/2, y: frame.origin.y)
        
        //Gestures configuration
        self.gestureRecognizer = UITapGestureRecognizer(target: self, action: "handlePress")
        self.gestureRecognizer!.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)];
        self.addGestureRecognizer(self.gestureRecognizer!)
        //Callback attribution
        self.callback = callback
        
        self.addSubview(self.imageView!)
        self.addSubview(self.label!)
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
                self.label!.textColor = UIColor.blackColor()
                self.imageView!.image = self.getBackImageOfColor(UIColor.blackColor())
                
                self.label!.font = self.label!.font.fontWithSize(40)
                self.imageView!.frame = CGRect(x: 0, y: 0, width: self.imageView!.bounds.width * 1.25, height: self.imageView!.bounds.height * 1.25)
                self.imageView!.center = CGPoint(x: self.imageView!.bounds.width/2, y: self.frame.origin.y)
                self.label!.center = CGPoint(x: self.imageView!.bounds.width + self.label!.bounds.width/2, y: self.frame.origin.y)
                
                self.layoutIfNeeded()
                
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                self.label!.textColor = UIColor.whiteColor()
                self.imageView!.image = self.getBackImageOfColor(UIColor.whiteColor())
                
                self.label!.font = self.label!.font.fontWithSize(30)
                self.imageView!.frame = CGRect(x: 0, y: 0, width: self.imageView!.bounds.width / 1.25, height: self.imageView!.bounds.height / 1.25)
                self.imageView!.center = CGPoint(x: self.imageView!.bounds.width/2, y: self.frame.origin.y)
                self.label!.center = CGPoint(x: self.imageView!.bounds.width + self.label!.bounds.width/2, y: self.frame.origin.y)
                
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
        
    }
    
    func handlePress() {
        self.callback!()
    }
}
