//
//  ChatTopView.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/21/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class ChatTopView: UILabel {
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        
        text = title
        
        adjustsFontSizeToFitWidth = true
        
        textColor = UIColor.whiteColor()
        backgroundColor = UIColor(hexString: "#555555")
        textAlignment = .Center
        font = UIFont.systemFontOfSize(30)
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSizeMake(0, 15)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        
    }
    
}
