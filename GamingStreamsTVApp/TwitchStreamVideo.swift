//
//  TwitchStream.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation

struct TwitchStreamVideo {
    
    private(set) var quality : String
    private(set) var url : NSURL
    private(set) var codecs : String
    
    init(quality : String, url : NSURL, codecs : String) {
        self.quality = quality
        self.url = url
        self.codecs = codecs
    }
}