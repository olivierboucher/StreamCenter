//
//  CustomViewGroupController.swift
//  StreamCenter
//
//  Created by Markus Schalk on 21.11.15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import UIKit

class CustomVideoGroupViewController : UITableViewController {
    
    private let cellIdentifier = "cell"
    private var data:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .Bottom
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        title = "Custom Video Group"
    }

    override func viewWillAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let urls = defaults.stringArrayForKey("urls") {
            data = urls
        }
        self.tableView.reloadData()
        
    }
    
    // #pragma mark - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = data[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url:String = data[indexPath.row]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(CustomVideoViewController(url: url), animated: true, completion: nil)
        })
    }
}