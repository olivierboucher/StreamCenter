//
//  TwitchApi.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation
import Alamofire

class TwitchApi {
    
    static func getStreamsForChannel(channel : String, completionHandler: (streams: [TwitchStreamVideo]?, error: NSError?) -> ()){
        //First we build the url according to the channel we desire to get stream link
        let accessUrlString = String(format: "https://api.twitch.tv/api/channels/%@/access_token", channel)
        
        Alamofire.request(.GET, accessUrlString)
        .responseJSON { response in
            
            if(response.result.isSuccess){
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
                                    if(response.result.isSuccess){
                                        let streams = M3UParser.parseToDict(response.result.value!)
                                        completionHandler(streams: streams, error: nil)
                                        return
                                    }
                                    else {
                                        //Error with the .m3u8
                                        let userInfo = [
                                            NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                                            NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", response.result.error.debugDescription),
                                            NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                                        ]
                                        completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo))
                                        return
                                    }
                            }
                            return
                        }
                    }
                }
                //Error with the access token json response
                let userInfo = [
                    NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                    NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid JSON object"),
                    NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                ]
                completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 2, userInfo: userInfo))
                return
                
            }
            else {
                //Error with access token request
                let userInfo = [
                    NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                    NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", response.result.error.debugDescription),
                    NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                ]
                completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo))
                return
                
            }
        }
        
    }
    
    static func getTopGamesWithOffset(offset : Int, limit : Int, completionHandler: (games: [TwitchGame]?, error: NSError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let gamesUrlString = "https://api.twitch.tv/kraken/games/top"
        
        Alamofire.request(.GET, gamesUrlString, parameters :
            [   "limit"   : limit,
                "offset"  : offset])
        .responseJSON { response in
            
            if(response.result.isSuccess) {
                if let gamesInfoDict = response.result.value as? [String : AnyObject] {
                    var games = [TwitchGame]()
                    for gameRaw in gamesInfoDict["top"] as! [AnyObject] {
                        if let topItemDict = gameRaw as? [String : AnyObject] {
                            if let game = TwitchGame(dict: topItemDict) {
                                games.append(game)
                            }
                        }
                    }
                    completionHandler(games: games, error: nil)
                    return
                }
                else {
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided url is valid")
                    ]
                    completionHandler(games: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo))
                    return
                }
            }
            else {
                let userInfo = [
                    NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                    NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", response.result.error.debugDescription),
                    NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                ]
                completionHandler(games: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo))
                return
            }
        }
        
    }
    
    static func getTopStreamsForGameWithOffset(game : String, offset : Int, limit : Int, completionHandler: (streams: [TwitchStream]?, error: NSError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let streamsUrlString = "https://api.twitch.tv/kraken/streams"
        
        Alamofire.request(.GET, streamsUrlString, parameters :
            [   "limit"         : limit,
                "offset"        : offset,
                "game"          : game,
                "stream_type"   : "live"  ])
        .responseJSON { response in
            
            if(response.result.isSuccess) {
                if let streamsInfoDict = response.result.value as? [String : AnyObject] {
                    
                    var streams = [TwitchStream]()
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
                    
                    for streamRaw in streamsInfoDict["streams"] as! [AnyObject] {
                        if let streamDict = streamRaw as? [String : AnyObject] {
                            //First extract the channel infos from the stream
                            if let channelDict = streamDict["channel"] as? [String : AnyObject] {
                                if let channel = TwitchChannel(dict: channelDict), stream = TwitchStream(dict: streamDict, channel: channel) {
                                    streams.append(stream)
                                }
                                
                            }
                            else {
                                let userInfo = [
                                    NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                                    NSLocalizedFailureReasonErrorKey: String("Could not parse channel data to NSDictionnary"),
                                    NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided game is valid")
                                ]
                                completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo))
                                return
                            }
                        }
                    }
                    completionHandler(streams: streams, error: nil)
                    return
                }
                else {
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided game is valid")
                    ]
                    completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo))
                    return
                }
                
            }
            else {
                let userInfo = [
                    NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                    NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", response.result.error.debugDescription),
                    NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                ]
                completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo))
                return
            }
        }
    }
    
    static func getGamesWithSearchTerm(term: String, offset : Int, limit : Int, completionHandler: (games: [TwitchGame]?, error: NSError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let searchUrlString = "https://api.twitch.tv/kraken/search/games"
        
        Alamofire.request(.GET, searchUrlString, parameters :
            [   "query"     : term,
                "type"      : "suggest",
                "live"      : true          ])
        .responseJSON { response in
            
            if(response.result.isSuccess) {
                if let gamesInfoDict = response.result.value as? [String : AnyObject] {
                    var games = [TwitchGame]()
                    for gameDict in gamesInfoDict["games"] as! [[String : AnyObject]] {
                        if let game = TwitchGame(dict: gameDict) {
                            games.append(game)
                        }
                    }
                    completionHandler(games: games, error: nil)
                    return
                }
                else {
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided url is valid")
                    ]
                    completionHandler(games: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo))
                    return
                }
            }
            else {
                let userInfo = [
                    NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                    NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", response.result.error.debugDescription),
                    NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided search term is valid")
                ]
                completionHandler(games: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo))
                return
            }
        }
    }
    
    static func getStreamsWithSearchTerm(term : String, offset : Int, limit : Int, completionHandler: (streams: [TwitchStream]?, error: NSError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let streamsUrlString = "https://api.twitch.tv/kraken/streams"
        
        Alamofire.request(.GET, streamsUrlString, parameters :
            [   "limit"     : limit,
                "offset"    : offset,
                "query"     : term    ])
            .responseJSON { response in
                
                if(response.result.isSuccess) {
                    if let streamsInfoDict = response.result.value as? [String : AnyObject] {
                        
                        var streams = [TwitchStream]()
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
                        
                        for streamRaw in streamsInfoDict["streams"] as! [AnyObject] {
                            if let streamDict = streamRaw as? [String : AnyObject] {
                                //First extract the channel infos from the stream
                                if let channelDict = streamDict["channel"] as? [String : AnyObject] {
                                    if let channel = TwitchChannel(dict: channelDict), stream = TwitchStream(dict: streamDict, channel: channel) {
                                        streams.append(stream)
                                    }
                                    
                                }
                                else {
                                    let userInfo = [
                                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                                        NSLocalizedFailureReasonErrorKey: String("Could not parse channel data to NSDictionnary"),
                                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided game is valid")
                                    ]
                                    completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo))
                                    return
                                }
                            }
                        }
                        completionHandler(streams: streams, error: nil)
                        return
                    }
                    else {
                        let userInfo = [
                            NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                            NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                            NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided game is valid")
                        ]
                        completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo))
                        return
                    }
                    
                }
                else {
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", response.result.error.debugDescription),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                    ]
                    completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo))
                    return
                }
        }
    }
    
    static func authenticate(completionHandler: (authorized: Bool) -> ()) {
        let urlString = "https://api.twitch.tv/kraken/oauth2/authorize"
        Alamofire.request(.GET, urlString, parameters:
            [   "response_type"     :   "code",
                "client_id"         :   "clientID",
                "redirect_uri"      :   "https://com.rivusmedia.GamingStreamsTVApp.auth",
                "scope"             :   "" ])
            .responseJSON { response in
            //sup
                print(response)
        }
    }
    
    static func getEmoteUrlStringFromId(id : String) -> String {
        return  "http://static-cdn.jtvnw.net/emoticons/v1/\(id)/1.0"
    }
}
