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
    
    
    
    ///This is a method to retrieve the most popular Hitbox games and we filter it to only games that have streams with content that is live at the moment
    ///
    /// - parameters:
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of games to return
    ///     - searchTerm: An optional search term
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    static func getGames(offset: Int, limit: Int, searchTerm: String? = nil, completionHandler: (games: [HitboxGame]?, error: HitboxError?) -> ()) {
        let urlString = "https://api.hitbox.tv/games"
        
        var parameters: [String : AnyObject] = ["limit" : limit, "liveonly" : "true", "offset" : offset]
        
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
                            Logger.Debug("Returned \(games.count) results")
                            completionHandler(games: games, error: nil)
                            return
                        }
                    }
                    Logger.Error("Could not parse the response as JSON")
                    completionHandler(games: nil, error: .JSONError)
                    return
                }
                else {
                    Logger.Error("Could not request top games")
                    completionHandler(games: nil, error: .URLError)
                    return
                }
        }
    }
    
    ///This is a method to retrieve the Hitbox streams for a specific game
    ///
    /// - parameters:
    ///     - forGame: An integer gameID for given HitboxGame. This is called the category_id in the Hitbox API
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of games to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
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
                        Logger.Debug("Returned \(streams.count) results")
                        completionHandler(streams: streams, error: nil)
                        return
                    }
                }
                Logger.Error("Could not parse the response as JSON")
                completionHandler(streams: nil, error: .JSONError)
                return
            }
            else {
                Logger.Error("Could not request top streams")
                completionHandler(streams: nil, error: .URLError)
                return
            }
        }
    }
    
    ///This is a method to retrieve the stream links and information for a given Hitbox Stream
    ///
    /// - parameters:
    ///     - forMediaID: A media ID for a given stream. In the Hitbox API they call it the user_media_id
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    static func getStreamInfo(forMediaId mediaId: String, completionHandler: (streamVideos: [HitboxStreamVideo]?, error: HitboxError?) -> ()) {
        let urlString = "http://www.hitbox.tv/api/player/config/live/\(mediaId)"
        Logger.Debug("getting stream info for: \(urlString)")
        Alamofire.request(.GET, urlString)
            .responseJSON { (response) -> Void in

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
                            Logger.Debug("Returned \(streamVideos.count) results")
                            completionHandler(streamVideos: streamVideos, error: nil)
                            return
                        }
                    }
                    Logger.Error("Could not parse the response as JSON")
                    completionHandler(streamVideos: nil, error: .JSONError)
                    return
                }
                else {
                    Logger.Error("Could not request stream info")
                    completionHandler(streamVideos: nil, error: .URLError)
                    return
                }
        }
    }
    
    ///This is a method to authenticate with the HitboxAPI. It takes a username and password and if it's successful it will store the token in the User's Keychain
    ///
    /// - parameters:
    ///     - username: A username
    ///     - password: A password
    ///     - completionHandler: A closure providing a boolean indicating if the authentication was successful and an optional error if it was not successful
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
                        if let username = dataDict["user_name"] as? String {
                            TokenHelper.storeHitboxUsername(username)
                        }
                        
                        TokenHelper.storeHitboxToken(token)
                        Mixpanel.tracker()?.trackEvents([Event.ServiceAuthenticationEvent("Hitbox")])
                        Logger.Debug("Successfully authenticated")
                        completionHandler(success: true, error: nil)
                        return
                    }
                }
                Logger.Error("Could not parse the response as JSON")
                completionHandler(success: false, error: .NoAuthTokenError)
            }
            else {
                Logger.Error("Could not request for authentication")
                completionHandler(success: false, error: .URLError)
            }
        }
    }

}
