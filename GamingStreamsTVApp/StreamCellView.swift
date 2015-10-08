//
//  StreamCellView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.

import Alamofire
import UIKit
import Foundation

class StreamCellView : UICollectionViewCell {
    internal static let CELL_IDENTIFIER : String = "kStreamCellView"
    internal static let LABEL_HEIGHT : CGFloat = 40;
    
    var stream : TwitchStream? {
        get { return self.stream }
        set {
            self.stream = newValue
            self.streamStatusLabel?.text = stream?.channel.status
            self.viewersInfoLabel?.text = "\(stream?.viewers) viewers on \(stream?.channel.name)"
            self.assignImageAndDisplay()
        }
    }
    
    private var image : UIImage?
    private var imageView : UIImageView?
    private var activityIndicator : UIActivityIndicatorView?
    private var streamStatusLabel : UILabel?
    private var viewersInfoLabel : UILabel?
    
    /*
    * init(frame: CGRect)
    *
    * Override the default constructor to add required subviews
    * Adds a loading indicator while a stream gets set and its image displayed
    */
    override init(frame: CGRect) {
        super.init(frame: frame)

        let imageViewBounds = CGRect(x: 0, y: StreamCellView.LABEL_HEIGHT, width: self.bounds.width, height: self.bounds.height - 80)
        self.imageView = UIImageView(frame: imageViewBounds)
        self.imageView!.adjustsImageWhenAncestorFocused = true
        self.imageView!.layer.cornerRadius = 10
        self.imageView!.backgroundColor = UIColor(white: 0.25, alpha: 0.7)
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height - (StreamCellView.LABEL_HEIGHT*2)))
        self.activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator?.startAnimating()
        
        self.streamStatusLabel = UILabel(frame: CGRect(x: 0,y: 0, width: self.bounds.width, height: StreamCellView.LABEL_HEIGHT))
        self.viewersInfoLabel = UILabel(frame: CGRect(x: 0,y: self.bounds.height - StreamCellView.LABEL_HEIGHT, width: self.bounds.width, height: StreamCellView.LABEL_HEIGHT))
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
    
    /*
    * prepareForReuse()
    *
    * Override the default method to free internal ressources and add
    * a loading indicator
    */
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
    
    
    /*
    * assignImageAndDisplay()
    *
    * Downloads the image from the actual stream and assigns it to the image view
    * Removes the loading indicator on download callback success
    */
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
    
    /*
    * downloadImageWithSize(size : CGSize, completionHandler : (image : UIImage?, error : NSError?) -> ())
    *
    * Download an image from twitch server with the required size
    * Passes the downloaded image to a defined completion handler
    */
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
    
    /*
    * didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
    *
    * Responds to the focus update by either growing or shrinking
    *
    */
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