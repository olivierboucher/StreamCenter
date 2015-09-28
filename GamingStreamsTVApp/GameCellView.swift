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
    
    private var _game : TwitchGame?
    private var _image : UIImage?
    private var _imageView : UIImageView?
    private var _activityIndicator : UIActivityIndicatorView?
    private var _gameNameLabel : UILabel?
    private var _viewCountLabel : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        let imageViewFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-80)
        self._imageView = UIImageView(frame: imageViewFrame);
        self._imageView!.adjustsImageWhenAncestorFocused = true;
        self._imageView!.layer.cornerRadius = 10
        self._imageView!.backgroundColor = UIColor(white: 0.25, alpha: 0.7)
        
        self._activityIndicator = UIActivityIndicatorView(frame: imageViewFrame)
        self._activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self._activityIndicator?.startAnimating()
        
        self._gameNameLabel = UILabel(frame: CGRect(x: 0,y: self.bounds.height-80, width: self.bounds.size.width, height: 40))
        self._viewCountLabel = UILabel(frame: CGRect(x: 0,y: self.bounds.height-40, width: self.bounds.size.width, height: 40))
        self._gameNameLabel?.alpha = 0;
        self._viewCountLabel?.alpha = 0;
        self._gameNameLabel?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightSemibold)
        self._viewCountLabel?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightThin)
        self._gameNameLabel?.textColor = UIColor.whiteColor()
        self._viewCountLabel?.textColor = UIColor.whiteColor()
        
        self._imageView?.addSubview(self._activityIndicator!)
        self.contentView.addSubview(self._imageView!)
        self.contentView.addSubview(_gameNameLabel!)
        self.contentView.addSubview(_viewCountLabel!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self._game = nil
        self._image = nil
        self._imageView?.image = nil
        self._gameNameLabel?.text = ""
        self._viewCountLabel?.text = ""
        
        self._activityIndicator = UIActivityIndicatorView(frame: self._imageView!.frame)
        self._activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self._activityIndicator?.startAnimating()
        
        self._imageView?.addSubview(self._activityIndicator!)
    }
    
    func setGame(game : TwitchGame) {
        _game = game;
        _gameNameLabel!.text = game.name
        _viewCountLabel?.text = "\(game.viewers) viewers"
        self.assignImageAndDisplay();
    }
    func getGame() -> TwitchGame? {
        return self._game;
    }
    
    private func assignImageAndDisplay() {
        
        self.downloadImageWithSize(self._imageView!.bounds.size) {
            (image, error) in
            
            if(error != nil || image == nil) {
                //TODO : Set error image, not available
                self._image = nil;
            }
            else {
                self._image = image!;
            }
            
            dispatch_async(dispatch_get_main_queue(),{
                if((self._activityIndicator != nil) && (self._activityIndicator!.isDescendantOfView(self._imageView!))) {
                    self._activityIndicator?.removeFromSuperview()
                    self._activityIndicator = nil
                }
                self._imageView!.image = self._image;
            })
            
        }
    }
    
    private func downloadImageWithSize(size : CGSize, completionHandler : (image : UIImage?, error : NSError?) -> ()) {
        
        if let imgUrlTemplate = _game?.thumbnails["template"] as? String {
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
                self._gameNameLabel?.center.y += 40
                self._viewCountLabel?.center.y += 40
                self._gameNameLabel?.alpha = 1;
                self._viewCountLabel?.alpha = 1;
                self.layoutIfNeeded()
                
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                self._gameNameLabel?.center.y -= 40
                self._viewCountLabel?.center.y -= 40
                self._gameNameLabel?.alpha = 0;
                self._viewCountLabel?.alpha = 0;
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
    }
}


