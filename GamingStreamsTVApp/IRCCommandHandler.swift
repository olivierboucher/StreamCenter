//
//  IRCCommandHandler.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-18.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

protocol IRCCommandHandler {
    func handleCommand(sender : String?, user : String?, host : String?, command : String?, intentOrTags : [String : String], parameters : [String])
}