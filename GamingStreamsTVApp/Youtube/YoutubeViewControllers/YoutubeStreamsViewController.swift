//
//  YoutubeStreamsVIewController.swift
//  GamingStreamsTVApp
//
//  Created by Chayel Heinsen on 10/10/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class YoutubeStreamsViewController : LoadingViewController {
    private let LOADING_BUFFER = 20
    
    override var NUM_COLUMNS: Int {
        get {
            return 5
        }
    }
    
    override var ITEMS_INSETS_X : CGFloat {
        get {
            return 25
        }
    }
    
    override var HEIGHT_RATIO: CGFloat {
        get {
            return 1.777777777
        }
    }
    
    private var streams = [YoutubeStream]()
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
        title = "YouTube"
        YoutubeGaming.setAPIKey("AIzaSyAFLrfWAIk9gdaBbC3h7ymNpAtp9gLiWkY")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        configureViews()
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
    
    func loadContent() {
        self.removeErrorView()
        self.displayLoadingView("Loading Games...")
        
        YoutubeGaming.streamsWithPageToken(nil) { (streams, error) -> Void in
            
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
    
    func configureViews() {
        
        //then do the search bar
//        self.searchField = UITextField(frame: CGRectZero)
//        self.searchField.translatesAutoresizingMaskIntoConstraints = false
//        self.searchField.placeholder = "Search Games"
//        self.searchField.delegate = self
//        self.searchField.textAlignment = .Center
//        
//        let imageView = UIImageView(image: UIImage(named: "hitbox"))
//        imageView.contentMode = .ScaleAspectFit
        
        super.configureViews("Youtube", centerView: nil, leftView: nil, rightView: nil)
        
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
    
    
    
    override var itemCount: Int {
        get {
            return streams.count
        }
    }
    
    override func getItemAtIndex(index: Int) -> CellItem {
        return streams[index]
    }
}

// MARK - UICollectionViewDelegate interface

extension YoutubeStreamsViewController {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedStream = streams[(indexPath.section * NUM_COLUMNS) +  indexPath.row]
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
                
                var sections = [NSIndexSet]()
                
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
