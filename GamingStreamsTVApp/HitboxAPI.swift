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
    
    enum HitboxError: ErrorType {
        case URLError
        case JSONError
        case AuthError
        case NoAuthTokenError
        case OtherError
        
        var errorDescription: String {
            get {
                switch self {
                case .URLError:
                    return "There was an error with the request."
                case .JSONError:
                    return "There was an error parsing the JSON."
                case .AuthError:
                    return "The user is not authenticated."
                case .NoAuthTokenError:
                    return "There was no auth token provided in the response data."
                case .OtherError:
                    return "An unidentified error occured."
                }
            }
        }
        
        var recoverySuggestion: String {
            get {
                switch self {
                case .URLError:
                    return "Please make sure that the url is formatted correctly."
                case .JSONError:
                    return "Please check the request information and response."
                case .AuthError:
                    return "Please make sure to authenticate with Twitch before attempting to load this data."
                case .NoAuthTokenError:
                    return "Please check the server logs and response."
                case .OtherError:
                    return "Sorry, there's no provided solution for this error."
                }
            }
        }
    }
    
    static func getGames(offset: Int, limit: Int, completionHandler: (games: [HitboxGame]?, error: HitboxError?) -> ()) {
        let urlString = "https://api.hitbox.tv/games"
        
        Alamofire.request(.GET, urlString, parameters:
            [   "limit"         : limit,
                "liveonly"      : true,
                "q"             : "league of legends"   ])
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
                    completionHandler(games: nil, error: .JSONError)
                    return
                }
                else {
                    completionHandler(games: nil, error: .URLError)
                    return
                }
        }
    }
    
    static func getLiveStreams(forGame gameid: Int, offset: Int, limit: Int, completionHandler: (streams: [HitboxMedia]?, error: HitboxError?) -> ()) {
        let urlString = "https://api.hitbox.tv/media/live/list"
        
        Alamofire.request(.GET, urlString, parameters:
            [   "game"          : gameid,
                "limit"         : limit,
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
                completionHandler(streams: nil, error: .JSONError)
                return
            }
            else {
                completionHandler(streams: nil, error: .URLError)
                return
            }
        }
    }
    
    static func getLiveStreams(offset: Int, limit: Int, completionHandler: (streams: [HitboxMedia]?, error: HitboxError?) -> ()) {
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
                completionHandler(streams: nil, error: .JSONError)
                return
            }
            else {
                completionHandler(streams: nil, error: .URLError)
                return
            }
        }
    }

}
