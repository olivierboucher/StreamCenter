//
//  GameCellView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import UIKit;
import Foundation

class GameCellView : UICollectionViewCell {
    static let cellIdentifier : String = "kGameCellView";
    
    private var _game : TwitchGame?;
    private var _image : UIImage?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.blackColor();
    }
    convenience init() {
        self.init();
    }
    
    convenience init(game : TwitchGame) {
        self.init();
        _game = game;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGame(game : TwitchGame) {
        _game = game;
    }
    
    func downloadImageWithSize(size : CGRect, completionHandler : (image : UIImage?, error : NSError?) -> ()) {
        
        if let imgUrlTemplate = _game?.getThumbnails()["template"] as? String {
            if let imgUrlString : String? = imgUrlTemplate.stringByReplacingOccurrencesOfString("{width}", withString: "\(size.width)")
                .stringByReplacingOccurrencesOfString("{height}", withString: "\(size.height)") {
                    //Now that we have our correct template, we download the image
                    let imgUrl = NSURL(string: imgUrlString!);
                    let task = NSURLSession.sharedSession().dataTaskWithURL(imgUrl!) {(data, response, error) in
                        
                    };
                    task.resume();
            }
        }
    }
}


