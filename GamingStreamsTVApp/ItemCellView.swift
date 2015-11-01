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
    var bannerString: String? { get }
    var image: UIImage? { get }
    mutating func setImage(image: UIImage)
}

class ItemCellView: UICollectionViewCell {
    internal static let CELL_IDENTIFIER : String = "kItemCellView"
    internal static let LABEL_HEIGHT : CGFloat = 40
    
    private var representedItem : CellItem?
    private var image : UIImage?
    private var imageView : UIImageView!
    private var activityIndicator : UIActivityIndicatorView!
    private var titleLabel : ScrollingLabel!
    private var subtitleLabel : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageViewFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-80)
        self.imageView = UIImageView(frame: imageViewFrame)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.adjustsImageWhenAncestorFocused = true
        //we don't need to have this next line because we are turning on the 'adjustsImageWhenAncestorFocused' therefore we can't clip to bounds, and the corner radius has no effect if we aren't clipping
        self.imageView.layer.cornerRadius = 10
        self.imageView.backgroundColor = UIColor(white: 0.25, alpha: 0.7)
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.activityIndicator = UIActivityIndicatorView(frame: imageViewFrame)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator.startAnimating()
        
        self.titleLabel = ScrollingLabel(scrollSpeed: 0.5)
        self.subtitleLabel = UILabel()
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.alpha = 0.5
        self.subtitleLabel.alpha = 0.5
        self.titleLabel.font = UIFont.systemFontOfSize(30, weight: UIFontWeightSemibold)
        self.subtitleLabel.font = UIFont.systemFontOfSize(30, weight: UIFontWeightThin)
        self.titleLabel.textColor = UIColor.whiteColor()
        self.subtitleLabel.textColor = UIColor.whiteColor()
        
        self.imageView.addSubview(self.activityIndicator)
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subtitleLabel)
        
        let viewDict = ["image" : imageView, "title" : titleLabel, "subtitle" : subtitleLabel, "imageGuide" : imageView.focusedFrameGuide]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[image]|", options: [], metrics: nil, views: viewDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[title]|", options: [], metrics: nil, views: viewDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subtitle]|", options: [], metrics: nil, views: viewDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[image]", options: [], metrics: nil, views: viewDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageGuide]-5-[title(\(ItemCellView.LABEL_HEIGHT))]-5-[subtitle(\(ItemCellView.LABEL_HEIGHT))]|", options: [], metrics: nil, views: viewDict))
        
        self.imageView.addCenterConstraints(toView: self.activityIndicator)
        
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
        self.imageView.image = nil
        self.titleLabel.text = ""
        self.subtitleLabel.text = ""
        
        self.activityIndicator = UIActivityIndicatorView(frame: self.imageView.frame)
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator.startAnimating()
        
        self.imageView.addSubview(self.activityIndicator!)
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
            
            if let image = image {
                self.image = image
            } else {
                self.image = nil
            }
            
            
            dispatch_async(dispatch_get_main_queue(),{
                if self.activityIndicator != nil  {
                    self.activityIndicator?.removeFromSuperview()
                    self.activityIndicator = nil
                }
                self.imageView.image = self.image
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
        if let image = representedItem?.image {
            completionHandler(image: image, error: nil)
            return
        }
        if let imgUrlTemplate = representedItem?.urlTemplate {
            let imgUrlString = imgUrlTemplate.stringByReplacingOccurrencesOfString("{width}", withString: "\(Int(size.width))")
                .stringByReplacingOccurrencesOfString("{height}", withString: "\(Int(size.height))")
            Alamofire.request(.GET, imgUrlString).response() {
                (_, _, data, error) in
                
                guard let data = data, image = UIImage(data: data) else {
                    completionHandler(image: nil, error: nil)
                    return
                }
                self.representedItem?.setImage(image)
                completionHandler(image: image, error: nil)
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
                self.titleLabel.alpha = 1
                self.subtitleLabel.alpha = 1
                self.titleLabel.beginScrolling()
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                self.titleLabel.alpha = 0.5
                self.subtitleLabel.alpha = 0.5
                self.titleLabel.endScrolling()
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
        return self.representedItem
    }
    
    func setRepresentedItem(item : CellItem) {
        self.representedItem = item
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        self.assignImageAndDisplay()
    }
    
}
