//
//  TwitchChannel.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation


struct TwitchChannel {
    private(set) var id : Int
    private(set) var name : String
    private(set) var displayName : String
    private(set) var links : [String : String]
    private(set) var broadcasterLanguage : String?
    private(set) var language : String
    private(set) var gameName : String
    private(set) var logo : String?
    private(set) var status : String
    private(set) var videoBanner : String?
    private(set) var lastUpdate = NSDate()
    private(set) var followers = 0
    private(set) var views = 0
    
    init(id : Int, name : String, displayName : String, links : [String : String], broadcasterLanguage : String?,
        language : String, gameName : String, logo : String?, status : String, videoBanner : String?,
        lastUpdate : NSDate, followers : Int, views : Int) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.links = links
        self.broadcasterLanguage = broadcasterLanguage
        self.language = language
        self.gameName = gameName
        self.logo = logo
        self.status = status
        self.videoBanner = videoBanner
        self.lastUpdate = lastUpdate
        self.followers = followers
        self.views = views
    }
    
    init?(dict: [String : AnyObject]) {
        guard let id = dict["_id"] as? Int else {
            return nil
        }
        guard let name = dict["name"] as? String else {
            return nil
        }
        guard let displayName = dict["display_name"] as? String else {
            return nil
        }
        guard let links = dict["_links"] as? [String : String] else {
            return nil
        }
        guard let language = dict["language"] as? String else {
            return nil
        }
        guard let gameName = dict["game"] as? String else {
            return nil
        }
        guard let status = dict["status"] as? String else {
            return nil
        }
        self.id = id
        self.name = name
        self.displayName = displayName
        self.links = links
        self.language = language
        self.gameName = gameName
        self.status = status
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
        if let updateDateString = dict["updated_at"] as? String, updateDate = dateFormatter.dateFromString(updateDateString) {
            self.lastUpdate = updateDate
        }
        if let followers = dict["followers"] as? Int {
            self.followers = followers
        }
        if let views = dict["views"] as? Int {
            self.views = views
        }
        if let broadcasterLanguage = dict["broadcaster_language"] as? String {
            self.broadcasterLanguage = broadcasterLanguage
        }
        if let videoBanner = dict["video_banner"] as? String  {
            self.videoBanner = videoBanner
        }
        if let logo = dict["logo"] as? String {
            self.logo = logo
        }
    }
    
    var displayLanguage: String? {
        get {
            if let display = NSLocale(localeIdentifier: language).displayNameForKey(NSLocaleLanguageCode, value: language) {
                return display.lowercaseString
            }
            return nil
        }
    }
}