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
    
    private var topBar : TopBarView?
    private var collectionView : UICollectionView?
    private var games : [TwitchGame]?
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(longPressRecognizer)
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
                self.layoutAndDisplayViews();
            })
        }
    }
    
    /*
     * layoutAndDisplayViews()
     *
     * Assigns a new collection view to the controller and displays it if
     * it has not been initialized. Otherwise, it asks to reload data
     */
    private func layoutAndDisplayViews() {
        
        if((self.topBar == nil) || !(self.topBar!.isDescendantOfView(self.view))) {
            let topBarBounds = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.TOP_BAR_HEIGHT)
            self.topBar = TopBarView(frame: topBarBounds, withMainTitle: "Top Games")
            self.topBar?.backgroundColor = UIColor.init(white: 0.5, alpha: 1)
            
            self.view.addSubview(self.topBar!)
        }
        
        if((collectionView == nil) || !(collectionView!.isDescendantOfView(self.view))) {
            let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
            layout.scrollDirection = UICollectionViewScrollDirection.Vertical;
            layout.minimumInteritemSpacing = 10;
            layout.minimumLineSpacing = 50;
            
            let collectionViewBounds = CGRect(x: self.view.bounds.origin.x, y: CGRectGetMaxY(topBar!.bounds), width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            
            self.collectionView = UICollectionView(frame: collectionViewBounds, collectionViewLayout: layout);
            
            self.collectionView!.registerClass(ItemCellView.classForCoder(), forCellWithReuseIdentifier: ItemCellView.CELL_IDENTIFIER);
            self.collectionView!.dataSource = self;
            self.collectionView!.delegate = self;
            self.collectionView!.contentInset = UIEdgeInsets(top: ITEMS_INSETS_Y + 10, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X)
            
            self.view.addSubview(self.collectionView!)
            self.view.bringSubviewToFront(self.topBar!)
            
        }
        else {
            collectionView?.reloadData()
        }
        
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            TwitchApi.getGamesWithSearchTerm("call", offset: 0, limit: 20) { (games, error) -> () in
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
                    self.layoutAndDisplayViews();
                })
            }
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
        if(indexPath.row == (self.games?.count)! - 1){
            TwitchApi.getTopGamesWithOffset(games!.count, limit: LOADING_BUFFER) {
                (games, error) in
                
                if(error != nil || games == nil){
                    NSLog("Error loading more games")
                }
                guard let games = games where games.count > 0 else {
                    return
                }
                
                var paths = [NSIndexPath]()
                
                for i in 0..<games.count {
                    paths.append(NSIndexPath(forItem: i + self.games!.count, inSection: 0))
                }
                
                self.collectionView!.performBatchUpdates({
                    self.games!.appendContentsOf(games)
                    
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
        //The number of possible rows
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

