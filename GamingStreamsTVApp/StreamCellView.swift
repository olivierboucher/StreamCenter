//
//  StreamCellView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import Alamofire
import UIKit
import Foundation

class StreamCellView : UICollectionViewCell {
    static let cellIdentifier : String = "kStreamCellView"
    
    private var _stream : TwitchStream?
    private var _image : UIImage?
    private var _imageView : UIImageView?
    private var _activityIndicator : UIActivityIndicatorView?
    private var _streamStatusLabel : UILabel?
    private var _viewersInfoLabel : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let imageViewBounds = CGRect(x: 0, y: 40, width: self.bounds.width, height: self.bounds.height - 80)
        self._imageView = UIImageView(frame: imageViewBounds)
        self._imageView!.adjustsImageWhenAncestorFocused = true
        self._imageView!.layer.cornerRadius = 10
        self._imageView!.backgroundColor = UIColor(white: 0.25, alpha: 0.7)
        
        self._activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-80))
        self._activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self._activityIndicator?.startAnimating()
        
        self._streamStatusLabel = UILabel(frame: CGRect(x: 0,y: 0, width: self.bounds.width, height: 40))
        self._viewersInfoLabel = UILabel(frame: CGRect(x: 0,y: self.bounds.height-40, width: self.bounds.width, height: 40))
        self._streamStatusLabel?.alpha = 0;
        self._viewersInfoLabel?.alpha = 0;
        self._streamStatusLabel?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightSemibold)
        self._viewersInfoLabel?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightThin)
        self._streamStatusLabel?.textColor = UIColor.blackColor()
        self._viewersInfoLabel?.textColor = UIColor.whiteColor()
        
        self._imageView?.addSubview(self._activityIndicator!)
        self.contentView.addSubview(self._imageView!)
        self.contentView.addSubview(_streamStatusLabel!)
        self.contentView.addSubview(_viewersInfoLabel!)
    }
    convenience init() {
        self.init()
    }
    
    convenience init(stream : TwitchStream) {
        self.init();
        _stream = stream
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStream(stream : TwitchStream) {
        self._stream = stream
        self._streamStatusLabel?.text = stream.channel.status
        self._viewersInfoLabel?.text = "\(stream.viewers) viewers on \(stream.channel.name)"
        self.assignImageAndDisplay()
    }
    
    private func assignImageAndDisplay() {
        
        self.downloadImageWithSize(self._imageView!.bounds.size) {
            (image, error) in
            if(error != nil || image == nil) {
                //TODO : Set error image, not available
                NSLog("Error setting stream image")
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
        
        if let imgUrlTemplate = _stream?.preview["template"] as? String {
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
                self._streamStatusLabel?.center.y -= 22
                self._viewersInfoLabel?.center.y += 22
                self._streamStatusLabel?.alpha = 1;
                self._viewersInfoLabel?.alpha = 1;
                self.layoutIfNeeded()
                
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                self._streamStatusLabel?.center.y += 22
                self._viewersInfoLabel?.center.y -= 22
                self._streamStatusLabel?.alpha = 0;
                self._viewersInfoLabel?.alpha = 0;
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
    }

}