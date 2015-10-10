//
//  YoutubeStreamsVIewController.swift
//  GamingStreamsTVApp
//
//  Created by Chayel Heinsen on 10/10/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class YoutubeStreamsViewController: LoadingViewController {
    private let LOADING_BUFFER = 20;
    private let TOP_BAR_HEIGHT : CGFloat = 100;
    private let NUM_COLUMNS = 3;
    private let ITEMS_INSETS_X : CGFloat = 45;
    private let ITEMS_INSETS_Y : CGFloat = 30;
    private let PREVIEW_IMG_HEIGHT_RATIO : CGFloat = 1.777777777;
    
    private var collectionView : UICollectionView?
    private var streams : Array<YoutubeStream>?
    
    convenience init(){
        self.init(nibName: nil, bundle: nil);
    }
    
    /*
    * viewWillAppear(animated: Bool)
    *
    * Overrides the super function to reload the collection view with fresh data
    *
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.collectionView == nil) {
            self.displayLoadingView()
        }
        
        YoutubeGaming.streamsWithPageToken(nil) { (streams, error) -> Void in
            
            guard let streams = streams where error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if (self.errorView == nil) {
                        self.removeLoadingView()
                        self.displayErrorView("Error loading game list.\nPlease check your internet connection.")
                    }
                });
                
                return
            }
            
            self.streams = streams
            
            dispatch_async(dispatch_get_main_queue(), {
                self.removeLoadingView()
                self.removeErrorView()
                self.displayCollectionView();
            })
        }
    }
    
    // MARK: - Private
    
    /*
    * displayCollectionView()
    *
    * Assigns a new collection view to the controller and displays it if
    * it has not been initialized. Otherwise, it asks to reload data
    */
    private func displayCollectionView() {
        
        if ((collectionView == nil) || !(collectionView!.isDescendantOfView(self.view))) {
            let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
            layout.scrollDirection = UICollectionViewScrollDirection.Vertical;
            layout.minimumInteritemSpacing = 10;
            layout.minimumLineSpacing = 10;
            
            let collectionViewBounds = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            
            self.collectionView = UICollectionView(frame: collectionViewBounds, collectionViewLayout: layout);
            
            self.collectionView!.registerClass(ItemCellView.classForCoder(), forCellWithReuseIdentifier: ItemCellView.CELL_IDENTIFIER);
            self.collectionView!.dataSource = self;
            self.collectionView!.delegate = self;
            self.collectionView!.contentInset = UIEdgeInsets(top: ITEMS_INSETS_Y + 10, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X)
            
            self.view.addSubview(self.collectionView!)
        } else {
            collectionView?.reloadData()
        }
    }
}

// MARK - UICollectionViewDelegate interface

extension YoutubeStreamsViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedStream = streams![(indexPath.section * NUM_COLUMNS) +  indexPath.row]
        let videoViewController = YoutubeVideoViewController(stream: selectedStream)
        
        self.presentViewController(videoViewController, animated: true, completion: nil)
    }
    /*
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if ((indexPath.section * NUM_COLUMNS) + indexPath.row == streams!.count - 1) {
            
            TwitchApi.getTopStreamsForGameWithOffset(self.game!.name, offset: self.streams!.count, limit: LOADING_BUFFER) {
                (streams, error) in
                
                guard let streams = streams where error == nil else {
                    NSLog("Error loading more streams")
                    return
                }
                
                var sections = Array<NSIndexSet>()
                
                for var i = 0; i < streams.count / self.NUM_COLUMNS; i++ {
                    let section = self.collectionView!.numberOfSections() + i
                    sections.append(NSIndexSet(index: section))
                }
                
                self.collectionView!.performBatchUpdates({
                    self.streams!.appendContentsOf(streams)
                    
                    for section in sections {
                        self.collectionView!.insertSections(section)
                    }
                    
                    }, completion: nil)
            }
            
        }
    }
    */
}

// MARK: - UICollectionViewDelegateFlowLayout interface

extension YoutubeStreamsViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = self.view.bounds.width / CGFloat(NUM_COLUMNS) - CGFloat(ITEMS_INSETS_X * 2);
            let height = width / PREVIEW_IMG_HEIGHT_RATIO + (ItemCellView.LABEL_HEIGHT * 2); //There 2 labels, top & bottom
            
            return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            let topInset = (section == 0) ? TOP_BAR_HEIGHT : ITEMS_INSETS_X
            return UIEdgeInsets(top: topInset, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X);
    }
}

// MARK: - UICollectionViewDataSource interface

extension YoutubeStreamsViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //The number of possible rows
        return Int(ceil(Double(streams!.count) / Double(NUM_COLUMNS)));
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If the count of streams allows the current row to be full
        if((section+1) * NUM_COLUMNS <= streams!.count){
            return NUM_COLUMNS;
        }
            // the row cannot be full so we return the difference
        else {
            return streams!.count - ((section) * NUM_COLUMNS)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ItemCellView = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellView.CELL_IDENTIFIER, forIndexPath: indexPath) as! ItemCellView
        cell.setRepresentedItem(streams![(indexPath.section * NUM_COLUMNS) +  indexPath.row])
        return cell;
    }
}
