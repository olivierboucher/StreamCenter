//
//  TwitchApi.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation
import Alamofire

class TwitchApi {
    
    ///This is a method to retrieve Twitch streams for a provided channel
    ///
    /// - parameters:
    ///     - channel: A string indicating the name of the channel that we are trying to get the stream info for
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    static func getStreamsForChannel(channel : String, completionHandler: (streams: [TwitchStreamVideo]?, error: ServiceError?) -> ()){
        //First we build the url according to the channel we desire to get stream link
        let accessUrlString = String(format: "https://api.twitch.tv/api/channels/%@/access_token", channel)
        
        Alamofire.request(.GET, accessUrlString)
        .responseJSON { response in
            
            if response.result.isSuccess {
                if let accessInfoDict = response.result.value as? [String : AnyObject] {
                    if let sig = accessInfoDict["sig"] as? String {
                        if let token = accessInfoDict["token"] as? String {
                            let playlistUrlString  = String(format : "http://usher.twitch.tv/api/channel/hls/%@.m3u8", channel)
                            
                            Alamofire.request(.GET, playlistUrlString, parameters :
                                [   "player"            : "twitchweb",
                                    "allow_audio_only"  : "true",
                                    "allow_source"      : "true",
                                    "type"              : "any",
                                    "p"                 : Int(arc4random_uniform(99999)),
                                    "token"             : token,
                                    "sig"               : sig])
                                .responseString { response in
                                    if response.result.isSuccess {
                                        let streams = M3UParser.parseToDict(response.result.value!)
                                        completionHandler(streams: streams, error: nil)
                                        return
                                    }
                                    else {
                                        //Error with the .m3u8
                                        completionHandler(streams: nil, error: .URLError)
                                        return
                                    }
                            }
                            return
                        }
                    }
                }
                //Error with the access token json response
                completionHandler(streams: nil, error: .JSONError)
                return
                
            }
            else {
                //Error with access token request
                completionHandler(streams: nil, error: .URLError)
                return
                
            }
        }
        
    }
    
