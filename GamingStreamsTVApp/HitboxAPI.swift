//
//  HitboxAPI.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/12/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import Alamofire

class HitboxAPI {
    
    static func getGames(offset: Int, limit: Int, completionHandler: (games: [HitboxGame]?, error: NSError?) -> ()) {
        let urlString = "https://api.hitbox.tv/games"
        
        Alamofire.request(.GET, urlString, parameters:
            [   "limit"         : limit,
                "liveonly"    : true      ])
            .responseJSON { (response) -> Void in
                //do the stuff
                if(response.result.isSuccess) {
                    if let baseDict = response.result.value as? [String : AnyObject] {
                        if let gamesDict = baseDict["categories"] as? [[String : AnyObject]] {
                            var games = [HitboxGame]()
                            for gameRaw in gamesDict {
                                if let game = HitboxGame(dict: gameRaw) {
                                    games.append(game)
                                }
                            }
                            completionHandler(games: games, error: nil)
                            return
                        }
                    }
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided url is valid")
                    ]
                    completionHandler(games: nil, error: NSError(domain: "HitboxAPI", code: 3, userInfo: userInfo))
                    return
                }
                else {
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", response.result.error.debugDescription),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                    ]
                    completionHandler(games: nil, error: NSError(domain: "HitboxAPI", code: 1, userInfo: userInfo))
                    return
                }
        }
    }
    
    static func getLiveStreams(offset: Int, limit: Int, completionHandler: (streams: [HitboxMedia]?, error: NSError?) -> ()) {
        let urlString = "https://api.hitbox.tv/media/live/list"
        
        Alamofire.request(.GET, urlString, parameters:
            [   "limit"         : limit,
                "start"         : offset,
                "publicOnly"    : true      ])
        .responseJSON { (response) -> Void in
            //do the stuff
            if(response.result.isSuccess) {
                if let baseDict = response.result.value as? [String : AnyObject] {
                    if let streamsDicts = baseDict["livestream"] as? [[String : AnyObject]] {
                        var streams = [HitboxMedia]()
                        for streamRaw in streamsDicts {
                            if let stream = HitboxMedia(dict: streamRaw) {
                                streams.append(stream)
                            }
                        }
                        completionHandler(streams: streams, error: nil)
                        return
                    }
                }
                let userInfo = [
                    NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                    NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                    NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided url is valid")
                ]
                completionHandler(streams: nil, error: NSError(domain: "HitboxAPI", code: 3, userInfo: userInfo))
                return
            }
            else {
                let userInfo = [
                    NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                    NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", response.result.error.debugDescription),
                    NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                ]
                completionHandler(streams: nil, error: NSError(domain: "HitboxAPI", code: 1, userInfo: userInfo))
                return
            }
        }
    }

}
