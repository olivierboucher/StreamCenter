//
//  CellView.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/8/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import Alamofire

protocol CellItem {
    var urlTemplate: String? { get }
    var title: String { get }
    var subtitle: String { get }
}

class ItemCellView: UICollectionViewCell {
    internal static let CELL_IDENTIFIER : String = "kItemCellView";
    internal static let LABEL_HEIGHT : CGFloat = 40;
    
    private var representedItem : CellItem?;
    private var image : UIImage?
    private var imageView : UIImageView?
    private var activityIndicator : UIActivityIndicatorView?
    private var titleLabel : UILabel?
    private var subtitleLabel : UILabel?
    
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
        
        self.titleLabel = UILabel(frame: CGRect(x: 0,y: self.bounds.height - (ItemCellView.LABEL_HEIGHT*2), width: self.bounds.size.width, height: ItemCellView.LABEL_HEIGHT))
        self.subtitleLabel = UILabel(frame: CGRect(x: 0,y: self.bounds.height - ItemCellView.LABEL_HEIGHT, width: self.bounds.size.width, height: ItemCellView.LABEL_HEIGHT))
        self.titleLabel?.alpha = 0;
        self.subtitleLabel?.alpha = 0;
        self.titleLabel?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightSemibold)
        self.subtitleLabel?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightThin)
        self.titleLabel?.textColor = UIColor.whiteColor()
        self.subtitleLabel?.textColor = UIColor.whiteColor()
        
        self.imageView?.addSubview(self.activityIndicator!)
        self.contentView.addSubview(self.imageView!)
        self.contentView.addSubview(titleLabel!)
        self.contentView.addSubview(subtitleLabel!)
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
        
        self.representedItem = nil
        self.image = nil
        self.imageView?.image = nil
        self.titleLabel?.text = ""
        self.subtitleLabel?.text = ""
        
        self.activityIndicator = UIActivityIndicatorView(frame: self.imageView!.frame)
        self.activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator?.startAnimating()
        
        self.imageView?.addSubview(self.activityIndicator!)
    }
    
    /*
    * assignImageAndDisplay()
    *
    * Downloads the image from the actual game and assigns it to the image view
    * Removes the loading indicator on download callback success
    */
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
    
    /*
    * downloadImageWithSize(size : CGSize, completionHandler : (image : UIImage?, error : NSError?) -> ())
    *
    * Download an image from twitch server with the required size
    * Passes the downloaded image to a defined completion handler
    */
    private func downloadImageWithSize(size : CGSize, completionHandler : (image : UIImage?, error : NSError?) -> ()) {
        
        if let imgUrlTemplate = representedItem?.urlTemplate {
            if let imgUrlString : String? = imgUrlTemplate.stringByReplacingOccurrencesOfString("{width}", withString: "\(Int(size.width))")
                .stringByReplacingOccurrencesOfString("{height}", withString: "\(Int(size.height))") {
                    Alamofire.request(.GET, imgUrlString!).response() {
                        (_, _, data, error) in
                        
                        guard let data = data where error == nil else {
                            //TODO: GET ERROR FROM ALAMOFIRE
                            completionHandler(image : nil, error : nil);
                            return
                        }
                        
                        let image = UIImage(data: data);
                        completionHandler(image: image, error: nil);
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
                self.titleLabel?.center.y += self.centerVerticalCoordinate
                self.subtitleLabel?.center.y += self.centerVerticalCoordinate
                self.titleLabel?.alpha = 1;
                self.subtitleLabel?.alpha = 1;
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                self.titleLabel?.center.y -= self.centerVerticalCoordinate
                self.subtitleLabel?.center.y -= self.centerVerticalCoordinate
                self.titleLabel?.alpha = 0;
                self.subtitleLabel?.alpha = 0;
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
    }
    
    var centerVerticalCoordinate: CGFloat {
        get {
            switch representedItem {
            case is TwitchGame:
                return 40
            case is TwitchStream:
                return 22
            default:
                return 22
            }
        }
    }
    
    /////////////////////////////
    // MARK - Getter and setters
    /////////////////////////////
    
    func getRepresentedItem() -> CellItem? {
        return self.representedItem;
    }
    
    func setRepresentedItem(item : CellItem) {
        self.representedItem = item;
        titleLabel!.text = item.title
        subtitleLabel?.text = item.subtitle
        self.assignImageAndDisplay();
        
    }
    
}
