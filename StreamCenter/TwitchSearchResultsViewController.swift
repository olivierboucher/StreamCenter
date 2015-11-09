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
    
    override var NUM_COLUMNS: Int {
        switch searchType {
        case .Game:
            return 5
        case .Stream:
            return 3
        }
    }
    
    override var ITEMS_INSETS_X: CGFloat {
        get {
            switch searchType {
            case .Game:
                return 25
            case .Stream:
                return 45
            }
        }
    }
    
    override var HEIGHT_RATIO: CGFloat {
        get {
            switch searchType {
            case .Game:
                return 1.39705882353
            case .Stream:
                return 0.5625
            }
        }
    }
    
    private var searchType = SearchType.Game
    
    private var searchTerm: String!
    private var games = [TwitchGame]()
    private var streams = [TwitchStream]()
    
    private var searchTypeControl: UISegmentedControl!
    
    convenience init(searchTerm term: String) {
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
                if(self.searchType == .Game) { self.collectionView.reloadData() }
            })
        }
        TwitchApi.getStreamsWithSearchTerm(searchTerm, offset: 0, limit: LOADING_BUFFER) { (streams, error) -> () in
            guard let streams = streams else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeLoadingView()
                    self.displayErrorView("Error loading stream list.\nPlease check your internet connection.")
                })
                return
            }
            
            self.streams = streams
            dispatch_async(dispatch_get_main_queue(), {
                
                self.removeLoadingView()
                if(self.searchType == .Stream) { self.collectionView.reloadData() }
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
    
    override func loadMore() {
        if searchType == .Stream {
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
    
    override var itemCount: Int {
        get {
            switch searchType {
                case .Game:
                    return games.count
                case .Stream:
                    return streams.count
                }
        }
    }
    
    override func getItemAtIndex(index: Int) -> CellItem {
        switch searchType {
            case .Game:
                return games[index]
            case .Stream:
                return streams[index]
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
    
}
