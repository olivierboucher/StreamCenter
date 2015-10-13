//
//  ViewController.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import UIKit

class GamesViewController : LoadingViewController {

    private let LOADING_BUFFER = 20
    private let NUM_COLUMNS = 5
    private let ITEMS_INSETS_X : CGFloat = 25
    private let ITEMS_INSETS_Y : CGFloat = 0
    private let GAME_IMG_HEIGHT_RATIO : CGFloat = 1.39705882353 //Computed from sampled image from twitch api
    
    private var searchField: UITextField!
    private var games = [TwitchGame]()
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecognizer.cancelsTouchesInView = true
        self.view.addGestureRecognizer(longPressRecognizer)
        
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
        
        if self.games.count == 0 {
            loadContent()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadContent() {
        self.removeErrorView()
        self.displayLoadingView("Loading Games...")
        TwitchApi.getTopGamesWithOffset(0, limit: 17) {
            (games, error) in
            
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
    }
    
    func configureViews() {
        
        //then do the search bar
        self.searchField = UITextField(frame: CGRectZero)
        self.searchField.translatesAutoresizingMaskIntoConstraints = false
        self.searchField.placeholder = "Search Games or Streams"
        self.searchField.delegate = self
        self.searchField.textAlignment = .Center
        
        //do the top bar first
        self.topBar = TopBarView(frame: CGRectZero, withMainTitle: "Top Games", supplementalView: self.searchField)
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
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        TwitchApi.authenticate { (authorized) -> () in
            print(authorized)
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


extension GamesViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedGame = games[indexPath.row]
        let streamsViewController = StreamsViewController(game: selectedGame)
        
        self.presentViewController(streamsViewController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == self.games.count - 1){
            TwitchApi.getTopGamesWithOffset(games.count, limit: LOADING_BUFFER) {
                (games, error) in
                
                if(error != nil || games == nil){
                    NSLog("Error loading more games")
                }
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
                
                self.collectionView!.performBatchUpdates({
                    self.games.appendContentsOf(filteredGames)
                    
                    self.collectionView!.insertItemsAtIndexPaths(paths)
                    
                    }, completion: nil)
            }
        }
    }
}

//////////////////////////////////////////////////////
// MARK - UICollectionViewDelegateFlowLayout interface
//////////////////////////////////////////////////////

extension GamesViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = collectionView.bounds.width / CGFloat(NUM_COLUMNS) - CGFloat(ITEMS_INSETS_X * 2)
            //Computed using the ratio from sampled from
            let height = (width * GAME_IMG_HEIGHT_RATIO) + ItemCellView.LABEL_HEIGHT * 2 //There 2 labels, top & bottom
            
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

extension GamesViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //The number of sections
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If the count of games allows the current row to be full
        return games.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ItemCellView = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellView.CELL_IDENTIFIER, forIndexPath: indexPath) as! ItemCellView
        cell.setRepresentedItem(games[indexPath.row])
        return cell
    }
}

//////////////////////////////////////////////
// MARK - UITextFieldDelegate interface
//////////////////////////////////////////////

extension GamesViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard let term = textField.text where !term.isEmpty else {
            return
        }
        
        let searchViewController = SearchResultsViewController(seatchTerm: term)
        presentViewController(searchViewController, animated: true, completion: nil)
    }
}

//////////////////////////////////////////////
// MARK - UISearchResultsUpdating interface
//////////////////////////////////////////////

//extension GamesViewController : UISearchResultsUpdating {
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        print("doesn't do anything yet")
//    }
//}
