//
//  ErrorView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-16.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import UIKit
import Foundation

class ErrorView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func getErrorImageOfColor(color : UIColor) -> UIImage {
        
        let size = CGSizeMake(51, 38)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        
        let pathRef = CGPathCreateMutable()
        CGPathMoveToPoint(pathRef, nil, 17.848, 30.1)
        CGPathAddLineToPoint(pathRef, nil, 9.78, 30.1)
        CGPathAddCurveToPoint(pathRef, nil, 5.701, 30.1, 2.375, 26.787, 2.375, 22.7)
        CGPathAddCurveToPoint(pathRef, nil, 2.375, 19.194, 4.826, 16.247, 8.112, 15.489)
        CGPathAddLineToPoint(pathRef, nil, 8.112, 15.489)
        CGPathAddCurveToPoint(pathRef, nil, 7.989, 14.828, 7.925, 14.147, 7.925, 13.45)
        CGPathAddCurveToPoint(pathRef, nil, 7.925, 7.32, 12.895, 2.35, 19.025, 2.35)
        CGPathAddCurveToPoint(pathRef, nil, 23.864, 2.35, 27.979, 5.446, 29.499, 9.765)
        CGPathAddCurveToPoint(pathRef, nil, 30.931, 8.599, 32.759, 7.9, 34.75, 7.9)
        CGPathAddCurveToPoint(pathRef, nil, 39.113, 7.9, 42.692, 11.256, 43.046, 15.528)
        CGPathAddLineToPoint(pathRef, nil, 43.046, 15.528)
        CGPathAddCurveToPoint(pathRef, nil, 46.247, 16.342, 48.625, 19.244, 48.625, 22.7)
        CGPathAddCurveToPoint(pathRef, nil, 48.625, 26.779, 45.31, 30.1, 41.22, 30.1)
        CGPathAddLineToPoint(pathRef, nil, 33.152, 30.1)
        CGPathAddLineToPoint(pathRef, nil, 25.5, 17.15)
        CGPathAddLineToPoint(pathRef, nil, 17.848, 30.1)
        CGPathAddLineToPoint(pathRef, nil, 17.848, 30.1)
        CGPathAddLineToPoint(pathRef, nil, 17.848, 30.1)
        CGPathCloseSubpath(pathRef)
        CGPathMoveToPoint(pathRef, nil, 34.245, 31.95)
        CGPathAddLineToPoint(pathRef, nil, 41.226, 31.95)
        CGPathAddCurveToPoint(pathRef, nil, 46.334, 31.95, 50.475, 27.798, 50.475, 22.7)
        CGPathAddCurveToPoint(pathRef, nil, 50.475, 18.822, 48.095, 15.501, 44.708, 14.126)
        CGPathAddLineToPoint(pathRef, nil, 44.708, 14.126)
        CGPathAddCurveToPoint(pathRef, nil, 43.741, 9.514, 39.65, 6.05, 34.75, 6.05)
        CGPathAddCurveToPoint(pathRef, nil, 33.154, 6.05, 31.643, 6.418, 30.299, 7.073)
        CGPathAddCurveToPoint(pathRef, nil, 28.074, 3.148, 23.859, 0.5, 19.025, 0.5)
        CGPathAddCurveToPoint(pathRef, nil, 11.873, 0.5, 6.075, 6.298, 6.075, 13.45)
        CGPathAddCurveToPoint(pathRef, nil, 6.075, 13.706, 6.082, 13.959, 6.097, 14.211)
        CGPathAddLineToPoint(pathRef, nil, 6.097, 14.211)
        CGPathAddCurveToPoint(pathRef, nil, 2.818, 15.636, 0.525, 18.906, 0.525, 22.7)
        CGPathAddCurveToPoint(pathRef, nil, 0.525, 27.809, 4.655, 31.95, 9.774, 31.95)
        CGPathAddLineToPoint(pathRef, nil, 16.755, 31.95)
        CGPathAddLineToPoint(pathRef, nil, 13.475, 37.5)
        CGPathAddLineToPoint(pathRef, nil, 37.525, 37.5)
        CGPathAddLineToPoint(pathRef, nil, 34.245, 31.95)
        CGPathAddLineToPoint(pathRef, nil, 34.245, 31.95)
        CGPathAddLineToPoint(pathRef, nil, 34.245, 31.95)
        CGPathCloseSubpath(pathRef)
        CGPathMoveToPoint(pathRef, nil, 25.5, 20.85)
        CGPathAddLineToPoint(pathRef, nil, 34.287, 35.65)
        CGPathAddLineToPoint(pathRef, nil, 16.713, 35.65)
        CGPathAddLineToPoint(pathRef, nil, 25.5, 20.85)
        CGPathAddLineToPoint(pathRef, nil, 25.5, 20.85)
        CGPathCloseSubpath(pathRef)
        CGPathMoveToPoint(pathRef, nil, 24.575, 24.55)
        CGPathAddLineToPoint(pathRef, nil, 24.575, 30.1)
        CGPathAddLineToPoint(pathRef, nil, 26.425, 30.1)
        CGPathAddLineToPoint(pathRef, nil, 26.425, 24.55)
        CGPathAddLineToPoint(pathRef, nil, 24.575, 24.55)
        CGPathAddLineToPoint(pathRef, nil, 24.575, 24.55)
        CGPathCloseSubpath(pathRef)
        CGPathMoveToPoint(pathRef, nil, 24.575, 31.95)
        CGPathAddLineToPoint(pathRef, nil, 24.575, 33.8)
        CGPathAddLineToPoint(pathRef, nil, 26.425, 33.8)
        CGPathAddLineToPoint(pathRef, nil, 26.425, 31.95)
        CGPathAddLineToPoint(pathRef, nil, 24.575, 31.95)
        CGPathAddLineToPoint(pathRef, nil, 24.575, 31.95)
        CGPathCloseSubpath(pathRef)
        
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextAddPath(ctx, pathRef)
        CGContextFillPath(ctx)
        
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img;
    }
}