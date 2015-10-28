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
                    completionHandler(serverURLS: urls, error: nil)
                    return
                }
                completionHandler(serverURLS: nil, error: .JSONError)
            } else {
                completionHandler(serverURLS: nil, error: .URLError)
            }
        }
    }
    
    static func compileWebSocket(serverURL: String, completionHandler: (result: String?, error: ServiceError?) -> ()) {
        Alamofire.request(.GET, "http://\(serverURL)/socket.io/1/").responseString { response in
            if response.result.isSuccess {
                if let responseSocket = response.result.value {
                    if let colonRange = responseSocket.rangeOfString(":") {
                        let connectionID = responseSocket.substringToIndex(colonRange.startIndex)
                        let compiledString = "ws://\(serverURL)/socket.io/1/websocket/\(connectionID)"
                        completionHandler(result: compiledString, error: nil)
                        return
                    }
                }
            }
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
                completionHandler(result: nil, error: .OtherError("Invalid url array"))
                return
            }
            
            HitboxChatAPI.compileWebSocket(serverURLs[0]){ socketURL, error in
                guard error == nil else {
                    completionHandler(result: nil, error: error!)
                    return
                }
                
                guard let socketURL = socketURL else {
                    completionHandler(result: nil, error: .OtherError("Invalid socket URL"))
                    return
                }
                
                completionHandler(result: socketURL, error: nil)
            }
        }
    }

}
