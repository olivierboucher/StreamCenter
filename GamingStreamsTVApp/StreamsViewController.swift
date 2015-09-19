//
//  StreamsViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import UIKit
import Foundation


class StreamsViewController : UIViewController {
    
    private let NUM_COLUMNS = 4;
    private let ITEMS_INSETS_X : CGFloat = 25;
    private let ITEMS_INSETS_Y : CGFloat = 40;
    private let TOP_BAR_HEIGHT : CGFloat = 100;
    
    private var _game : TwitchGame?
    private var _topBar : TopBarView?
    private var _collectionView : UICollectionView?;
    private var _loadingView : LoadingView?
    private var _streams : NSArray?;
    
    convenience init(game : TwitchGame){
        self.init(nibName: nil, bundle: nil);
        self._game = game;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(self._collectionView == nil){
            self._loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width/5, height: self.view.bounds.height/5))
            self._loadingView?.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
            self.view.addSubview(_loadingView!)
        }
        
        TwitchApi.getTopStreamsForGameWithOffset(self._game!.getName(), offset: 0, limit: 20) {
            (streams, error) in
            
            if(error != nil){
                NSLog("Error loading top streams for game");
            }
            if(streams != nil) {
                self._streams = streams!
                dispatch_async(dispatch_get_main_queue(),{
                    if((self._topBar == nil) || !(self._topBar!.isDescendantOfView(self.view))) {
                        let topBarBounds = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.TOP_BAR_HEIGHT)
                        self._topBar = TopBarView(frame: topBarBounds, withMainTitle: "Live Streams - \(self._game!.getName())", backButtonTitle : "Games") {
                            //This is the callback that gets called on back button exit
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        self._topBar?.backgroundColor = UIColor.init(white: 0.5, alpha: 1)
                        
                        self.view.addSubview(self._topBar!)
                    }
                    if((self._loadingView != nil) && (self._loadingView!.isDescendantOfView(self.view))){
                        self._loadingView?.removeFromSuperview()
                        self._loadingView = nil
                    }
                    self.displayCollectionView();
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func displayCollectionView() {
        if((_collectionView == nil) || !(_collectionView!.isDescendantOfView(self.view))) {
            let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
            layout.scrollDirection = UICollectionViewScrollDirection.Vertical;
            layout.minimumInteritemSpacing = 10;
            layout.minimumLineSpacing = 10;
            
            self._collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout);
            
            self._collectionView!.registerClass(StreamCellView.classForCoder(), forCellWithReuseIdentifier: StreamCellView.cellIdentifier);
            self._collectionView!.dataSource = self;
            self._collectionView!.delegate = self;
            self._collectionView!.contentInset = UIEdgeInsets(top: ITEMS_INSETS_Y + 10, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X)
            
            self.view.addSubview(self._collectionView!);
            self.view.bringSubviewToFront(self._topBar!)
        }
        else {
            self._collectionView!.reloadData()
        }
    }
}

extension StreamsViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //TODO: get stream info and launch it
        let selectedStream = _streams!.objectAtIndex((indexPath.section * NUM_COLUMNS) +  indexPath.row) as! TwitchStream
        let videoViewController = VideoViewController(stream: selectedStream)
        
        self.presentViewController(videoViewController, animated: true, completion: nil)
    }
}

extension StreamsViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = self.view.bounds.width / CGFloat(NUM_COLUMNS) - CGFloat(ITEMS_INSETS_X * 2);
            let height = width / 1.777777777;
            
            return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            let topInset = (section == 0) ? TOP_BAR_HEIGHT : ITEMS_INSETS_X
            return UIEdgeInsets(top: topInset, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X);
    }
}

extension StreamsViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        let test = Double(_streams!.count) / Double(NUM_COLUMNS);
        let test2 = ceil(test);
        
        return Int(test2);
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if((section+1) * NUM_COLUMNS <= _streams!.count){
            //NSLog("count for section #%d : %d", section, NUM_COLUMNS);
            return NUM_COLUMNS;
        }
        else {
            //NSLog("count for section #%d : %d", section, _games!.count - ((section) * NUM_COLUMNS));
            return _streams!.count - ((section) * NUM_COLUMNS)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : StreamCellView = collectionView.dequeueReusableCellWithReuseIdentifier(StreamCellView.cellIdentifier, forIndexPath: indexPath) as! StreamCellView;
        //NSLog("Indexpath => section:%d row:%d", indexPath.section, indexPath.row);
        cell.setStream(_streams!.objectAtIndex((indexPath.section * NUM_COLUMNS) +  indexPath.row) as! TwitchStream);
        return cell;
    }
}