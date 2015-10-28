//
//  TwitchChatConsumer.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-18.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

protocol ChatManagerConsumer {
    func messageReadyForDisplay(message: NSAttributedString)
}