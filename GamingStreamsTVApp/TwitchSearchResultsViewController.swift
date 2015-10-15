//
//  TwitchSearchResultsViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/12/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

private enum SearchType {
    case Game
    case Stream
}

class TwitchSearchResultsViewController: LoadingViewController {
    
    private let LOADING_BUFFER = 20
    
    private var searchType = SearchType.Game
    
    private var searchTerm: String!
    private var games = [TwitchGame]()
    private var streams = [TwitchStream]()
    
    private var searchTypeControl: UISegmentedControl!
    
    convenience init(seatchTerm term: String) {
        self.init(nibName: nil, bundle: nil)
        self.searchTerm = term
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    * viewWillAppear(animated: Bool)
    *
    * Overrides the super function to reload the collection view with fresh data
    *
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.streams.count == 0 || self.games.count == 0 {
            loadContent()
        }
    }
    
    func loadContent() {
        self.removeErrorView()
        self.displayLoadingView("Loading Results...")
        TwitchApi.getGamesWithSearchTerm(searchTerm, offset: 0, limit: LOADING_BUFFER) { (games, error) -> () in
            guard let games = games else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeLoadingView()
                    self.displayErrorView("Error loading game list.\nPlease check your internet connection.")
                })
                return
            }
            
            self.games = games
            dispatch_async(dispatch_get_main_queue(), {
                
                self.removeLoadingView()
                self.collectionView.reloadData()
            })
        }
        TwitchApi.getStreamsWithSearchTerm(searchTerm, offset: 0, limit: LOADING_BUFFER) { (streams, error) -> () in
            guard let streams = streams else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeLoadingView()
                    self.displayErrorView("Error loading game list.\nPlease check your internet connection.")
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
        
        //then do the search bar
        self.searchTypeControl = UISegmentedControl(items: ["Games", "Streams"])
        self.searchTypeControl.translatesAutoresizingMaskIntoConstraints = false
        self.searchTypeControl.selectedSegmentIndex = 0
        self.searchTypeControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(white: 0.45, alpha: 1)], forState: .Normal)
        self.searchTypeControl.addTarget(self, action: Selector("changedSearchType:"), forControlEvents: .ValueChanged)
        
        super.configureViews("Search Results - \(searchTerm)", centerView: nil, leftView: self.searchTypeControl, rightView: nil)
    }
    
    override func reloadContent() {
        loadContent()
        super.reloadContent()
    }
    
    func changedSearchType(control: UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            searchType = .Game
        case 1:
            searchType = .Stream
        default:
            return
        }
        collectionView.reloadData()
    }
    
    var numberOfColumns: Int {
        switch searchType {
        case .Game:
            return 5
        case .Stream:
            return 3
        }
    }
    
    var itemInset: CGFloat {
        switch searchType {
        case .Game:
            return 25
        case .Stream:
            return 45
        }
    }

}

////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////

extension TwitchSearchResultsViewController {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch searchType {
        case .Game:
            let selectedGame = games[indexPath.row]
            let streamViewController = TwitchStreamsViewController(game: selectedGame)
            self.presentViewController(streamViewController, animated: true, completion: nil)
        case .Stream:
            let selectedStream = streams[indexPath.row]
            let videoViewController = TwitchVideoViewController(stream: selectedStream)
            
            self.presentViewController(videoViewController, animated: true, completion: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        switch searchType {
        case .Game:
            //games don't support an offset to load more items
            return
        case .Stream:
            if (indexPath.row == self.streams.count - 1) {
                TwitchApi.getStreamsWithSearchTerm(self.searchTerm, offset: self.streams.count, limit: LOADING_BUFFER, completionHandler: { (streams, error) -> () in
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
                    
                    self.collectionView.performBatchUpdates({
                        self.streams.appendContentsOf(filteredStreams)
                        
                        self.collectionView.insertItemsAtIndexPaths(paths)
                        
                        }, completion: nil)
                })
            }
        }
    }
}

//////////////////////////////////////////////////////
// MARK - UICollectionViewDelegateFlowLayout interface
//////////////////////////////////////////////////////

extension TwitchSearchResultsViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = collectionView.bounds.width / CGFloat(numberOfColumns) - CGFloat(itemInset * 2)
            var height: CGFloat!
            
            switch searchType {
            case .Game:
                height = (width * GAME_IMG_HEIGHT_RATIO) + ItemCellView.LABEL_HEIGHT * 2 //There 2 labels, top & bottom
            case .Stream:
                height = width / STREAM_IMG_HEIGHT_RATIO + (ItemCellView.LABEL_HEIGHT * 2) //There 2 labels, top & bottom
            }
            
            return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: TOP_BAR_HEIGHT + ITEMS_INSETS_Y, left: itemInset, bottom: ITEMS_INSETS_Y, right: itemInset)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return itemInset
    }
}

//////////////////////////////////////////////
// MARK - UICollectionViewDataSource interface
//////////////////////////////////////////////

extension TwitchSearchResultsViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If the count of streams allows the current row to be full
        switch searchType {
        case .Game:
            return games.count
        case .Stream:
            return streams.count
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ItemCellView = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellView.CELL_IDENTIFIER, forIndexPath: indexPath) as! ItemCellView
        switch searchType {
        case .Game:
            cell.setRepresentedItem(games[indexPath.row])
        case .Stream:
            cell.setRepresentedItem(streams[indexPath.row])
        }
        return cell
    }
}
