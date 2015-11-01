//
//  QRCodeGenerator.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

struct QRCodeGenerator {
    
    static func generateQRCode(withString qrString: String, clearBackground clearBg: Bool = false) -> UIImage? {
        let data = qrString.dataUsingEncoding(NSUTF8StringEncoding)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
    
        guard let ciImg = filter.outputImage else {
            return nil
        }
        
        if !clearBg {
            return UIImage(CIImage: ciImg)
        }
        
        guard let bgFilter = CIFilter(name: "CIFalseColor") else {
            return nil
        }
        
        bgFilter.setValue(ciImg, forKey: "inputImage")
        bgFilter.setValue(CIColor(red: 0, green: 0, blue: 0, alpha: 1), forKey: "inputColor0")
        bgFilter.setValue(CIColor(red: 1, green: 1, blue: 1, alpha: 0), forKey: "inputColor1")
        
        guard let clearImage = bgFilter.outputImage else {
            return nil
        }
        
        return UIImage(CIImage: clearImage)
    }
    
}
