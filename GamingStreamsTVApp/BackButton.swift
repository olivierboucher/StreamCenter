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
    
    init(frame : CGRect, withTitle title : NSString) {
        super.init(frame: frame)
        
        let font = UIFont(name: "Helvetica", size: 30)
        let maxLabelSize = CGSize(width: frame.width * 0.9, height: frame.height)
        let drawingOptions = NSStringDrawingOptions.TruncatesLastVisibleLine
        let attributes = [NSFontAttributeName : font!]
        let labelBounds = title.boundingRectWithSize(maxLabelSize, options: drawingOptions, attributes: attributes, context: nil)
        
        let label = UILabel(frame: labelBounds)
        label.font = font
        label.text = title as String
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Left
        //label.layer.borderColor = UIColor.redColor().CGColor;
        //label.layer.borderWidth = 1;
        
        let imageView = UIImageView(frame: CGRect(x: 0,y: 0, width: frame.width * 0.1, height: frame.height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self.getBackImageOfColor(UIColor.whiteColor())
        //imageView.layer.borderColor = UIColor.greenColor().CGColor;
        //imageView.layer.borderWidth = 1;
        
        imageView.center = CGPoint(x: imageView.bounds.width/2, y: frame.origin.y)
        label.center = CGPoint(x: imageView.bounds.width + label.bounds.width/2, y: frame.origin.y)
        
        self.addSubview(imageView)
        self.addSubview(label)
        
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
}