//
//  TwitchGame.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation


class TwitchGame {
    
    private(set) var id : Int;
    private(set) var viewers : Int;
    private(set) var channels : Int;
    private(set) var name : String;
    private(set) var thumbnails : NSDictionary;
    private(set) var logos : NSDictionary;
    
    init(id : Int, viewers : Int, channels : Int, name : String, thumbnails : NSDictionary, logos : NSDictionary) {
        self.id = id;
        self.viewers = viewers;
        self.channels = channels;
        self.name = name;
        self.thumbnails = thumbnails;
        self.logos = logos;
    }

    
}