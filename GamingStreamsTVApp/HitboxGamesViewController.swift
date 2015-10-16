//
//  HitboxGamesViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class HitboxGamesViewController : LoadingViewController {
        
    private let LOADING_BUFFER = 20
    private let NUM_COLUMNS = 5
    override var ITEMS_INSETS_X : CGFloat {
        get {
            return 25
        }
    }
    
    private var searchField: UITextField!
    private var authButton : UIButton?
    private var games = [HitboxGame]()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        title = "Hitbox"
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
        
        //right now this is hardcoded to search for league of legends
        HitboxAPI.getGames(0, limit: LOADING_BUFFER) { (games, error) -> () in
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
        self.searchField.placeholder = "Search Games"
        self.searchField.delegate = self
        self.searchField.textAlignment = .Center
        
        if TokenHelper.getHitboxToken() == nil {
            self.authButton = UIButton(type: .System)
            self.authButton?.translatesAutoresizingMaskIntoConstraints = false
            self.authButton?.setTitle("Authenticate", forState: .Normal)
            self.authButton?.addTarget(self, action: Selector("authorizeUser"), forControlEvents: .PrimaryActionTriggered)
        }
        
        let imageView = UIImageView(image: UIImage(named: "hitbox"))
        imageView.contentMode = .ScaleAspectFit
        
        super.configureViews("Top Games", centerView: imageView, leftView: self.searchField, rightView: self.authButton)
        
    }
    
    func authorizeUser() {
        let alert = UIAlertController(title: "Authenticate", message: "To authenticate with the Hitbox API, please enter your username and password", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "username"
            textField.autocapitalizationType = .None
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "password"
            textField.secureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Authorize", style: .Default, handler: { (action) -> Void in
            guard let username = alert.textFields?[0].text, password = alert.textFields?[1].text where !username.isEmpty && !password.isEmpty else {
                return
            }
            self.performAuthorization(withUsername: username, andPassword: password)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func performAuthorization(withUsername username: String, andPassword password: String) {
        HitboxAPI.authenticate(withUserName: username, password: password) { (success, error) -> () in
            let title = success ? "Nice!" : "Uh-oh"
            var message = success ? "You authenticated with Hitbox" : "The authentication attempt was unsuccessful: "
            
            if let error = error {
                message += error.errorDescription
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: success ? "Cool" : "Ok", style: .Cancel, handler: nil))
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if success {
                    self.authButton?.removeFromSuperview()
                    self.authButton = nil
                }
                self.presentViewController(alert, animated: true, completion: nil)
            })
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


extension HitboxGamesViewController {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedGame = games[indexPath.row]
        let streamsViewController = HitboxStreamsViewController(game: selectedGame)
        
        self.presentViewController(streamsViewController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == self.games.count - 1){
            HitboxAPI.getGames(games.count, limit: LOADING_BUFFER, completionHandler: { (games, error) -> () in
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
    }
    
}

//////////////////////////////////////////////////////
// MARK - UICollectionViewDelegateFlowLayout interface
//////////////////////////////////////////////////////

extension HitboxGamesViewController : UICollectionViewDelegateFlowLayout {
    
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

extension HitboxGamesViewController {
    
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

extension HitboxGamesViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard let term = textField.text where !term.isEmpty else {
            return
        }
        
        let searchViewController = HitboxSearchResultsViewController(seatchTerm: term)
        presentViewController(searchViewController, animated: true, completion: nil)
    }
}

//////////////////////////////////////////////
// MARK - UISearchResultsUpdating interface
//////////////////////////////////////////////

//extension HitboxgamesViewController : UISearchResultsUpdating {
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        print("doesn't do anything yet")
//    }
//}
