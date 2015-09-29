//
//  TwitchChannel.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation


class TwitchChannel {
    private(set) var id : Int;
    private(set) var name : String;
    private(set) var displayName : String
    private(set) var links : Dictionary<String, String>;
    private(set) var broadcasterLanguage : String?;
    private(set) var language : String;
    private(set) var gameName : String;
    private(set) var logo : String?;
    private(set) var status : String;
    private(set) var videoBanner : String?;
    private(set) var lastUpdate : NSDate;
    private(set) var followers : Int;
    private(set) var views : Int;
    
    init(id : Int, name : String, displayName : String, links : Dictionary<String, String>, broadcasterLanguage : String?,
        language : String, gameName : String, logo : String?, status : String, videoBanner : String?,
        lastUpdate : NSDate, followers : Int, views : Int) {
        self.id = id;
        self.name = name;
        self.displayName = displayName;
        self.links = links;
        self.broadcasterLanguage = broadcasterLanguage;
        self.language = language;
        self.gameName = gameName;
        self.logo = logo;
        self.status = status;
        self.videoBanner = videoBanner;
        self.lastUpdate = lastUpdate;
        self.followers = followers;
        self.views = views;
    }
}
