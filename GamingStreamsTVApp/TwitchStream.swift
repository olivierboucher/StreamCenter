//
//  TwitchStream.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchStream {
    private(set) var id : Int;
    private(set) var gameName : String;
    private(set) var viewers : Int;
    private(set) var videoHeight : Int;
    private(set) var preview : Dictionary<String, String>;
    private(set) var channel : TwitchChannel;
    
    init(id : Int, gameName : String, viewers : Int, videoHeight : Int, preview : Dictionary<String, String>, channel : TwitchChannel) {
        self.id = id;
        self.gameName = gameName;
        self.viewers = viewers;
        self.videoHeight = videoHeight;
        self.preview = preview;
        self.channel = channel;
    }
}
