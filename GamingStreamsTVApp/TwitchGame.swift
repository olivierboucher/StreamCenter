//
//  TwitchGame.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation


class TwitchGame {
    
    private var _id : Int;
    private var _viewers : Int;
    private var _channels : Int;
    private var _name : String;
    private var _thumbnails : NSDictionary;
    private var _logos : NSDictionary;
    
    init(id : Int, viewers : Int, channels : Int, name : String, thumbnails : NSDictionary, logos : NSDictionary) {
        _id = id;
        _viewers = viewers;
        _channels = channels;
        _name = name;
        _thumbnails = thumbnails;
        _logos = logos;
    }
    
    func getId() -> Int {
        return _id;
    }
    
    func getViewers() -> Int {
        return _viewers
    }
    
    func getChannels() -> Int {
        return _channels;
    }
    
    func getName() -> String {
        return _name;
    }
    
    func getThumbnails() -> NSDictionary {
        return _thumbnails;
    }
    
    func getLogos() -> NSDictionary {
        return _logos;
    }
    
}