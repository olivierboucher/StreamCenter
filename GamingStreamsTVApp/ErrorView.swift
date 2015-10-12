//
//  ErrorView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-16.

import UIKit
import Foundation

class ErrorView : UIView {
    
    private var imageView : UIImageView!
    private var label : UILabel!
    
    init(frame: CGRect, andTitle title : String) {
        super.init(frame: frame)
        
        let imageViewBounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.width/1.333333333)
        imageView = UIImageView(frame: imageViewBounds)
        imageView.image = getErrorImageOfColor(UIColor.whiteColor())
        
        let labelBounds = CGRect(x: 0, y: imageViewBounds.height, width: imageViewBounds.width, height: self.bounds.height - imageViewBounds.height)
        label = UILabel(frame: labelBounds)
        label.text = title
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.font = label?.font.fontWithSize(25)
        
        self.addSubview(imageView)
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func getErrorImageOfColor(color : UIColor) -> UIImage {
        
        let size = CGSizeMake(300, 225)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()

        let pathRef = CGPathCreateMutable()
        CGPathMoveToPoint(pathRef, nil, 215.577, 189.5)
        CGPathAddLineToPoint(pathRef, nil, 243.506, 189.5)
        CGPathAddCurveToPoint(pathRef, nil, 273.878, 189.5, 298.5, 164.814, 298.5, 134.5)
        CGPathAddCurveToPoint(pathRef, nil, 298.5, 111.439, 284.346, 91.694, 264.211, 83.521)
        CGPathAddLineToPoint(pathRef, nil, 264.211, 83.521)
        CGPathAddCurveToPoint(pathRef, nil, 258.46, 56.095, 234.135, 35.5, 205, 35.5)
        CGPathAddCurveToPoint(pathRef, nil, 195.508, 35.5, 186.527, 37.686, 178.532, 41.582)
        CGPathAddCurveToPoint(pathRef, nil, 165.303, 18.246, 140.24, 2.5, 111.5, 2.5)
        CGPathAddCurveToPoint(pathRef, nil, 68.974, 2.5, 34.5, 36.974, 34.5, 79.5)
        CGPathAddCurveToPoint(pathRef, nil, 34.5, 81.02, 34.544, 82.529, 34.631, 84.027)
        CGPathAddLineToPoint(pathRef, nil, 34.631, 84.027)
        CGPathAddCurveToPoint(pathRef, nil, 15.136, 92.498, 1.5, 111.94, 1.5, 134.5)
        CGPathAddCurveToPoint(pathRef, nil, 1.5, 164.876, 26.057, 189.5, 56.494, 189.5)
        CGPathAddLineToPoint(pathRef, nil, 84.423, 189.5)
        CGPathAddLineToPoint(pathRef, nil, 150, 79.5)
        CGPathAddLineToPoint(pathRef, nil, 215.577, 189.5)
        CGPathAddLineToPoint(pathRef, nil, 215.577, 189.5)
        CGPathAddLineToPoint(pathRef, nil, 215.577, 189.5)
        CGPathCloseSubpath(pathRef)
        CGPathMoveToPoint(pathRef, nil, 150, 101.5)
        CGPathAddLineToPoint(pathRef, nil, 221.5, 222.5)
        CGPathAddLineToPoint(pathRef, nil, 78.5, 222.5)
        CGPathAddLineToPoint(pathRef, nil, 150, 101.5)
        CGPathAddLineToPoint(pathRef, nil, 150, 101.5)
        CGPathCloseSubpath(pathRef)
        CGPathMoveToPoint(pathRef, nil, 144.5, 145.5)
        CGPathAddLineToPoint(pathRef, nil, 144.5, 178.5)
        CGPathAddLineToPoint(pathRef, nil, 155.5, 178.5)
        CGPathAddLineToPoint(pathRef, nil, 155.5, 145.5)
        CGPathAddLineToPoint(pathRef, nil, 144.5, 145.5)
        CGPathAddLineToPoint(pathRef, nil, 144.5, 145.5)
        CGPathCloseSubpath(pathRef)
        CGPathMoveToPoint(pathRef, nil, 144.5, 189.5)
        CGPathAddLineToPoint(pathRef, nil, 144.5, 200.5)
        CGPathAddLineToPoint(pathRef, nil, 155.5, 200.5)
        CGPathAddLineToPoint(pathRef, nil, 155.5, 189.5)
        CGPathAddLineToPoint(pathRef, nil, 144.5, 189.5)
        CGPathAddLineToPoint(pathRef, nil, 144.5, 189.5)
        CGPathCloseSubpath(pathRef)
        
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextAddPath(ctx, pathRef)
        CGContextFillPath(ctx)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
}