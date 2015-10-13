//
//  QRCodeViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {
    
    convenience init(stringData : String){
        self.init(nibName: nil, bundle: nil)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFontOfSize(45, weight: UIFontWeightSemibold)
        title.text = "Scan the qr code below or go to the link provided"
        
        let image = QRCodeGenerator.generateQRCode(withString: stringData)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(40, weight: UIFontWeightSemibold)
        label.text = stringData
        
        let dismissButton = UIButton(type: .System)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: Selector("dismiss"), forControlEvents: .PrimaryActionTriggered)
        dismissButton.setTitle("Dismiss", forState: .Normal)
        
        self.view.addSubview(title)
        self.view.addSubview(imageView)
        self.view.addSubview(label)
        self.view.addSubview(dismissButton)
        
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.3, constant: 1.0))
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: -90.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: title, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1.0, constant: -30.0))
        self.view.addConstraint(NSLayoutConstraint(item: title, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .Top, relatedBy: .Equal, toItem: label, attribute: .Bottom, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
