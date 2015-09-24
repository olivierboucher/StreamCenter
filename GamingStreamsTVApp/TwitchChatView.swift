//
//  TwitchChatView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-23.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import UIKit
import Foundation

protocol TwitchChatViewDataSource {
    func getEmotesCache() -> Dictionary<String, NSData>
}

class TwitchChatView : UIView {
    var datasource : TwitchChatViewDataSource?
}