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
    private let ITEMS_INSETS_Y : CGFloat = 40
    private let TOP_BAR_HEIGHT : CGFloat = 100
    private let GAME_IMG_HEIGHT_RATIO : CGFloat = 1.39705882353 //Computed from sampled image from twitch api
    
    private var searchField: UITextField!
    private var games : [TwitchGame]?
    
    var didSearch = false
    
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
        
        if self.games == nil {
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
                });
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
        //do the top bar first
        let topBarBounds = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.TOP_BAR_HEIGHT)
        self.topBar = TopBarView(frame: topBarBounds, withMainTitle: "Top Games")
        self.topBar.backgroundColor = UIColor(white: 0.5, alpha: 1)
        self.view.addSubview(self.topBar)
        
        //then do the search bar
        let searchBarFrame = CGRect(x: 0, y: CGRectGetMaxY(topBarBounds), width: 600, height: self.TOP_BAR_HEIGHT / 1.5)
        self.searchField = UITextField(frame: searchBarFrame)
        self.searchField.placeholder = "Search"
        self.searchField.delegate = self
        self.searchField.center.x = CGRectGetMidX(self.view.bounds)
        self.searchField.center.y += 15;
        self.definesPresentationContext = true
        self.view.addSubview(self.searchField)
        
        //then do the collection view
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical;
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 50
        
        let collectionViewBounds = CGRect(x: self.view.bounds.origin.x, y: CGRectGetMaxY(searchBarFrame), width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        
        self.collectionView = UICollectionView(frame: collectionViewBounds, collectionViewLayout: layout);
        
        self.collectionView.registerClass(ItemCellView.classForCoder(), forCellWithReuseIdentifier: ItemCellView.CELL_IDENTIFIER);
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X)
        
        self.view.addSubview(self.collectionView)
        self.view.bringSubviewToFront(self.topBar)
        self.view.bringSubviewToFront(self.searchField)
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            
            let alert = UIAlertController(title: "Search", message: "Please enter a search term", preferredStyle: .Alert)
            
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "Call of Duty"
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Search", style: .Default, handler: { (action) -> Void in
                //do the search
                
                guard let term = alert.textFields?.first?.text where term.characters.count > 0 else {
                    return
                }
                
                TwitchApi.getGamesWithSearchTerm(term, offset: 0, limit: 20) { (games, error) -> () in
                    guard let games = games where games.count > 0 else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.removeLoadingView()
                            self.displayErrorView("Error loading game list.\nPlease check your internet connection.")
                        });
                        return
                    }
                    
                    self.games = games
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.removeLoadingView()
                        self.collectionView.reloadData()
                    })
                }
            }))
            
            presentViewController(alert, animated: true, completion: nil)
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
        let selectedGame = games![indexPath.row]
        let streamsViewController = StreamsViewController(game: selectedGame)
        
        self.presentViewController(streamsViewController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == (self.games?.count)! - 1 && !didSearch){
            TwitchApi.getTopGamesWithOffset(games!.count, limit: LOADING_BUFFER) {
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
                    if let _ = self.games!.indexOf({$0.id == gameId}) {
                        return false
                    }
                    return true
                })
                
                for i in 0..<filteredGames.count {
                    paths.append(NSIndexPath(forItem: i + self.games!.count, inSection: 0))
                }
                
                self.collectionView!.performBatchUpdates({
                    self.games!.appendContentsOf(filteredGames)
                    
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
            let width = self.view.bounds.width / CGFloat(NUM_COLUMNS) - CGFloat(ITEMS_INSETS_X * 2);
            //Computed using the ratio from sampled from
            let height = (width * GAME_IMG_HEIGHT_RATIO) + ItemCellView.LABEL_HEIGHT * 2; //There 2 labels, top & bottom
            
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

extension GamesViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //The number of sections
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If the count of games allows the current row to be full
        guard let games = games else {
            return 0
        }
        return games.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ItemCellView = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellView.CELL_IDENTIFIER, forIndexPath: indexPath) as! ItemCellView;

        guard let games = games else {
            return cell
        }
        
        cell.setRepresentedItem(games[indexPath.row]);
        
        return cell;
    }
}

//////////////////////////////////////////////
// MARK - UITextFieldDelegate interface
//////////////////////////////////////////////

extension GamesViewController : UITextFieldDelegate {
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        guard let term = textField.text where !term.isEmpty else {
            if didSearch {
                self.loadContent()
                didSearch = false
            }
            return true
        }
        displayLoadingView("Searching for '\(term)'")
        TwitchApi.getGamesWithSearchTerm(term, offset: 0, limit: 20) { (games, error) -> () in
            guard let games = games where games.count > 0 else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeLoadingView()
                    self.displayErrorView("Error loading searching for games.\nPlease check your internet connection.")
                });
                return
            }
            self.didSearch = true
            
            self.games = games
            dispatch_async(dispatch_get_main_queue(), {
                
                self.removeLoadingView()
                self.collectionView.reloadData()
            })
        }
        return true
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
