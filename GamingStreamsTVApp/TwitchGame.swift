//
//  TwitchGame.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation
import UIKit

class TwitchGame: CellItem {
    
    private(set) var id : Int!
    private(set) var viewers = 0
    private(set) var popularity = 0
    private(set) var channels = 0
    private(set) var name : String!
    private(set) var thumbnails : [String : String]!
    private(set) var logos : [String : String]!
    private var mImage: UIImage?
    
    init(id : Int, viewers : Int, channels : Int, name : String, thumbnails : [String : String], logos : [String : String]) {
        self.id = id
        self.viewers = viewers
        self.channels = channels
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
        } else {
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
        if let channels = dict["channels"] as? Int {
            self.channels = channels
        }
        if let popularity = dict["popularity"] as? Int {
            self.popularity = popularity
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
    
    func setImage(image: UIImage) {
        mImage = image
    }
}