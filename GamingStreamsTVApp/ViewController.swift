//
//  ViewController.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //For testing purposes
        let api = TwitchApi();
        
        api.getStreamsForChannel("sodapoppin") {
            (streams, error) in
            
            if(error != nil){
                NSLog("An error happened while retrieving streams");
            }
            if(streams != nil){
                let firstStream = (streams?.objectAtIndex(0))! as! TwitchStreamVideo;
                NSLog("Quality: %@\nCodecs: %@\nURL:%@", firstStream.getQuality()!, firstStream.getCodecs()!, (firstStream.getUrl()!.absoluteString));
            }
        };
        
        api.getTopGamesWithOffset(0, limit: 10) {
            (games, error) in
            
            if(error != nil){
                NSLog("An error happened while retrieving top games");
            }
            if(games != nil) {
                let firstGame = (games?.objectAtIndex(0))! as! TwitchGame;
                NSLog("Id: %d\nGame: %@\nViewers: %d\nChannels: %d\nThumbnails: %@\nLogos: %@", firstGame.getId(), firstGame.getName(), firstGame.getViewers(), firstGame.getChannels(), firstGame.getThumbnails(), firstGame.getLogos());
            }
        };
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

