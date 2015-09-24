//
//  ViewController.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class GamesViewController : UIViewController {
    
    private let NUM_COLUMNS = 5;
    private let ITEMS_INSETS_X : CGFloat = 25;
    private let ITEMS_INSETS_Y : CGFloat = 40;
    private let TOP_BAR_HEIGHT : CGFloat = 100;
    
    private var _topBar : TopBarView?
    private var _collectionView : UICollectionView?
    private var _loadingView : LoadingView?
    private var _errorView : ErrorView?
    private var _games : NSArray?
    
    private var _testChat : TwitchChatHandler?
    
    
    convenience init(){
        self.init(nibName: nil, bundle: nil);
    }
    
    //We want the latest data to be fetched each time
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(self._collectionView == nil){
            self._loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width/5, height: self.view.bounds.height/5))
            self._loadingView?.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
            self.view.addSubview(_loadingView!)
        }
//        //TESTS
//
//        self._testChat = TwitchChatHandler()
//        
//        self._testChat?.anonymousConnect()
//        self._testChat?.startLoop()
//        self._testChat?.send("JOIN", destination: "#lirik", message: nil)
//
//        // TESTS END
        
        TwitchApi.getTopGamesWithOffset(0, limit: 17) {
            (games, error) in
            
            if(error != nil || games == nil){
                dispatch_async(dispatch_get_main_queue(),{
                    if(self._errorView == nil){
                        if((self._loadingView != nil) && (self._loadingView!.isDescendantOfView(self.view))){
                            self._loadingView?.removeFromSuperview()
                            self._loadingView = nil
                        }
                        let errorViewFrame = CGRect(x: 0, y: 0, width: 400, height: 400)
                        self._errorView = ErrorView(frame: errorViewFrame, andTitle: "Error loading game list.\nPlease check your internet connection.")
                        self._errorView?.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
                        self.view.addSubview(self._errorView!)
                    }
                });
            }
            else {
                self._games = games!;
                dispatch_async(dispatch_get_main_queue(),{
                    if((self._topBar == nil) || !(self._topBar!.isDescendantOfView(self.view))) {
                        let topBarBounds = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.TOP_BAR_HEIGHT)
                        self._topBar = TopBarView(frame: topBarBounds, withMainTitle: "Top Games")
                        self._topBar?.backgroundColor = UIColor.init(white: 0.5, alpha: 1)
                        
                        self.view.addSubview(self._topBar!)
                    }
                    if((self._loadingView != nil) && (self._loadingView!.isDescendantOfView(self.view))){
                        self._loadingView?.removeFromSuperview()
                        self._loadingView = nil
                    }
                    if((self._errorView != nil) && (self._errorView!.isDescendantOfView(self.view))){
                        self._errorView?.removeFromSuperview()
                        self._errorView = nil
                    }
                    self.displayCollectionView();
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func displayCollectionView() {
        
        if((_collectionView == nil) || !(_collectionView!.isDescendantOfView(self.view))) {
            let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
            layout.scrollDirection = UICollectionViewScrollDirection.Vertical;
            layout.minimumInteritemSpacing = 10;
            layout.minimumLineSpacing = 10;
            
            let collectionViewBounds = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            
            self._collectionView = UICollectionView(frame: collectionViewBounds, collectionViewLayout: layout);
            
            self._collectionView!.registerClass(GameCellView.classForCoder(), forCellWithReuseIdentifier: GameCellView.cellIdentifier);
            self._collectionView!.dataSource = self;
            self._collectionView!.delegate = self;
            //self._collectionView?.backgroundColor = UIColor.blueColor();
            self._collectionView!.contentInset = UIEdgeInsets(top: ITEMS_INSETS_Y + 10, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X)
            
            self.view.addSubview(self._collectionView!)
            self.view.bringSubviewToFront(self._topBar!)
        }
        else {
            _collectionView?.reloadData()
        }
    }
    
    //    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    //        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
    //
    //        let view1 = context.previouslyFocusedView as? GameCellView
    //        let view2 = context.nextFocusedView as? GameCellView
    //
    //        if(view1 != nil) {
    //            NSLog("Prev : %@", (view1!.getGame()?.getName())!)
    //        }
    //        if(view2 != nil) {
    //            NSLog("Next : %@", (view2!.getGame()?.getName())!)
    //        }
    //    }
    
}

extension GamesViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedGame = _games!.objectAtIndex((indexPath.section * NUM_COLUMNS) +  indexPath.row) as! TwitchGame
        let streamsViewController = StreamsViewController(game: selectedGame)
        
        self.presentViewController(streamsViewController, animated: true, completion: nil)
    }
}

extension GamesViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = self.view.bounds.width / CGFloat(NUM_COLUMNS) - CGFloat(ITEMS_INSETS_X * 2);
            let height = (width * 1.39705882353) + 80;
            
            return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            let topInset = (section == 0) ? TOP_BAR_HEIGHT : ITEMS_INSETS_X
            return UIEdgeInsets(top: topInset, left: ITEMS_INSETS_X, bottom: ITEMS_INSETS_Y, right: ITEMS_INSETS_X);
    }
}

extension GamesViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        let test = Double(_games!.count) / Double(NUM_COLUMNS);
        let test2 = ceil(test);
        
        return Int(test2);
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if((section+1) * NUM_COLUMNS <= _games!.count){
            //NSLog("count for section #%d : %d", section, NUM_COLUMNS);
            return NUM_COLUMNS;
        }
        else {
            //NSLog("count for section #%d : %d", section, _games!.count - ((section) * NUM_COLUMNS));
            return _games!.count - ((section) * NUM_COLUMNS)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : GameCellView = collectionView.dequeueReusableCellWithReuseIdentifier(GameCellView.cellIdentifier, forIndexPath: indexPath) as! GameCellView;
        //NSLog("Indexpath => section:%d row:%d", indexPath.section, indexPath.row);
        cell.setGame(_games!.objectAtIndex((indexPath.section * NUM_COLUMNS) +  indexPath.row) as! TwitchGame);
        return cell;
    }
}

