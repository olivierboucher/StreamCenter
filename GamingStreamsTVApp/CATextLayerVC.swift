//
//  CATextLayerVC.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-24.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import UIKit
import Foundation

class CATextLayerVC : CATextLayer {
    
    override init() {
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(layer: aDecoder)
    }
    
    override func drawInContext(ctx: CGContext) {
        let height = self.bounds.size.height
        let fontSize = self.fontSize
        let yDiff = (height-fontSize)/2 - fontSize/10
        
        CGContextSaveGState(ctx)
        CGContextTranslateCTM(ctx, 0.0, yDiff)
        super.drawInContext(ctx)
        CGContextRestoreGState(ctx)
    }
}