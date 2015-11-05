//
//  HitboxGame.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

struct HitboxGame: CellItem {
    
    let id : Int!
    let name : String!
    let shortName : String?
    let viewers : Int!
    let thumbnail : String!
    
    private var mImage: UIImage?
    
    init?(dict: [String : AnyObject]) {
        guard let id = dict["category_id"] as? String, intId = Int(id) else {
            return nil
        }
        guard let name = dict["category_name"] as? String else {
            return nil
        }
        guard let thumb = dict["category_logo_large"] as? String else {
            return nil
        }
        guard let viewers = dict["category_viewers"] as? String, intViewers = Int(viewers) else {
            return nil
        }
        
        self.id = intId
        self.name = name
        self.thumbnail = thumb
        self.viewers = intViewers
        self.shortName = dict["category_name_short"] as? String
    }
    
    var urlTemplate: String? {
        get {
            return "https://edge.sf.hitbox.tv" + thumbnail
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
                return " "
            }
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
