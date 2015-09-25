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
            menuTitle.font = UIFont.systemFontOfSize(self.menuItemSize.height * 0.8, weight: 0.5)
            menuTitle.textColor = UIColor.whiteColor()
            
            self.addSubview(menuTitle)
            
            for var j = 0; j < self.menuOptions[i].value.count; j++  {
                currentIndex++
                let optionView = MenuItemView(frame: self.getFrameForItemAtIndex(currentIndex), option: self.menuOptions[i].value[j])
                
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
    var title : UILabel? = nil
    
    init(frame: CGRect, option: MenuOption) {
        self.option = option
        super.init(frame: frame)
        
        self.title = UILabel(frame: self.bounds)
        
        self.title!.text = self.option.isEnabled ? self.option.enabledTitle : self.option.disabledTitle
        self.title!.textAlignment = NSTextAlignment.Center
        self.title!.font = UIFont.systemFontOfSize(self.bounds.height * 0.7, weight: 0)
        self.title!.textColor = UIColor.whiteColor()
        
        self.backgroundColor = UIColor(white: 0.5, alpha: 0.9)
        self.addSubview(self.title!)
        self.layer.cornerRadius = self.bounds.height * 0.05
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.option = MenuOption(title: "", enabled: false)
        super.init(coder: aDecoder)
    }
    
    override func canBecomeFocused() -> Bool {
        return !self.option.isEnabled
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        if(context.nextFocusedView == self){
            coordinator.addCoordinatedAnimations({
                
                self.title!.textColor = UIColor.blackColor()
                self.backgroundColor = UIColor.whiteColor()
                
                let newFrame = CGRect(
                    x: self.bounds.origin.x - (self.bounds.width * 0.1)/2,
                    y: self.bounds.origin.y - (self.bounds.height * 0.1)/2,
                    width: self.bounds.width * 1.1,
                    height: self.bounds.height * 1.1)
                
                self.bounds = newFrame
                self.title!.frame = newFrame
                
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                
                self.title!.textColor = UIColor.whiteColor()
                self.backgroundColor = UIColor(white: 0.5, alpha: 0.9)
                
                let newFrame = CGRect(
                    x: self.bounds.origin.x + ((self.bounds.width/1.1) * 0.1)/2,
                    y: self.bounds.origin.y + ((self.bounds.height/1.1) * 0.1)/2,
                    width: self.bounds.width / 1.1,
                    height: self.bounds.height / 1.1)
                
                self.bounds = newFrame
                self.title!.frame = newFrame
                
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
        
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