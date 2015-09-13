//
//  TwitchChannel.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation


class TwitchChannel {
    private var _id : Int;
    private var _name : String;
    private var _displayName : String
    private var _links : NSDictionary;
    private var _broadcasterLanguage : String;
    private var _language : String;
    private var _gameName : String;
    private var _logo : String;
    private var _status : String;
    private var _videoBanner : String;
    private var _lastUpdate : NSDate;
    private var _followers : Int;
    private var _views : Int;
    
    init(id : Int, name : String, displayName : String, links : NSDictionary, broadcasterLanguage : String, language : String, gameName : String, logo : String, status : String, videoBanner : String, lastUpdate : NSDate, followers : Int, views : Int) {
        _id = id;
        _name = name;
        _displayName = displayName;
        _links = links;
        _broadcasterLanguage = broadcasterLanguage;
        _language = language;
        _gameName = gameName;
        _logo = logo;
        _status = status;
        _videoBanner = videoBanner;
        _lastUpdate = lastUpdate;
        _followers = followers;
        _views = views;
    }
}
