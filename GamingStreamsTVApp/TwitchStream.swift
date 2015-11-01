//
//  TwitchStream.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation
import UIKit

struct TwitchStream: CellItem {
    let id : Int!
    let gameName : String!
    let viewers : Int!
    let videoHeight : Int!
    let preview : [String : String]!
    let channel : TwitchChannel!
    var mImage: UIImage?
    
    init(id : Int, gameName : String, viewers : Int, videoHeight : Int, preview : [String : String], channel : TwitchChannel) {
        self.id = id
        self.gameName = gameName
        self.viewers = viewers
        self.videoHeight = videoHeight
        self.preview = preview
        self.channel = channel
    }
    
    init?(dict: [String : AnyObject], channel: TwitchChannel) {
        guard let id = dict["_id"] as? Int else {
            return nil
        }
        
        guard let gameName = dict["game"] as? String else {
            return nil
        }
        
        guard let preview = dict["preview"] as? [String : String] else {
            return nil
        }
        
        self.id = id
        self.gameName = gameName
        self.preview = preview
        
        if let viewers = dict["viewers"] as? Int {
            self.viewers = viewers
        }
        else {
            self.viewers = 0
        }
        
        if let videoHeight = dict["video_height"] as? Int {
            self.videoHeight = videoHeight
        }
        else {
            self.videoHeight = 0
        }
        
        self.channel = channel
    }
    
    var urlTemplate: String? {
        get {
            return preview["large"]
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
    
    var bannerString: String? {
        get {
            return channel.displayLanguage
        }
    }
    
    var image: UIImage? {
        get {
            return mImage
        }
    }
    
    mutating func setImage(image: UIImage) {
        mImage = image
    }
}
