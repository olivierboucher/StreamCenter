//
//  HitboxSearchResultsViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/15/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
class HitboxSearchResultsViewController: LoadingViewController {
    
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
    
    private var searchTerm: String!
    private var games = [HitboxGame]()
    
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
        
        if self.games.count == 0 {
            loadContent()
        }
    }
    
    func loadContent() {
        self.removeErrorView()
        self.displayLoadingView("Loading Results...")
        HitboxAPI.getGames(0, limit: LOADING_BUFFER, searchTerm: searchTerm) { (games, error) -> () in
            guard let games = games else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeLoadingView()
                    self.displayErrorView("Error loading search results.\nPlease check your internet connection.")
                })
                return
            }
            
            self.games = games
            dispatch_async(dispatch_get_main_queue(), {
                
                self.removeLoadingView()
                self.collectionView.reloadData()
            })
        }
    }
    
    private func configureViews() {
        super.configureViews("Search Results - \(searchTerm)", centerView: nil, leftView: nil, rightView: nil)
    }
    
    override func reloadContent() {
        loadContent()
        super.reloadContent()
    }
    
    override func loadMore() {
        HitboxAPI.getGames(games.count, limit: LOADING_BUFFER, searchTerm: self.searchTerm, completionHandler: { (games, error) -> () in
            guard let games = games where games.count > 0 else {
                return
            }
            
            var paths = [NSIndexPath]()
            
            let filteredGames = games.filter({
                let gameId = $0.id
                if let _ = self.games.indexOf({$0.id == gameId}) {
                    return false
                }
                return true
            })
            
            for i in 0..<filteredGames.count {
                paths.append(NSIndexPath(forItem: i + self.games.count, inSection: 0))
            }
            
            self.collectionView.performBatchUpdates({
                self.games.appendContentsOf(filteredGames)
                
                self.collectionView.insertItemsAtIndexPaths(paths)
                
                }, completion: nil)
        })
    }
    
    override var itemCount: Int {
        get {
            return games.count
        }
    }
    
    override func getItemAtIndex(index: Int) -> CellItem {
        return games[index]
    }
}

////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////

extension HitboxSearchResultsViewController {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedGame = games[indexPath.row]
        let streamViewController = HitboxStreamsViewController(game: selectedGame)
        self.presentViewController(streamViewController, animated: true, completion: nil)
    }
}

//////////////////////////////////////////////
// MARK - UICollectionViewDataSource interface
//////////////////////////////////////////////

extension HitboxSearchResultsViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If the count of streams allows the current row to be full
        return games.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ItemCellView = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellView.CELL_IDENTIFIER, forIndexPath: indexPath) as! ItemCellView
        cell.setRepresentedItem(games[indexPath.row])
        return cell
    }
}
