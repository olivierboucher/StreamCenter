//
//  NSDateFormatter.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-28.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    convenience init(format : String) {
        self.init()
        self.dateFormat = format
    }
}