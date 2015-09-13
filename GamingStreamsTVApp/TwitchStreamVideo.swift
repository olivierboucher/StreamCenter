//
//  TwitchStream.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchStreamVideo {
    
    private var _quality : String?;
    private var _url : NSURL?;
    private var _codecs : String?;
    
    init(quality : String, url : NSURL, codecs : String) {
        _quality = quality;
        _url = url;
        _codecs = codecs;
    }
    
    func getQuality() -> String? {
        return _quality;
    }
    
    func getUrl() -> NSURL? {
        return _url;
    }
    
    func getCodecs() -> String? {
        return _codecs;
    }
}