//
//  MyTwitchViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/16/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class MyTwitchViewController: UIViewController {
    private let LOADING_BUFFER = 12
    private let NUM_COLUMNS = 3
    
    var ITEMS_INSETS_X : CGFloat {
        get {
            return 45
        }
    }
    
    var HEIGHT_RATIO: CGFloat {
        get {
            return 0.5625
        }
    }
    
    private var streams = [TwitchStream]()
    
    private var collectionView: UICollectionView!
    private var userImageView: UIImageView!
    private var userNameLabel: UILabel!
    private var bioTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 0.4, alpha: 1)
        
        self.configureViews()
        
        TwitchApi.getUser { (user, error) -> () in
            guard let user = user else {
                print("error getting user: \(error)")
                return
            }
            self.userNameLabel.text = user.name
            if let bio = user.bio {
                self.bioTextView.text = bio
            }
            TwitchApi.getUserProfileImage(forUser: user, completionHandler: { (image) -> () in
                if let image = image {
                    self.userImageView.image = image
                }
            })
        }
    }
    
    /*
    * viewWillAppear(animated: Bool)
    *
    * Overrides the super function to reload the collection view with fresh data
    *
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.streams.count == 0 {
            loadContent()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadContent() {
        
        //get the followed streams for the user
        TwitchApi.getStreamsThatUserIsFollowing(0, limit: LOADING_BUFFER) { (streams, error) -> () in
            guard let streams = streams else {
                print("error getting streams in MyTwitchViewController: \(error)")
                return
            }
            
            self.streams = streams
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.reloadData()
            })
        }
    }
    
    private func configureViews() {
        
        userImageView = UIImageView(image: UIImage(named: "twitch"))
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.clipsToBounds = true
        userImageView.contentMode = .ScaleAspectFit
        
        userNameLabel = UILabel()
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.font = UIFont.systemFontOfSize(30, weight: UIFontWeightSemibold)
        userNameLabel.textColor = UIColor.whiteColor()
        
        bioTextView = UITextView()
        bioTextView.translatesAutoresizingMaskIntoConstraints = false
        bioTextView.font = UIFont.systemFontOfSize(30, weight: UIFontWeightThin)
        bioTextView.textColor = UIColor.whiteColor()
        
        let vertStackView = UIStackView(arrangedSubviews: [userNameLabel, bioTextView])
        vertStackView.translatesAutoresizingMaskIntoConstraints = false
        vertStackView.axis = .Vertical
        vertStackView.spacing = 15.0
        
        let mainStackView = UIStackView(arrangedSubviews: [userImageView, vertStackView])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .Horizontal
        mainStackView.spacing = 25.0
        
        //then do the collection view
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 50
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerClass(ItemCellView.classForCoder(), forCellWithReuseIdentifier: ItemCellView.CELL_IDENTIFIER)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 5, left: ITEMS_INSETS_X, bottom: 5, right: ITEMS_INSETS_X)
        
        self.view.addSubview(mainStackView)
        self.view.addSubview(collectionView)
        
        let viewDict = ["stack" : mainStackView, "collection" : collectionView]
        
        self.view.addConstraint(NSLayoutConstraint(item: mainStackView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.2, constant: 1.0))
        userImageView.addConstraint(NSLayoutConstraint(item: userImageView, attribute: .Width, relatedBy: .Equal, toItem: userImageView, attribute: .Height, multiplier: 1.0, constant: 1.0))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-25-[stack]-25-[collection]|", options: [], metrics: nil, views: viewDict))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-25-[stack]-25-|", options: [], metrics: nil, views: viewDict))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collection]|", options: [], metrics: nil, views: viewDict))
        
    }
    
    func loadMore() {
        TwitchApi.getStreamsThatUserIsFollowing(self.streams.count, limit: LOADING_BUFFER) {
            (streams, error) in
            
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
        }
    }
}

////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////

extension MyTwitchViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedStream = streams[indexPath.row]
        let videoViewController = TwitchVideoViewController(stream: selectedStream)
        
        self.presentViewController(videoViewController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath == self.streams.count - 1 {
            loadMore()
        }
    }
    
}


////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////

extension MyTwitchViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.streams.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ItemCellView = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellView.CELL_IDENTIFIER, forIndexPath: indexPath) as! ItemCellView
        cell.setRepresentedItem(self.streams[indexPath.row])
        return cell
    }
    
}

//////////////////////////////////////////////////////
// MARK - UICollectionViewDelegateFlowLayout interface
//////////////////////////////////////////////////////

extension MyTwitchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let width = collectionView.bounds.width / CGFloat(NUM_COLUMNS) - CGFloat(ITEMS_INSETS_X * 2)
            let height = width * HEIGHT_RATIO + (ItemCellView.LABEL_HEIGHT * 2) //There 2 labels, top & bottom
            
            return CGSize(width: width, height: height)
    }
    
}
