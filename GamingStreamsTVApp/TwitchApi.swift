//
//  TwitchApi.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import Alamofire

class TwitchApi {
    
    static func getStreamsForChannel(channel : String, completionHandler: (streams: NSArray?, error: NSError?) -> ()){
        //First we build the url according to the channel we desire to get stream link
        let accessUrlString = String(format: "https://api.twitch.tv/api/channels/%@/access_token", channel);
        
        Alamofire.request(.GET, accessUrlString)
            .responseJSON { _, _, result in
                if(result.isSuccess){
                    if let accessInfoDict = result.value as? NSDictionary {
                        if let sig = accessInfoDict["sig"] as? String {
                            if let token = accessInfoDict["token"] as? String {
                                let playlistUrlString  = String(format : "http://usher.twitch.tv/api/channel/hls/%@.m3u8", channel);
                                
                                Alamofire.request(.GET, playlistUrlString, parameters :
                                    [   "player"            : "twitchweb",
                                        "allow_audio_only"  : "true",
                                        "allow_source"      : "true",
                                        "type"              : "any",
                                        "p"                 : 1234,
                                        "token"             : token,
                                        "sig"               : sig])
                                    .responseString { _, _, result in
                                        if(result.isSuccess){
                                            let streams = M3UParser.parseToDict(result.value!);
                                            completionHandler(streams: streams, error: nil);
                                            return
                                        }
                                        else {
                                            //Error with the .m3u8
                                            let userInfo = [
                                                NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                                                NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", result.error.debugDescription),
                                                NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                                            ];
                                            completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo));
                                            return
                                        }
                                }
                            }
                        }
                    }
                    //Error with the access token json response
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid JSON object"),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                    ];
                    completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 2, userInfo: userInfo));
                    return
                    
                }
                else {
                    //Error with access token request
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", result.error.debugDescription),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                    ];
                    completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo));
                    return
                    
                }
        }
        
    }
    
    static func getTopGamesWithOffset(offset : Int, limit : Int, completionHandler: (games: NSArray?, error: NSError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let gamesUrlString = "https://api.twitch.tv/kraken/games/top";
        
        Alamofire.request(.GET, gamesUrlString, parameters :
            [   "limit"   : limit,
                "offset"  : offset])
            .responseJSON { _, _, result in
                
                if(result.isSuccess) {
                    if let gamesInfoDict = result.value as? NSDictionary {
                        let games = NSMutableArray();
                        for gameRaw in gamesInfoDict["top"] as! NSArray {
                            if let topItemDict = gameRaw as? NSDictionary {
                                if let gameDict = topItemDict["game"] as? NSDictionary {
                                    games.addObject(TwitchGame(
                                        id : gameDict["_id"] as! Int,
                                        viewers : topItemDict["viewers"] as! Int,
                                        channels : topItemDict["channels"] as! Int,
                                        name : gameDict["name"] as! String,
                                        thumbnails : gameDict["box"] as! NSDictionary,
                                        logos : gameDict["logo"] as! NSDictionary));
                                }
                            }
                        }
                        completionHandler(games: games, error: nil);
                        return
                    }
                    else {
                        let userInfo = [
                            NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                            NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                            NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided url is valid")
                        ];
                        completionHandler(games: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo));
                        return
                    }
                }
                else {
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", result.error.debugDescription),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                    ];
                    completionHandler(games: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo));
                    return
                }
        }
        
    }
    
    static func getTopStreamsForGameWithOffset(game : String, offset : Int, limit : Int, completionHandler: (streams: NSArray?, error: NSError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let streamsUrlString = "https://api.twitch.tv/kraken/streams";
        
        Alamofire.request(.GET, streamsUrlString, parameters :
            [   "limit"   : limit,
                "offset"  : offset,
                "game"    : game])
            .responseJSON { _, _, result in
                
                if(result.isSuccess) {
                    if let streamsInfoDict = result.value as? NSDictionary {
                        
                        let streams = NSMutableArray();
                        let dateFormatter = NSDateFormatter();
                        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX";
                        
                        for streamRaw in streamsInfoDict["streams"] as! NSArray {
                            if let streamDict = streamRaw as? NSDictionary {
                                //First extract the channel infos from the stream
                                var channel : TwitchChannel?;
                                if let channelDict = streamDict["channel"] as? NSDictionary {
                                    channel = TwitchChannel(
                                        id: channelDict["_id"] as! Int,
                                        name : channelDict["name"] as! String,
                                        displayName : channelDict["display_name"] as! String,
                                        links : channelDict["_links"] as! NSDictionary,
                                        broadcasterLanguage : channelDict["broadcaster_language"] as? String!,
                                        language: channelDict["language"] as! String,
                                        gameName : channelDict["game"] as! String,
                                        logo : channelDict["logo"] as? String!,
                                        status : channelDict["status"] as! String,
                                        videoBanner : channelDict["video_banner"] as? String!,
                                        lastUpdate : dateFormatter.dateFromString(channelDict["updated_at"] as! String)!,
                                        followers : channelDict["followers"] as! Int,
                                        views : channelDict["views"] as! Int
                                    );
                                    streams.addObject(TwitchStream(
                                        id : streamDict["_id"] as! Int,
                                        gameName : streamDict["game"] as! String,
                                        viewers : streamDict["viewers"] as! Int,
                                        videoHeight : streamDict["video_height"] as! Int,
                                        preview : streamDict["preview"] as! NSDictionary,
                                        channel : channel!
                                        ));
                                }
                                else {
                                    let userInfo = [
                                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                                        NSLocalizedFailureReasonErrorKey: String("Could not parse channel data to NSDictionnary"),
                                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided game is valid")
                                    ];
                                    completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo));
                                    return
                                }
                            }
                        }
                        completionHandler(streams: streams, error: nil);
                        return
                    }
                    else {
                        let userInfo = [
                            NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                            NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                            NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided game is valid")
                        ];
                        completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo));
                        return
                    }
                    
                }
                else {
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("The operation returned an error : %@", result.error.debugDescription),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                    ];
                    completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo));
                    return
                }
        }
    }
}