    ///This is a method to retrieve the most popular Twitch games
    ///
    /// - parameters:
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of games to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    static func getTopGamesWithOffset(offset : Int, limit : Int, completionHandler: (games: [TwitchGame]?, error: ServiceError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let gamesUrlString = "https://api.twitch.tv/kraken/games/top"
        
        Alamofire.request(.GET, gamesUrlString, parameters :
            [   "limit"   : limit,
                "offset"  : offset])
        .responseJSON { response in
            
            if response.result.isSuccess {
                if let gamesInfoDict = response.result.value as? [String : AnyObject] {
                    if let gamesDicts = gamesInfoDict["top"] as? [[String : AnyObject]] {
                        var games = [TwitchGame]()
                        for gameRaw in gamesDicts {
                            if let game = TwitchGame(dict: gameRaw) {
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
    
    ///This is a method to retrieve the most popular Twitch streams for a given game
    ///
    /// - parameters:
    ///     - game: The game that we are attempting to get the streams for
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of streams to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    static func getTopStreamsForGameWithOffset(game : String, offset : Int, limit : Int, completionHandler: (streams: [TwitchStream]?, error: ServiceError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let streamsUrlString = "https://api.twitch.tv/kraken/streams"
        
        Alamofire.request(.GET, streamsUrlString, parameters :
            [   "limit"         : limit,
                "offset"        : offset,
                "game"          : game,
                "stream_type"   : "live"  ])
        .responseJSON { response in
            
            if response.result.isSuccess {
                if let streamsInfoDict = response.result.value as? [String : AnyObject] {
                    if let streamsDicts = streamsInfoDict["streams"] as? [[String : AnyObject]] {
                        var streams = [TwitchStream]()
                        for streamRaw in streamsDicts {
                            if let channelDict = streamRaw["channel"] as? [String : AnyObject] {
                                if let channel = TwitchChannel(dict: channelDict), stream = TwitchStream(dict: streamRaw, channel: channel) {
                                    streams.append(stream)
                                }
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
    
    ///This is a method to retrieve Twitch games based on a search term
    ///
    /// - parameters:
    ///     - term: A search term
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of games to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    static func getGamesWithSearchTerm(term: String, offset : Int, limit : Int, completionHandler: (games: [TwitchGame]?, error: ServiceError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let searchUrlString = "https://api.twitch.tv/kraken/search/games"
        
        Alamofire.request(.GET, searchUrlString, parameters :
            [   "query"     : term,
                "type"      : "suggest",
                "live"      : true          ])
        .responseJSON { response in
            
            if response.result.isSuccess {
                if let gamesInfoDict = response.result.value as? [String : AnyObject] {
                    if let gamesDicts = gamesInfoDict["games"] as? [[String : AnyObject]] {
                        var games = [TwitchGame]()
                        for gameDict in gamesDicts {
                            if let game = TwitchGame(dict: gameDict) {
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
    
    ///This is a method to retrieve Twitch streams based on a search term
    ///
    /// - parameters:
    ///     - term: A search term
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of streams to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    static func getStreamsWithSearchTerm(term : String, offset : Int, limit : Int, completionHandler: (streams: [TwitchStream]?, error: ServiceError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let streamsUrlString = "https://api.twitch.tv/kraken/streams"
        
        Alamofire.request(.GET, streamsUrlString, parameters :
            [   "limit"     : limit,
                "offset"    : offset,
                "query"     : term    ])
        .responseJSON { response in
            
            if response.result.isSuccess {
                if let streamsInfoDict = response.result.value as? [String : AnyObject] {
                    if let streamsDicts = streamsInfoDict["streams"] as? [[String : AnyObject]] {
                        var streams = [TwitchStream]()
                        for streamDict in streamsDicts {
                            if let channelDict = streamDict["channel"] as? [String : AnyObject] {
                                if let channel = TwitchChannel(dict: channelDict), stream = TwitchStream(dict: streamDict, channel: channel) {
                                    streams.append(stream)
                                }
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
    
    ///This is a method to retrieve Twitch streams that a user is following
    ///
    /// - parameters:
    ///     - term: A search term
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of games to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    static func getStreamsThatUserIsFollowing(offset : Int, limit : Int, completionHandler: (streams: [TwitchStream]?, error: ServiceError?) -> ()) {
        
        guard let token = TokenHelper.getTwitchToken() else {
            completionHandler(streams: nil, error: .AuthError)
            return
        }
        //First we build the url according to the game we desire to get infos
        let streamsUrlString = "https://api.twitch.tv/kraken/streams/followed"
        
        Alamofire.request(.GET, streamsUrlString, parameters :
            [   "limit"         : limit,
                "offset"        : offset,
                "oauth_token"   : token     ])
            .responseJSON { response in
                
                if response.result.isSuccess {
                    if let streamsInfoDict = response.result.value as? [String : AnyObject] {
                        if let streamsDicts = streamsInfoDict["streams"] as? [[String : AnyObject]] {
                            var streams = [TwitchStream]()
                            for streamDict in streamsDicts {
                                if let channelDict = streamDict["channel"] as? [String : AnyObject] {
                                    if let channel = TwitchChannel(dict: channelDict), stream = TwitchStream(dict: streamDict, channel: channel) {
                                        streams.append(stream)
                                    }
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
    
    static func getUser(completionHandler: (user: TwitchUser?, error: ServiceError?) -> ()) {
        guard let token = TokenHelper.getTwitchToken() else {
            //do we want to actually return an erro?
            print("you can't get the user info without having an auth token")
            completionHandler(user: nil, error: .AuthError)
            return
        }
        let urlString = "https://api.twitch.tv/kraken/user"
        Alamofire.request(.GET, urlString, parameters: ["oauth_token" : token]).responseJSON { response in
            if response.result.isSuccess {
                //we are going to get the user but we could also get their logo if we want to display it
                if let dictionary = response.result.value as? [String : AnyObject] {
                    if let user = TwitchUser(dict: dictionary) {
                        TokenHelper.storeTwitchUsername(user.name)
                        completionHandler(user: user, error: nil)
                        return
                    }
                }
                print("could not get user object due to a json error")
                completionHandler(user: nil, error: .JSONError)
            } else {
                print("could not get user object due to a request error")
                completionHandler(user: nil, error: .URLError)
            }
        }
    }
    
    static func checkIfUserIsSubscribedToChannel(channelName channel: String, completionHandler: (subscribed: Bool, error:ServiceError?) -> ()) {
        guard let token = TokenHelper.getTwitchToken(), username = TokenHelper.getTwitchUsername() else {
            completionHandler(subscribed: false, error: .AuthError)
            return
        }
        let urlString = "https://api.twitch.tv/kraken/users/\(username)/follows/channels/\(channel)"
        Alamofire.request(.GET, urlString, parameters: ["oauth_token" : token]).responseJSON { response in
            print("status code: \(response.response?.statusCode)")
            if response.result.isSuccess {
//                if let dictionary = response.result.value as? [String : AnyObject] {
//                    if let _ = dictionary["error"] as? String {
//                        //don't return an error, because this just means that the user is not subscribed
//                        completionHandler(subscribed: false, error: nil)
//                    } else {
//                        completionHandler(subscribed: true, error: nil)
//                    }
//                    return
//                }
                completionHandler(subscribed: response.response?.statusCode != 404, error: nil)
            } else {
                completionHandler(subscribed: false, error: .URLError)
            }
        }
    }
    
    static func followOrUnFollowChannel(channelName channel: String, follow: Bool, completionHandler: (success: Bool, error: ServiceError?) -> ()) {
        guard let token = TokenHelper.getTwitchToken(), username = TokenHelper.getTwitchUsername() else {
            completionHandler(success: false, error: .AuthError)
            return
        }
        let urlString = "https://api.twitch.tv/kraken/users/\(username)/follows/channels/\(channel)"
        Alamofire.request(follow ? .PUT : .DELETE, urlString, parameters: ["oauth_token" : token]).responseJSON { response in
            if response.result.isSuccess {
                completionHandler(success: true, error: nil)
            } else {
                completionHandler(success: false, error: .URLError)
            }
        }
    }
    
    static func getUserProfileImage(forUser user: TwitchUser, completionHandler: (image: UIImage?) -> ()) {
        guard let logoURL = user.logoURL else {
            completionHandler(image: nil)
            return
        }
        Alamofire.request(.GET, logoURL).responseData { response in
            if response.result.isSuccess {
                if let data = response.result.value, image = UIImage(data: data) {
                    completionHandler(image: image)
                    return
                }
            }
            completionHandler(image: nil)
        }
    }
    
    static func getEmoteUrlStringFromId(id : String) -> String {
        return  "http://static-cdn.jtvnw.net/emoticons/v1/\(id)/1.0"
    }
}
