//
//  TwitchStream.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchStream {
    private var _id : Int;
    private var _gameName : String;
    private var _viewers : Int;
    private var _videoHeight : Int;
    private var _preview : NSDictionary;
    private var _channel : TwitchChannel;
    
    init(id : Int, gameName : String, viewers : Int, videoHeight : Int, preview : NSDictionary, channel : TwitchChannel) {
        _id = id;
        _gameName = gameName;
        _viewers = viewers;
        _videoHeight = videoHeight;
        _preview = preview;
        _channel = channel;
    }
}
