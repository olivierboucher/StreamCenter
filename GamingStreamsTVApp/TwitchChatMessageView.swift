//
//  TwitchChatMessageView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-23.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import Foundation


class TwitchChatMessageView : UIView {
    let completeMessage : NSAttributedString
    
    init(message: TwitchChatMessage, width : CGFloat, position : CGPoint) {
        let maxSize = CGSize(width: width, height: 10000)
        let drawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin.union(NSStringDrawingOptions.UsesFontLeading)
        let size = message.completeMessage!.boundingRectWithSize(maxSize, options: drawingOptions, context: nil)
        self.completeMessage = message.completeMessage!
        
        super.init(frame: CGRect(origin: position, size: CGSize(width: width, height: size.height+10)))
        
        self.backgroundColor = UIColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        self.completeMessage = NSAttributedString(string: "")
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        completeMessage.drawInRect(rect)
    }
}
