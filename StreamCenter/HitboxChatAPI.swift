//
//  HitboxChatAPI.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/17/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import Alamofire

class HitboxChatAPI {
    
    static func getChatServers(completionHandler: (serverURLS: [String]?, error: ServiceError?) -> ()) {
        let urlString = "https://www.hitbox.tv/api/chat/servers"
        Alamofire.request(.GET, urlString).responseJSON { response in
            if response.result.isSuccess {
                if let baseArray = response.result.value as? [[String : String]] {
                    var urls = [String]()
                    for dict in baseArray {
                        if let url = dict["server_ip"] {
                            urls.append(url)
                        }
                    }
                    Logger.Debug("Returned \(urls.count) results")
                    completionHandler(serverURLS: urls, error: nil)
                    return
                }
                Logger.Error("Could not parse server list as JSON")
                completionHandler(serverURLS: nil, error: .JSONError)
            }
            Logger.Error("Could not request chat server list")
            completionHandler(serverURLS: nil, error: .URLError)
            
        }
    }
    
    static func compileWebSocket(serverURL: String, completionHandler: (result: String?, error: ServiceError?) -> ()) {
        Alamofire.request(.GET, "http://\(serverURL)/socket.io/1/").responseString { response in
            if response.result.isSuccess {
                if let responseSocket = response.result.value {
                    if let colonRange = responseSocket.rangeOfString(":") {
                        let connectionID = responseSocket.substringToIndex(colonRange.startIndex)
                        let compiledString = "ws://\(serverURL)/socket.io/1/websocket/\(connectionID)"
                        Logger.Debug("Compiled websocket url: \(compiledString)")
                        completionHandler(result: compiledString, error: nil)
                        return
                    }
                }
            }
            Logger.Error("Could not request a websocket URL")
            completionHandler(result: nil, error: .URLError)
        }
    }
    
    static func getFirstAvailableWebSocket(completionHandler : (result: String?, error: ServiceError?) -> ()) {
        HitboxChatAPI.getChatServers(){ serverURLs, error in
            guard error == nil else {
                completionHandler(result: nil, error: error!)
                return
            }
            
            guard let serverURLs = serverURLs where serverURLs.count > 0 else {
                Logger.Error("Invalid server list")
                completionHandler(result: nil, error: .OtherError("Invalid url array"))
                return
            }
            
            HitboxChatAPI.compileWebSocket(serverURLs[0]){ socketURL, error in
                guard error == nil else {
                    completionHandler(result: nil, error: error!)
                    return
                }
                
                guard let socketURL = socketURL else {
                    Logger.Error("Invalid socket URL");
                    completionHandler(result: nil, error: .OtherError("Invalid socket URL"))
                    return
                }
                Logger.Debug("Returning websocket url: \(socketURL)")
                completionHandler(result: socketURL, error: nil)
            }
        }
    }

}
