//
//  ViewController.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import UIKit

class TwitchGamesViewController : LoadingViewController {

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
            return 1.39705882353
        }
    }
    
    private var searchField: UITextField!
    private var games = [TwitchGame]()
    private var twitchButton: UIButton?
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
        title = "Twitch"
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
            self.twitchButton = UIButton(type: .System)
            self.twitchButton?.translatesAutoresizingMaskIntoConstraints = false
            self.twitchButton?.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.twitchButton?.setTitle("Authenticate", forState: .Normal)
            self.twitchButton?.addTarget(self, action: Selector("authorizeUser"), forControlEvents: .PrimaryActionTriggered)
        }
        
        let imageView = UIImageView(image: UIImage(named: "twitch"))
        imageView.contentMode = .ScaleAspectFit
        
        super.configureViews("Top Games", centerView: imageView, leftView: self.searchField, rightView: nil)
        
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
    
    override func loadMore() {
        TwitchApi.getTopGamesWithOffset(games.count, limit: LOADING_BUFFER) {
            (games, error) in
            
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


extension TwitchGamesViewController {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedGame = games[indexPath.row]
        let streamsViewController = TwitchStreamsViewController(game: selectedGame)
        
        self.presentViewController(streamsViewController, animated: true, completion: nil)
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
        
        let searchViewController = TwitchSearchResultsViewController(searchTerm: term)
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
                self.twitchButton?.removeFromSuperview()
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}