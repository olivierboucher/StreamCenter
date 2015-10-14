//
//  QRCodeGenerator.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class QRCodeGenerator: NSObject {
    
    static func generateQRCode(withString qrString: String) -> UIImage? {
        let data = qrString.dataUsingEncoding(NSUTF8StringEncoding)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
    
        guard let ciImg = filter.outputImage else {
            return nil
        }
        return UIImage(CIImage: ciImg)
    }
    
}
