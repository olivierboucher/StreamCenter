//
//  LoadingViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-29.

import UIKit
import Foundation

//NOTE(Olivier):
//Swift doesn't provide any way to abstract a class like Java or C#
//This is not a protocol because I don't want to copy this code in each controller

class LoadingViewController : UIViewController {
    
    internal let TOP_BAR_HEIGHT : CGFloat = 100
    var ITEMS_INSETS_X : CGFloat {
        get {
            return 0
        }
    }
    internal let ITEMS_INSETS_Y : CGFloat = 0
    internal let GAME_IMG_HEIGHT_RATIO : CGFloat = 1.39705882353 //Computed from sampled image from twitch api
    internal let STREAM_IMG_HEIGHT_RATIO : CGFloat = 1.777777777 //Computed from sampled image from twitch api
    
    internal var collectionView : UICollectionView!
    internal var topBar : TopBarView!
    
    internal var loadingView : LoadingView?
    internal var errorView : ErrorView?
    private var reloadLabel : UILabel?
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(white: 0.4, alpha: 1)
    }
    
    /*
    * displayLoadingView()
    *
    * Initializes a loading view in the center of the screen and displays it
    *
    */
    func displayLoadingView(loading: String = "Loading...")  {
        self.loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width/5, height: self.view.bounds.height/5), text: loading)
        self.loadingView?.center = self.view.center
        self.view.addSubview(self.loadingView!)
    }
    
    /*
    * removeLoadingView()
    *
    * Removes the loading view if existant
    *
    */
    func removeLoadingView() {
        if self.loadingView != nil {
            self.loadingView?.removeFromSuperview()
            self.loadingView = nil
        }
    }
    
    /*
    * displayErrorView(title : String)
    *
    * Initializes an error view in the center of the screen and displays it
    *
    */
    func displayErrorView(title : String) {
        self.errorView = ErrorView(dimension: 450, andTitle: title)
        self.errorView?.center = self.view.center
        self.view.addSubview(self.errorView!)
        
        self.reloadLabel = UILabel()
        self.reloadLabel?.text = "Press and hold on your remote to reload the content."
        self.reloadLabel?.font = self.reloadLabel?.font.fontWithSize(25)
        self.reloadLabel?.sizeToFit()
        self.reloadLabel?.center = CGPoint(x: CGRectGetMidX(self.errorView!.frame), y: CGRectGetMaxY(self.errorView!.frame))
        self.reloadLabel?.center.y += 10
        self.reloadLabel?.textColor = UIColor.whiteColor()
        self.view.addSubview(self.reloadLabel!)
        
        //Gestures configuration
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        longPressRecognizer.cancelsTouchesInView = true
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    /*
    * removeErrorView()
    *
    * Removes the error view if existant
    *
    */
    func removeErrorView() {
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
            self.errorView = nil
        }
        if self.reloadLabel != nil {
            self.reloadLabel?.removeFromSuperview()
            self.reloadLabel = nil
        }
    }
    
    /*
    * removeErrorView()
    *
    * Removes the error view if existant
    *
    */
    func configureViews(topBarTitle: String, centerView: UIView? = nil, leftView: UIView? = nil, rightView: UIView? = nil) {
        
        //do the top bar first
        self.topBar = TopBarView(frame: CGRectZero, withMainTitle: "Top Games", centerView: centerView, leftView: leftView, rightView: rightView)
        self.topBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.topBar)
        
        //then do the collection view
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        layout.minimumInteritemSpacing = ITEMS_INSETS_X
        layout.minimumLineSpacing = 50
        
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.registerClass(ItemCellView.classForCoder(), forCellWithReuseIdentifier: ItemCellView.CELL_IDENTIFIER)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsets(top: TOP_BAR_HEIGHT + ITEMS_INSETS_Y, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X)
        
        self.view.addSubview(self.collectionView)
        self.view.bringSubviewToFront(self.topBar)
        
        let viewDict = ["topbar" : topBar, "collection" : collectionView]
        
        self.view.addConstraint(NSLayoutConstraint(item: topBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: TOP_BAR_HEIGHT))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topbar]", options: [], metrics: nil, views: viewDict))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collection]|", options: [], metrics: nil, views: viewDict))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[topbar]|", options: [], metrics: nil, views: viewDict))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collection]|", options: [], metrics: nil, views: viewDict))
        
    }
    
    /*
    *
    * Implement this on the child view controller to reload content if there was an error
    *
    */
    func reloadContent() {
        print("we are reloading the content now: \(self)")
    }
    
    /*
    * handleLongPress(recognizer: UILongPressGestureRecognizer)
    *
    * This is so that if the content doesn't load the first time around, we can load it again
    *
    */
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .Began {
            self.view.removeGestureRecognizer(recognizer)
            reloadContent()
        }
        
    }
}

////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////


extension LoadingViewController : UICollectionViewDelegate {
    
}

//////////////////////////////////////////////
// MARK - UICollectionViewDataSource interface
//////////////////////////////////////////////

extension LoadingViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //The number of sections
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If the count of games allows the current row to be full
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ItemCellView = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellView.CELL_IDENTIFIER, forIndexPath: indexPath) as! ItemCellView
        return cell
    }
}