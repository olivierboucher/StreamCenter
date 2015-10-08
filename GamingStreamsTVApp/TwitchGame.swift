//
//  TwitchGame.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation

struct TwitchGame: CellItem {
    
    private(set) var id : Int;
    private(set) var viewers : Int;
    private(set) var channels : Int;
    private(set) var name : String;
    private(set) var thumbnails : Dictionary<String, String>;
    private(set) var logos : Dictionary<String, String>;
    
    init(id : Int, viewers : Int, channels : Int, name : String, thumbnails : Dictionary<String, String>, logos : Dictionary<String, String>) {
        self.id = id;
        self.viewers = viewers;
        self.channels = channels;
        self.name = name;
        self.thumbnails = thumbnails;
        self.logos = logos;
    }
    
    var urlTemplate: String? {
        get {
            return thumbnails["template"]
        }
    }
    
    var title: String {
        get {
            return name
        }
    }
    
    var subtitle: String {
        get {
            return "\(viewers) viewers"
        }
    }
}