//
//  SourceSelectorViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class SourceSelectorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        let button1 = UIButton(type: .System)
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.addTarget(self, action: Selector("pickSource:"), forControlEvents: .PrimaryActionTriggered)
        button1.setTitle("Twitch", forState: .Normal)
        
        let button2 = UIButton(type: .System)
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.addTarget(self, action: Selector("pickSource:"), forControlEvents: .PrimaryActionTriggered)
        button2.setTitle("Hitbox", forState: .Normal)
        
        let button3 = UIButton(type: .System)
        button3.translatesAutoresizingMaskIntoConstraints = false
        button3.addTarget(self, action: Selector("pickSource:"), forControlEvents: .PrimaryActionTriggered)
        button3.setTitle("Youtube", forState: .Normal)
        
        self.view.addSubview(button1)
        self.view.addSubview(button2)
        self.view.addSubview(button3)
        
        let viewDict = ["b1" : button1, "b2" : button2, "b3" : button3]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[b1]-|", options: [], metrics: nil, views: viewDict))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[b2]-|", options: [], metrics: nil, views: viewDict))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[b3]-|", options: [], metrics: nil, views: viewDict))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[b1]-[b2]-[b3]", options: [], metrics: nil, views: viewDict))
    }
    
    func pickSource(sender: UIButton) {
        if let title = sender.currentTitle, source = SourceAPI(rawValue: title) {
            if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                delegate.switchSource(source)
            }
        }
    }

}
