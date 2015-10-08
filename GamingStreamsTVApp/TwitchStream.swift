//
//  TwitchStream.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation

struct TwitchStream: CellItem {
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
    
    var urlTemplate: String? {
        get {
            return preview["template"]
        }
    }
    
    var title: String {
        get {
            return channel.status
        }
    }
    
    var subtitle: String {
        get {
            return "\(viewers) viewers on \(channel.name)"
        }
    }
}
