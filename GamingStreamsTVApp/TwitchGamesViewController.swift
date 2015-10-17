//
//  ViewController.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import UIKit

class TwitchGamesViewController : LoadingViewController {

    private let LOADING_BUFFER = 20
    private let NUM_COLUMNS = 5
    override var ITEMS_INSETS_X : CGFloat {
        get {
            return 25
        }
    }
    
    private var searchField: UITextField!
    private var games = [TwitchGame]()
    private var authButton: UIButton?
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
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
        
        if TokenHelper.getTwitchToken() == nil {
            self.authButton = UIButton(type: .System)
            self.authButton?.translatesAutoresizingMaskIntoConstraints = false
            self.authButton?.setTitle("Authenticate", forState: .Normal)
            self.authButton?.addTarget(self, action: Selector("authorizeUser"), forControlEvents: .PrimaryActionTriggered)
        }
        
        let imageView = UIImageView(image: UIImage(named: "twitch"))
        imageView.contentMode = .ScaleAspectFit
        
        super.configureViews("Top Games", centerView: imageView, leftView: self.searchField, rightView: self.authButton)
        
    }
    
    func authorizeUser() {
        let qrController = TwitchAuthViewController()
        qrController.delegate = self
        presentViewController(qrController, animated: true, completion: nil)
    }
    
    override func reloadContent() {
        loadContent()
        super.reloadContent()
    }
}

////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////


extension TwitchGamesViewController {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedGame = games[indexPath.row]
        let streamsViewController = TwitchStreamsViewController(game: selectedGame)
        
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
                
                self.collectionView.performBatchUpdates({
                    self.games.appendContentsOf(filteredGames)
                    
                    self.collectionView.insertItemsAtIndexPaths(paths)
                    
                    }, completion: nil)
            }
        }
    }
}

//////////////////////////////////////////////////////
// MARK - UICollectionViewDelegateFlowLayout interface
//////////////////////////////////////////////////////

extension TwitchGamesViewController : UICollectionViewDelegateFlowLayout {
    
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
            return UIEdgeInsets(top: TOP_BAR_HEIGHT + ITEMS_INSETS_Y, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X)
    }
}

//////////////////////////////////////////////
// MARK - UICollectionViewDataSource interface
//////////////////////////////////////////////

extension TwitchGamesViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //The number of sections
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If the count of games allows the current row to be full
        return games.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ItemCellView = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellView.CELL_IDENTIFIER, forIndexPath: indexPath) as! ItemCellView
        cell.setRepresentedItem(games[indexPath.row])
        return cell
    }
}

//////////////////////////////////////////////
// MARK - UITextFieldDelegate interface
//////////////////////////////////////////////

extension TwitchGamesViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard let term = textField.text where !term.isEmpty else {
            return
        }
        
        let searchViewController = TwitchSearchResultsViewController(seatchTerm: term)
        presentViewController(searchViewController, animated: true, completion: nil)
    }
}

//////////////////////////////////////////////
// MARK - QRCodeDelegate interface
//////////////////////////////////////////////

extension TwitchGamesViewController: QRCodeDelegate {
    
    func qrCodeViewControllerFinished(success: Bool, data: [String : AnyObject]?) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if success {
                self.authButton?.removeFromSuperview()
                self.authButton = nil
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
