//
//  TwitchGame.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation
import UIKit

struct TwitchGame: CellItem {
    let id : Int!
    let viewers : Int!
    let popularity : Int!
    let channels : Int!
    let name : String!
    let thumbnails : [String : String]!
    let logos : [String : String]!
    private var mImage: UIImage?
    
    init(id : Int, viewers : Int, channels : Int, name : String, thumbnails : [String : String], logos : [String : String]) {
        self.id = id
        self.viewers = viewers
        self.channels = channels
        self.popularity = 0
        self.name = name
        self.thumbnails = thumbnails
        self.logos = logos
    }
    
    init?(dict: [String : AnyObject]) {
        if let gameDict = dict["game"] as? [String : AnyObject] {
            guard let id = gameDict["_id"] as? Int else {
                return nil
            }
            guard let name = gameDict["name"] as? String else {
                return nil
            }
            guard let thumbs = gameDict["box"] as? [String : String] else {
                return nil
            }
            guard let logos = gameDict["logo"] as? [String : String] else {
                return nil
            }
            
            self.id = id
            self.name = name
            self.thumbnails = thumbs
            self.logos = logos
        }
        else {
            guard let id = dict["_id"] as? Int else {
                return nil
            }
            guard let name = dict["name"] as? String else {
                return nil
            }
            guard let thumbs = dict["box"] as? [String : String] else {
                return nil
            }
            guard let logos = dict["logo"] as? [String : String] else {
                return nil
            }
            
            self.id = id
            self.name = name
            self.thumbnails = thumbs
            self.logos = logos
        }
        
        if let viewers = dict["viewers"] as? Int {
            self.viewers = viewers
        }
        else {
            self.viewers = 0
        }
        
        if let channels = dict["channels"] as? Int {
            self.channels = channels
        }
        else {
            self.channels = 0
        }
        
        if let popularity = dict["popularity"] as? Int {
            self.popularity = popularity
        }
        else {
            self.popularity = 0
        }
    }
    
    var urlTemplate: String? {
        get {
            return thumbnails["large"]
        }
    }
    
    var title: String {
        get {
            return name
        }
    }
    
    var subtitle: String {
        get {
            if viewers > 0 {
                return "\(viewers) viewers"
            } else {
                if popularity > 0 {
                    return "popularity: \(popularity)"
                }
            }
            //return blank so that the label is still rendered in the collection view (for spacing)
            return " "
        }
    }
    
    var bannerString: String? {
        get {
            return nil
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