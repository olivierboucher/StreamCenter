//
//  TwitchStreamsViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.

import UIKit
import Foundation

class TwitchStreamsViewController: LoadingViewController {
    private let LOADING_BUFFER = 12
    
    override var NUM_COLUMNS: Int {
        get {
            return 3
        }
    }
    
    override var ITEMS_INSETS_X : CGFloat {
        get {
            return 45
        }
    }
    
    override var HEIGHT_RATIO: CGFloat {
        get {
            return 0.5625
        }
    }
    
    private var game : TwitchGame!
    private var streams = [TwitchStream]()
    
    convenience init(game : TwitchGame){
        self.init(nibName: nil, bundle: nil)
        self.game = game
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
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
        self.removeErrorView()
        self.displayLoadingView("Loading Streams...")
        TwitchApi.getTopStreamsForGameWithOffset(self.game!.name, offset: 0, limit: 20) {
            (streams, error) in
            
            guard let streams = streams else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeLoadingView()
                    self.displayErrorView("Error loading streams list.\nPlease check your internet connection.")
                })
                return
            }
            
            self.streams = streams
            dispatch_async(dispatch_get_main_queue(), {
                self.removeLoadingView()
                self.collectionView.reloadData()
            })
        }
    }
    
    private func configureViews() {
        super.configureViews("Live Streams - \(self.game!.name)", centerView: nil, leftView: nil, rightView: nil)
    }
    
    override func reloadContent() {
        loadContent()
        super.reloadContent()
    }
    
    override func loadMore() {
        TwitchApi.getTopStreamsForGameWithOffset(self.game!.name, offset: self.streams.count, limit: LOADING_BUFFER) {
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
    
    override var itemCount: Int {
        get {
            return streams.count
        }
    }
    
    override func getItemAtIndex(index: Int) -> CellItem {
        return streams[index]
    }
}

////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////

extension TwitchStreamsViewController {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedStream = streams[indexPath.row]
        let videoViewController = TwitchVideoViewController(stream: selectedStream)
        
        self.presentViewController(videoViewController, animated: true, completion: nil)
    }
    
}
