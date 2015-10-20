//
//  QRCodeViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

protocol QRCodeDelegate {
    func qrCodeViewControllerFinished(success: Bool, data: [String : AnyObject]?)
}

class QRCodeViewController: UIViewController {
    
    let codeField = UITextField()
    let titleLabel = UILabel()
    
    var delegate: QRCodeDelegate?
    
    init(title: String, url: String) {
        super.init(nibName: nil, bundle: nil)
        
        let authenticationUrlString = url
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = UIFont.systemFontOfSize(45, weight: UIFontWeightSemibold)
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.text = title
        
        let image = QRCodeGenerator.generateQRCode(withString: authenticationUrlString, clearBackground: true)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(40, weight: UIFontWeightSemibold)
        label.textAlignment = NSTextAlignment.Center
        label.text = authenticationUrlString
        
        self.codeField.translatesAutoresizingMaskIntoConstraints = false
        self.codeField.placeholder = "Enter your code here"
        
        let authButton = UIButton(type: .System)
        authButton.translatesAutoresizingMaskIntoConstraints = false
        authButton.addTarget(self, action: Selector("processCode"), forControlEvents: .PrimaryActionTriggered)
        authButton.setTitle("Process", forState: .Normal)
        
        let dismissButton = UIButton(type: .System)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: Selector("dismiss"), forControlEvents: .PrimaryActionTriggered)
        dismissButton.setTitle("Dismiss", forState: .Normal)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(label)
        self.view.addSubview(codeField)
        self.view.addSubview(authButton)
        self.view.addSubview(dismissButton)
        
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.3, constant: 1.0))
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: -90.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1.0, constant: -30.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.codeField, attribute: .Top, relatedBy: .Equal, toItem: label, attribute: .Bottom, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.codeField, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: authButton, attribute: .Top, relatedBy: .Equal, toItem: self.codeField, attribute: .Bottom, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint(item: authButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .Top, relatedBy: .Equal, toItem: authButton, attribute: .Bottom, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func processCode() {
        //do nothing
        return
    }
}
