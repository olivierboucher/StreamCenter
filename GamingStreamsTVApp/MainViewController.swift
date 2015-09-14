//
//  ViewController.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private let NUM_COLUMNS = 5;
    private var _collectionView : UICollectionView?;
    private var _games : NSArray?;
    
    convenience init(){
        self.init(nibName: nil, bundle: nil);
        TwitchApi.getTopGamesWithOffset(0, limit: 10) {
            (games, error) in
            
            if(error != nil){
                NSLog("Error loading top games");
            }
            
            if(games != nil){
                self._games = games!;
                dispatch_async(dispatch_get_main_queue(),{
                    self.displayCollectionView();
                })
            }
        }
        
        self.view.backgroundColor = UIColor.greenColor();
        //self.displayCollectionView();
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
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical;
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        
        self._collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout);
        NSLog("Bounds=> x:%f y:%f w:%f h:%f", self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.height);
        
        self._collectionView!.registerClass(GameCellView.classForCoder(), forCellWithReuseIdentifier: GameCellView.cellIdentifier);
        self._collectionView!.dataSource = self;
        self._collectionView!.delegate = self;
        self._collectionView?.backgroundColor = UIColor.blueColor();
        
        self.view.addSubview(self._collectionView!);
    }

}

extension MainViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = self.view.bounds.width / CGFloat(NUM_COLUMNS) - 20;
            let height = width * 1.397;
            
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10);
    }
}

extension MainViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        let test = Double(_games!.count) / Double(NUM_COLUMNS);
        let test2 = ceil(test);
        
        return Int(test2);
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if((section+1) * NUM_COLUMNS <= _games!.count){
            NSLog("count for section #%d : %d", section, NUM_COLUMNS);
            return NUM_COLUMNS;
        }
        else {
            NSLog("count for section #%d : %d", section, _games!.count - ((section) * NUM_COLUMNS));
            return _games!.count - ((section) * NUM_COLUMNS)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : GameCellView = collectionView.dequeueReusableCellWithReuseIdentifier(GameCellView.cellIdentifier, forIndexPath: indexPath) as! GameCellView;
        NSLog("Indexpath => section:%d row:%d", indexPath.section, indexPath.row);
        cell.setGame(_games!.objectAtIndex((indexPath.section * NUM_COLUMNS) +  indexPath.row) as! TwitchGame);
        return cell;
    }
}

