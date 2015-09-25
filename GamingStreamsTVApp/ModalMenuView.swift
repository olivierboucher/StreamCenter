//
//  ModalMenuView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-25.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import Foundation

class ModalMenuView : UIView {
    
    let menuOptions : Dictionary<String, Array<MenuOption>>
    
    init(frame: CGRect, options: Dictionary<String, Array<MenuOption>>) {
        self.menuOptions = options
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.menuOptions = Dictionary<String, Array<MenuOption>>()
        super.init(coder: aDecoder)
    }
}

struct MenuOption {
    let enabledText : String
    let disbaledText : String
    
    init(enabledText : String, disabledText : String) {
        self.enabledText = enabledText
        self.disbaledText = disabledText
    }
}