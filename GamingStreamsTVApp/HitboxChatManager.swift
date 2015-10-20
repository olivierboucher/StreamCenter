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
    private let consumer : ChatManagerConsumer
    private let opQueue : dispatch_queue_t
    private var messageQueue : HitboxChatMessageQueue?
    private var credentials : HitboxChatCredentials?
    private var currentChannel : String?
    
    init(consumer : ChatManagerConsumer) {
        status = .Disconnected
        self.consumer = consumer
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
        opQueue = dispatch_queue_create("com.hitbox.chatmgr", queueAttr)
        
        messageQueue = HitboxChatMessageQueue(delegate: self)
        
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
                self.chatConnection!.queue = self.opQueue
            }
        }
    }
    
    func connectAnonymously(channel : String) {
        if let socket = chatConnection as WebSocket! {
            credentials = HitboxChatCredentials.anonymous()
            currentChannel = channel.lowercaseString
            socket.connect()
        }
    }
}

extension HitboxChatManager : WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        status = .Connected
        guard let joinMsg = credentials!.getJoinMessage(currentChannel!) else {
            print("Impossible to generate join message from credentials")
            return
        }
        socket.writeString(joinMsg)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        status = .Disconnected
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        if text.hasPrefix("5:::") { //Hitbox payloads that are messages start by "5:::"
            messageQueue?.addNewMessage(text)
        }
        else if text.hasPrefix("2::") { //This is the way hitbox sends a ping request
            socket.writeString("2::")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("We recieved data from websocket, that's weird..")
        print(String(data: data, encoding: NSUTF8StringEncoding))
    }
}

extension HitboxChatManager : HitboxChatMessageQueueDelegate {
    func handleProcessedAttributedString(message: NSAttributedString) {
        consumer.messageReadyForDisplay(message)
    }
}