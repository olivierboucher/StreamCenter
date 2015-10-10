//
//  StreamsViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.

import UIKit
import Foundation


class StreamsViewController : LoadingViewController {
    private let LOADING_BUFFER = 12;
    private let NUM_COLUMNS = 3;
    private let ITEMS_INSETS_X : CGFloat = 45;
    private let ITEMS_INSETS_Y : CGFloat = 30;
    private let TOP_BAR_HEIGHT : CGFloat = 100;
    private let PREVIEW_IMG_HEIGHT_RATIO : CGFloat = 1.777777777; //Computed from sampled image from twitch api
    
    private var game : TwitchGame?
    private var topBar : TopBarView?
    private var collectionView : UICollectionView?
    private var streams : [TwitchStream]?
    
    convenience init(game : TwitchGame){
        self.init(nibName: nil, bundle: nil)
        self.game = game
    }
    
    /*
    * viewWillAppear(animated: Bool)
    *
    * Overrides the super function to reload the collection view with fresh data
    * 
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.streams == nil {
            loadContent()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadContent() {
        self.removeErrorView()
        self.displayLoadingView("Loading Streams...")
        TwitchApi.getTopStreamsForGameWithOffset(self.game!.name, offset: 0, limit: 20) {
            (streams, error) in
            
            guard let streams = streams else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeLoadingView()
                    self.displayErrorView("Error loading streams list.\nPlease check your internet connection.")
                });
                return
            }
            
            self.streams = streams
            dispatch_async(dispatch_get_main_queue(), {
                if((self.topBar == nil) || !(self.topBar!.isDescendantOfView(self.view))) {
                    let topBarBounds = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.TOP_BAR_HEIGHT)
                    self.topBar = TopBarView(frame: topBarBounds, withMainTitle: "Live Streams - \(self.game!.name)")
                    self.topBar?.backgroundColor = UIColor.init(white: 0.5, alpha: 1)
                    
                    self.view.addSubview(self.topBar!)
                }
                self.removeLoadingView()
                self.displayCollectionView();
            })
        }
    }
    
    /*
    * displayCollectionView()
    *
    * Assigns a new collection view to the controller and displays it if
    * it has not been initialized. Otherwise, it asks to reload data
    */
    private func displayCollectionView() {
        if((collectionView == nil) || !(collectionView!.isDescendantOfView(self.view))) {
            let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
            layout.scrollDirection = UICollectionViewScrollDirection.Vertical;
            layout.minimumInteritemSpacing = 10;
            layout.minimumLineSpacing = 10;
            
            self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout);
            
            self.collectionView!.registerClass(ItemCellView.classForCoder(), forCellWithReuseIdentifier: ItemCellView.CELL_IDENTIFIER);
            self.collectionView!.dataSource = self;
            self.collectionView!.delegate = self;
            self.collectionView!.contentInset = UIEdgeInsets(top: ITEMS_INSETS_Y + 10, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X)
            
            self.view.addSubview(self.collectionView!);
            self.view.bringSubviewToFront(self.topBar!)
        }
        else {
            self.collectionView!.reloadData()
        }
    }
    
    override func reloadContent() {
        loadContent()
        super.reloadContent()
    }
}

////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////

extension StreamsViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedStream = streams![(indexPath.section * NUM_COLUMNS) +  indexPath.row]
        let videoViewController = VideoViewController(stream: selectedStream)
        
        self.presentViewController(videoViewController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if((indexPath.section * NUM_COLUMNS) + indexPath.row == streams!.count-1){
            TwitchApi.getTopStreamsForGameWithOffset(self.game!.name, offset: self.streams!.count, limit: LOADING_BUFFER) {
                (streams, error) in
                
                if(error != nil || streams == nil){
                    NSLog("Error loading more games")
                }
                else if(streams!.count > 0) {
                    
                    var sections = Array<NSIndexSet>()
                    
                    for var i = 0; i < streams!.count / self.NUM_COLUMNS; i++ {
                        let section = self.collectionView!.numberOfSections() + i
                        sections.append(NSIndexSet(index: section))
                    }
                    
                    self.collectionView!.performBatchUpdates({
                        self.streams!.appendContentsOf(streams!)
                        
                        for section in sections {
                            self.collectionView!.insertSections(section)
                        }
                        
                    }, completion: nil)
                }
            }
        }
    }
}

//////////////////////////////////////////////////////
// MARK - UICollectionViewDelegateFlowLayout interface
//////////////////////////////////////////////////////

extension StreamsViewController : UICollectionViewDelegateFlowLayout {
    
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

//////////////////////////////////////////////
// MARK - UICollectionViewDataSource interface
//////////////////////////////////////////////

extension StreamsViewController : UICollectionViewDataSource {
    
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