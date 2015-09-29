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
    
    private var stream : TwitchStream?
    private var image : UIImage?
    private var imageView : UIImageView?
    private var activityIndicator : UIActivityIndicatorView?
    private var streamStatusLabel : UILabel?
    private var viewersInfoLabel : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let imageViewBounds = CGRect(x: 0, y: 40, width: self.bounds.width, height: self.bounds.height - 80)
        self.imageView = UIImageView(frame: imageViewBounds)
        self.imageView!.adjustsImageWhenAncestorFocused = true
        self.imageView!.layer.cornerRadius = 10
        self.imageView!.backgroundColor = UIColor(white: 0.25, alpha: 0.7)
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-80))
        self.activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator?.startAnimating()
        
        self.streamStatusLabel = UILabel(frame: CGRect(x: 0,y: 0, width: self.bounds.width, height: 40))
        self.viewersInfoLabel = UILabel(frame: CGRect(x: 0,y: self.bounds.height-40, width: self.bounds.width, height: 40))
        self.streamStatusLabel?.alpha = 0;
        self.viewersInfoLabel?.alpha = 0;
        self.streamStatusLabel?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightSemibold)
        self.viewersInfoLabel?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightThin)
        self.streamStatusLabel?.textColor = UIColor.blackColor()
        self.viewersInfoLabel?.textColor = UIColor.whiteColor()
        
        self.imageView?.addSubview(self.activityIndicator!)
        self.contentView.addSubview(self.imageView!)
        self.contentView.addSubview(streamStatusLabel!)
        self.contentView.addSubview(viewersInfoLabel!)
    }
    convenience init() {
        self.init()
    }
    
    convenience init(stream : TwitchStream) {
        self.init();
        self.stream = stream
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stream = nil
        self.image = nil
        self.imageView?.image = nil
        self.streamStatusLabel?.text = ""
        self.viewersInfoLabel?.text = ""
        
        self.activityIndicator = UIActivityIndicatorView(frame: self.imageView!.frame)
        self.activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator?.startAnimating()
        
        self.imageView?.addSubview(self.activityIndicator!)
    }
    
    func setStream(stream : TwitchStream) {
        self.stream = stream
        self.streamStatusLabel?.text = stream.channel.status
        self.viewersInfoLabel?.text = "\(stream.viewers) viewers on \(stream.channel.name)"
        self.assignImageAndDisplay()
    }
    
    private func assignImageAndDisplay() {
        
        self.downloadImageWithSize(self.imageView!.bounds.size) {
            (image, error) in
            if(error != nil || image == nil) {
                //TODO : Set error image, not available
                NSLog("Error setting stream image")
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
        
        if let imgUrlTemplate = stream?.preview["template"] {
            if let imgUrlString : String? = imgUrlTemplate.stringByReplacingOccurrencesOfString("{width}", withString: "\(Int(size.width))")
                .stringByReplacingOccurrencesOfString("{height}", withString: "\(Int(size.height))") {
                    Alamofire.request(.GET, imgUrlString!).response() {
                        (_, _, data, error) in
                        if error != nil {
                            //TODO(Olivier): GET ERROR FROM ALAMOFIRE
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
                self.streamStatusLabel?.center.y -= 22
                self.viewersInfoLabel?.center.y += 22
                self.streamStatusLabel?.alpha = 1;
                self.viewersInfoLabel?.alpha = 1;
                self.layoutIfNeeded()
                
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                self.streamStatusLabel?.center.y += 22
                self.viewersInfoLabel?.center.y -= 22
                self.streamStatusLabel?.alpha = 0;
                self.viewersInfoLabel?.alpha = 0;
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
    }

}