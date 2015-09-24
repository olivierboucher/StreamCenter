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
    
    init(message: TwitchChatMessage, width : CGFloat, position : CGPoint) {
        let maxSize = CGSize(width: width, height: 10000)
        let drawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin.union(NSStringDrawingOptions.UsesFontLeading)
        let size = message.completeMessage!.boundingRectWithSize(maxSize, options: drawingOptions, context: nil)
        
        super.init(frame: CGRect(origin: position, size: CGSize(width: width, height: size.height)))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
