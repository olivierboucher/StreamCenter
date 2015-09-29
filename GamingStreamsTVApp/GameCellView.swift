//
//  GameCellView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import Alamofire
import UIKit;
import Foundation

class GameCellView : UICollectionViewCell {
    static let cellIdentifier : String = "kGameCellView";
    
    private var game : TwitchGame?
    private var image : UIImage?
    private var imageView : UIImageView?
    private var activityIndicator : UIActivityIndicatorView?
    private var gameNameLabel : UILabel?
    private var viewCountLabel : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        let imageViewFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-80)
        self.imageView = UIImageView(frame: imageViewFrame);
        self.imageView!.adjustsImageWhenAncestorFocused = true;
        self.imageView!.layer.cornerRadius = 10
        self.imageView!.backgroundColor = UIColor(white: 0.25, alpha: 0.7)
        
        self.activityIndicator = UIActivityIndicatorView(frame: imageViewFrame)
        self.activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator?.startAnimating()
        
        self.gameNameLabel = UILabel(frame: CGRect(x: 0,y: self.bounds.height-80, width: self.bounds.size.width, height: 40))
        self.viewCountLabel = UILabel(frame: CGRect(x: 0,y: self.bounds.height-40, width: self.bounds.size.width, height: 40))
        self.gameNameLabel?.alpha = 0;
        self.viewCountLabel?.alpha = 0;
        self.gameNameLabel?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightSemibold)
        self.viewCountLabel?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightThin)
        self.gameNameLabel?.textColor = UIColor.whiteColor()
        self.viewCountLabel?.textColor = UIColor.whiteColor()
        
        self.imageView?.addSubview(self.activityIndicator!)
        self.contentView.addSubview(self.imageView!)
        self.contentView.addSubview(gameNameLabel!)
        self.contentView.addSubview(viewCountLabel!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.game = nil
        self.image = nil
        self.imageView?.image = nil
        self.gameNameLabel?.text = ""
        self.viewCountLabel?.text = ""
        
        self.activityIndicator = UIActivityIndicatorView(frame: self.imageView!.frame)
        self.activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator?.startAnimating()
        
        self.imageView?.addSubview(self.activityIndicator!)
    }
    
    func setGame(game : TwitchGame) {
        self.game = game;
        gameNameLabel!.text = game.name
        viewCountLabel?.text = "\(game.viewers) viewers"
        self.assignImageAndDisplay();
    }
    func getGame() -> TwitchGame? {
        return self.game;
    }
    
    private func assignImageAndDisplay() {
        
        self.downloadImageWithSize(self.imageView!.bounds.size) {
            (image, error) in
            
            if(error != nil || image == nil) {
                //TODO : Set error image, not available
                self.image = nil;
            }
            else {
                self.image = image!;
            }
            
            dispatch_async(dispatch_get_main_queue(),{
                if((self.activityIndicator != nil) && (self.activityIndicator!.isDescendantOfView(self.imageView!))) {
                    self.activityIndicator?.removeFromSuperview()
                    self.activityIndicator = nil
                }
                self.imageView!.image = self.image;
            })
            
        }
    }
    
    private func downloadImageWithSize(size : CGSize, completionHandler : (image : UIImage?, error : NSError?) -> ()) {
        
        if let imgUrlTemplate = game?.thumbnails["template"] {
            if let imgUrlString : String? = imgUrlTemplate.stringByReplacingOccurrencesOfString("{width}", withString: "\(Int(size.width))")
                .stringByReplacingOccurrencesOfString("{height}", withString: "\(Int(size.height))") {
                    Alamofire.request(.GET, imgUrlString!).response() {
                        (_, _, data, error) in
                        if error != nil {
                            //TODO: GET ERROR FROM ALAMOFIRE
                            completionHandler(image : nil, error : nil);
                            return
                        }
                        else {
                            let image = UIImage(data: data!);
                            completionHandler(image: image, error: nil);
                        }
                    }
            }
        }
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        if(context.nextFocusedView == self){
            coordinator.addCoordinatedAnimations({
                self.gameNameLabel?.center.y += 40
                self.viewCountLabel?.center.y += 40
                self.gameNameLabel?.alpha = 1;
                self.viewCountLabel?.alpha = 1;
                self.layoutIfNeeded()
                
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                self.gameNameLabel?.center.y -= 40
                self.viewCountLabel?.center.y -= 40
                self.gameNameLabel?.alpha = 0;
                self.viewCountLabel?.alpha = 0;
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
    }
}


