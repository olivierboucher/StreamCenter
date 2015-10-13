//
//  HitboxMedia.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/12/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class HitboxMedia: CellItem {
    
    private(set) var id : Int!
    private(set) var name : String!
    private(set) var viewers : Int!
    private(set) var thumbnail: String!
    
    private var mImage: UIImage?
    
    init?(dict: [String : AnyObject]) {
        guard let id = dict["media_id"] as? String, intId = Int(id) else {
            return nil
        }
        guard let name = dict["media_display_name"] as? String else {
            return nil
        }
        guard let thumb = dict["media_thumbnail"] as? String else {
            return nil
        }
        guard let viewers = dict["category_viewers"] as? String, intViewers = Int(viewers) else {
            return nil
        }
        
        self.id = intId
        self.name = name
        self.thumbnail = thumb
        self.viewers = intViewers
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
    
    func setImage(image: UIImage) {
        mImage = image
    }

}
