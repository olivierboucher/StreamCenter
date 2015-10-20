//
//  SourceTabController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/14/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class SourceTabController: UITabBarController {
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
        
        let twitch = TwitchGamesViewController()
        let hitbox = HitboxGamesViewController()
        let youtube = YoutubeStreamsViewController()
        let custom = QRCustomVideoViewController()
        
        setViewControllers([twitch, hitbox, youtube, custom], animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
