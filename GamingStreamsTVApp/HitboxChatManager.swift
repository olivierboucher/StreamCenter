//
//  HitboxChatManager.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class HitboxChatManager {
    
    enum ConnectionStatus {
        case Connected
        case Connecting
        case Disconnected
    }
    
    private var chatConnection : WebSocket?
    private var status : ConnectionStatus
    
    init() {
        status = .Disconnected
        HitboxChatAPI.getFirstAvailableWebSocket(){ socketURL, error in
            guard error != nil else {
                print(error!.developerSuggestion)
                return
            }
            
            guard let socketURL = socketURL as String! else {
                print("Socket url is nil")
                return
            }
            
            if let URI = NSURL(string: socketURL) {
                self.status = .Connecting
                self.chatConnection = WebSocket(url: URI)
                self.chatConnection!.delegate = self
            }
        }
    }
    
    func connectAnonymously() {
        if status == .Connected {
            
        }
    }
}

extension HitboxChatManager : WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        status = .Connected
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        status = .Disconnected
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        
    }
}