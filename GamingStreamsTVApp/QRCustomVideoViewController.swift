//
//  CustomVideoQRViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/14/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class QRCustomVideoViewController: QRCodeViewController {
    
    override var UUID: String {
        get {
            return ""
        }
    }
    
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
        super.init(title: title, baseURL: "http://streamcenterapp.com/customurl/")
        self.delegate = self
        self.title = "Custom Video"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func processCode() {
        guard let code = codeField.text else {
            print("no code")
            return
        }
        
        TwitchApi.authenticate(withCode: code, andUUID: UUID) { (token, error) -> () in
            print(token)
            guard let token = token else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.titleLabel.text = "\(error)\nPlease ensure that your code is correct and press Authenticate again."
                })
                return
            }
            TokenHelper.storeTwitchToken(token)
            self.delegate?.qrCodeViewControllerFinished(true, data: nil)
        }
    }

}

extension QRCustomVideoViewController: QRCodeDelegate {
    
    func qrCodeViewControllerFinished(success: Bool, data: [String : AnyObject]?) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if let data = data where success == true {
                if let urlString = data["stream_url"] as? String {
                    self.presentViewController(CustomVideoViewController(url: urlString), animated: true, completion: nil)
                    return
                }
            }
            self.titleLabel.text = "Error"
        }
    }
    
}
