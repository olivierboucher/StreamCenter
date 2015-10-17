//
//  TwitchApi.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation
import Alamofire

class TwitchApi {
    
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
    
    static func getEmoteUrlStringFromId(id : String) -> String {
        return  "http://static-cdn.jtvnw.net/emoticons/v1/\(id)/1.0"
    }
}
