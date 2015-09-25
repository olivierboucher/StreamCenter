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
    let menuSize : CGSize
    let menuItemSize : CGSize
    var menuItemCount : Int {
        get {
            var count : Int = 0
            for menuOptionsArray in menuOptions {
                count += 1 + menuOptionsArray.1.count
            }
            return count
        }
    }
    
    init(frame: CGRect, options: Dictionary<String, Array<MenuOption>>, size : CGSize) {
        self.menuSize = size
        self.menuOptions = options
        self.menuItemSize = ModalMenuView.requiredMenuItemHeightToFit(menuOptions, menuSize: size)
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        self.buildMenuItemViews()
    }

    required init?(coder aDecoder: NSCoder) {
        self.menuSize = CGSize(width: 0, height: 0)
        self.menuItemSize = CGSize(width: 0, height: 0)
        self.menuOptions = Dictionary<String, Array<MenuOption>>()
        super.init(coder: aDecoder)
    }
    
//    func blurAndSetMenuFrame() {
//        let layer = CALayer()
//        layer.frame = CGRect(origin:
//            CGPoint(x: self.bounds.width/2 - self.menuSize.width/2,
//                    y: self.bounds.height/2 - self.menuSize.height/2),
//            size: self.menuSize)
//        
//        
//    }
    
    static func requiredMenuItemHeightToFit(menuOptions : Dictionary<String, Array<MenuOption>>, menuSize : CGSize) -> CGSize {
        var count : CGFloat = 0
        for menuOptionsArray in menuOptions {
            count += CGFloat(1 + menuOptionsArray.1.count)
        }
        let reqHeight = (menuSize.height / count) * 0.8 //For padding
        return CGSize(width: menuSize.width, height: reqHeight)
    }
    
    func buildMenuItemViews() {
        var currentIndex = 0
        for var i = self.menuOptions.count-1; i >= 0; i--  {
            let menuTitle = UILabel(frame: self.getFrameForItemAtIndex(currentIndex))
            
            menuTitle.text = self.menuOptions[i].key
            menuTitle.textAlignment = NSTextAlignment.Center
            menuTitle.font = UIFont.systemFontOfSize(self.menuItemSize.height * 0.7, weight: 1)
            menuTitle.textColor = UIColor.whiteColor()
            menuTitle.layer.borderColor = UIColor.greenColor().CGColor
            menuTitle.layer.borderWidth = 1
            
            self.addSubview(menuTitle)
            
            for var j = 0; j < self.menuOptions[i].value.count; j++  {
                currentIndex++
                let optionView = MenuItemView(frame: self.getFrameForItemAtIndex(currentIndex), option: self.menuOptions[i].value[j])
                optionView.layer.borderColor = UIColor.redColor().CGColor
                optionView.layer.borderWidth = 1
                
                self.addSubview(optionView)
            }
            currentIndex++
        }
    }
    
    func getFrameForItemAtIndex(index : Int) -> CGRect {
        
        var y = (self.bounds.height - (CGFloat(self.menuItemCount) * self.menuItemSize.height))/2 + CGFloat(index) * self.menuItemSize.height
        
        y -= (self.menuItemSize.height * 0.2)
        y = index == 0 ? y : y + (CGFloat(index) * (self.menuItemSize.height * 0.2))
        
        return CGRect(x: self.bounds.width/2 - self.menuSize.width/2,
            y: y,
            width: self.menuSize.width,
            height: self.menuItemSize.height)
    }
}

class MenuItemView : UIView {
    let option : MenuOption
    
    init(frame: CGRect, option: MenuOption) {
        self.option = option
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.option = MenuOption(title: "", enabled: false)
        super.init(coder: aDecoder)
    }
}

struct MenuOption {
    let enabledTitle : String
    let disabledTitle : String
    var isEnabled : Bool
    
    init(enabledTitle : String, disabledTitle : String, enabled : Bool) {
        self.enabledTitle = enabledTitle
        self.disabledTitle = disabledTitle
        self.isEnabled = enabled
    }
    
    init(title : String, enabled : Bool) {
        self.enabledTitle = title
        self.disabledTitle = title
        self.isEnabled = enabled
    }
    
}