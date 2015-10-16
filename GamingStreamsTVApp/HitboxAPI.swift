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
    
    static func getGames(offset: Int, limit: Int, searchTerm: String? = nil, completionHandler: (games: [HitboxGame]?, error: HitboxError?) -> ()) {
        let urlString = "https://api.hitbox.tv/games"
        
        var parameters: [String : AnyObject] = ["limit" : limit, "liveonly" : "true"]
        
        if let term = searchTerm {
            parameters["q"] = term
        }
        
        Alamofire.request(.GET, urlString, parameters: parameters)
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
    
    //https://api.hitbox.tv/mediainfo/live/458643
    static func getStreamInfo(forMediaId mediaId: String, completionHandler: (streamVideos: [HitboxStreamVideo]?, error: HitboxError?) -> ()) {
        let urlString = "http://www.hitbox.tv/api/player/config/live/\(mediaId)"
        print("getting stream info for: \(urlString)")
        Alamofire.request(.GET, urlString)
            .responseJSON { (response) -> Void in
                //do the stuff
                if(response.result.isSuccess) {
                    if let baseDict = response.result.value as? [String : AnyObject] {
                        if let playlist = baseDict["playlist"] as? [[String : AnyObject]], bitrates = playlist.first?["bitrates"] as? [[String : AnyObject]] {
                            var streamVideos = [HitboxStreamVideo]()
                            for bitrate in bitrates {
                                if let video = HitboxStreamVideo(dict: bitrate) {
                                    streamVideos.append(video)
                                }
                            }
                            
//                            //this is no longer necessary, it was to try and get a rtmp stream but AVPlayer doesn't support that
//                            if streamVideos.count == 0 {
//                                //rtmp://edge.live.hitbox.tv/live/youplay
//                                streamVideos += HitboxStreamVideo.alternativeCreation(playlist.first)
//                            }
                            completionHandler(streamVideos: streamVideos, error: nil)
                            return
                        }
                    }
                    completionHandler(streamVideos: nil, error: .JSONError)
                    return
                }
                else {
                    completionHandler(streamVideos: nil, error: .URLError)
                    return
                }
        }
    }
    
    
    static func authenticate(withUserName username: String, password: String, completionHandler: (success: Bool, error: HitboxError?) -> ()) {
        
        let urlString = "https://www.hitbox.tv/api/auth/login"
        Alamofire.request(.POST, urlString, parameters:
            [   "login"         : username,
                "pass"          : password,
                "rememberme"    : ""        ])
        .responseJSON { (response) -> Void in
            if response.result.isSuccess {
                if let baseDict = response.result.value as? [String : AnyObject] {
                    if let dataDict = baseDict["data"] as? [String : AnyObject], token = dataDict["authToken"] as? String {
                        TokenHelper.storeHitboxToken(token)
                        completionHandler(success: true, error: nil)
                        return
                    }
                }
                completionHandler(success: false, error: .NoAuthTokenError)
            } else {
                completionHandler(success: false, error: .URLError)
            }
        }
    }

}