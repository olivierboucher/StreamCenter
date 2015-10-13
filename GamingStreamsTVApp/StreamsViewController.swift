//
//  StreamsViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.

import UIKit
import Foundation


class StreamsViewController : LoadingViewController {
    private let LOADING_BUFFER = 12
    private let NUM_COLUMNS = 3
    private let ITEMS_INSETS_X : CGFloat = 45
    private let ITEMS_INSETS_Y : CGFloat = 0
    private let PREVIEW_IMG_HEIGHT_RATIO : CGFloat = 1.777777777 //Computed from sampled image from twitch api
    
    private var game : TwitchGame!
    private var streams = [TwitchStream]()
    
    convenience init(game : TwitchGame){
        self.init(nibName: nil, bundle: nil)
        self.game = game
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
    }
    
    /*
    * viewWillAppear(animated: Bool)
    *
    * Overrides the super function to reload the collection view with fresh data
    * 
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if self.streams.count == 0 {
            loadContent()
        }
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
                })
                return
            }
            
            self.streams = streams
            dispatch_async(dispatch_get_main_queue(), {
                self.removeLoadingView()
                self.collectionView.reloadData()
            })
        }
    }
    
    private func configureViews() {
        self.topBar = TopBarView(frame: CGRectZero, withMainTitle: "Live Streams - \(self.game!.name)")
        self.topBar.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.topBar)
        
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        layout.minimumInteritemSpacing = ITEMS_INSETS_X
        layout.minimumLineSpacing = 35
        
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.registerClass(ItemCellView.classForCoder(), forCellWithReuseIdentifier: ItemCellView.CELL_IDENTIFIER)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsets(top: TOP_BAR_HEIGHT + 10, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X)
        
        self.view.addSubview(self.collectionView)
        self.view.bringSubviewToFront(self.topBar)
        
        let viewDict = ["topbar" : topBar, "collection" : collectionView]
        
        self.topBar.addConstraint(NSLayoutConstraint(item: topBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: TOP_BAR_HEIGHT))

        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topbar]", options: [], metrics: nil, views: viewDict))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collection]|", options: [], metrics: nil, views: viewDict))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[topbar]|", options: [], metrics: nil, views: viewDict))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collection]|", options: [], metrics: nil, views: viewDict))
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
        let selectedStream = streams[indexPath.row]
        let videoViewController = VideoViewController(stream: selectedStream)
        
        self.presentViewController(videoViewController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.streams.count - 1){
            TwitchApi.getTopStreamsForGameWithOffset(self.game!.name, offset: self.streams.count, limit: LOADING_BUFFER) {
                (streams, error) in
                
                guard let streams = streams else {
                    return
                }
                var paths = [NSIndexPath]()
                
                let filteredStreams = streams.filter({
                    let streamId = $0.id
                    if let _ = self.streams.indexOf({$0.id == streamId}) {
                        return false
                    }
                    return true
                })
                
                for i in 0..<filteredStreams.count {
                    paths.append(NSIndexPath(forItem: i + self.streams.count, inSection: 0))
                }
                    
                self.collectionView!.performBatchUpdates({
                    self.streams.appendContentsOf(filteredStreams)
                
                    self.collectionView!.insertItemsAtIndexPaths(paths)
                
                }, completion: nil)
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
            let width = collectionView.bounds.width / CGFloat(NUM_COLUMNS) - CGFloat(ITEMS_INSETS_X * 2)
            let height = width / PREVIEW_IMG_HEIGHT_RATIO + (ItemCellView.LABEL_HEIGHT * 2) //There 2 labels, top & bottom
            
            return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            let topInset = (section == 0) ? TOP_BAR_HEIGHT : ITEMS_INSETS_X
            return UIEdgeInsets(top: topInset, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X)
    }
    
}

//////////////////////////////////////////////
// MARK - UICollectionViewDataSource interface
//////////////////////////////////////////////

extension StreamsViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //The number of possible rows
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If the count of streams allows the current row to be full
        return streams.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ItemCellView = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellView.CELL_IDENTIFIER, forIndexPath: indexPath) as! ItemCellView
        cell.setRepresentedItem(streams[indexPath.row])
        return cell
    }
}