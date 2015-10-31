//
//  CustomVideoQRViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/14/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class QRCustomVideoViewController: QRCodeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    init() {
        let title = "Scan the QR code below to be taken to a web page where you can enter a custom url.\nOnce you have received a response code from the website, enter it below."
        super.init(title: title, url: "http://streamcenterapp.com/customurl")
        self.title = "Custom Video"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func processCode() {
        guard let code = codeField.text else {
            Logger.Error("No code")
            return
        }
        StreamCenterService.getCustomURL(fromCode: code) { (url, error) -> () in
            guard let url = url else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.titleLabel.textColor = UIColor.redColor()
                    if let error = error {
                        self.titleLabel.text = "\(error.errorDescription)\nPlease ensure that your code is correct and press 'Process' again."
                    } else {
                        self.titleLabel.text = "An unknown error occured.\nPlease ensure that your code is correct and press 'Process' again."
                    }
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(CustomVideoViewController(url: url), animated: true, completion: nil)
            })
        }
    }

}
