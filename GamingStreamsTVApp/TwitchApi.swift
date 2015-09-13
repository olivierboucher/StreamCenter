//
//  TwitchApi.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchApi {
    
    func getStreamsForChannel(channel : String, completionHandler: (streams: NSArray?, error: NSError?) -> ()){
        //First we build the url according to the channel we desire to get stream link
        let accessUrlString = String(format: "https://api.twitch.tv/api/channels/%@/access_token", channel);
        let acessTokenUrl = NSURL(string: accessUrlString);
        //Lets execute the request asyncronously
        let task = NSURLSession.sharedSession().dataTaskWithURL(acessTokenUrl!) {(data, response, error) in
            //First we check for any error
            if(error != nil){
                completionHandler(streams: nil, error: error);
            }
            //We want the request to be a NSHTTPURLResponse since we want the status code
            if(response!.isKindOfClass(NSHTTPURLResponse.classForCoder())){
                let httpResponse = response as! NSHTTPURLResponse;
                
                switch(httpResponse.statusCode) {
                    //The only status code we accept
                    case 200:
                        //We get json, now deserialize it
                        var parsedObject: AnyObject?
                            do {
                                parsedObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments);
                            } catch _ {
                                let userInfo = [
                                    NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                                    NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid JSON object"),
                                    NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                                ];
                                completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 2, userInfo: userInfo));
                            }
                        if let accessInfoDict = parsedObject as? NSDictionary {
                            if let sig : String = accessInfoDict["sig"] as? String {
                                if let token : String = accessInfoDict["token"] as? String {
                                    
                                    //Now that we have our infos, we need to request the playlist
                                    var playlistUrlString : String = "http://usher.twitch.tv/api/channel/hls/\(channel).m3u8?player=twitchweb&token=\(token)&sig=\(sig)&allow_audio_only=true&allow_source=true&type=any&p=1234";
                                    playlistUrlString = playlistUrlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!;
                                    let playlistUrl = NSURL(string: playlistUrlString);
                                    
                                    let secTask = NSURLSession.sharedSession().dataTaskWithURL(playlistUrl!) {(data, response, error) in
                                        //First we check for any error
                                        if(error != nil){
                                            completionHandler(streams: nil, error: error);
                                        }
                                        //We want the request to be a NSHTTPURLResponse since we want the status code
                                        if(response!.isKindOfClass(NSHTTPURLResponse.classForCoder())){
                                            let httpResponse = response as! NSHTTPURLResponse;
                                            
                                            switch(httpResponse.statusCode) {
                                                case 200:
                                                    //We parse the M3U8 file and return the stream object array
                                                    let streams = M3UParser.parseToDict(String(data: data!, encoding: NSUTF8StringEncoding)!);
                                                    completionHandler(streams: streams, error: nil);
                                                    break;
                                                default:
                                                    let userInfo = [
                                                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                                                        NSLocalizedFailureReasonErrorKey: String("The operation returned a status code of %d", httpResponse.statusCode),
                                                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                                                    ];
                                                    completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo));
                                                    break;
                                            }
                                        }
                                    }
                                    
                                    secTask.resume();
                                    
                                }
                                else {
                                    let userInfo = [
                                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                                        NSLocalizedFailureReasonErrorKey: String("Could not extract \"token\" parameter from JSON"),
                                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                                    ];
                                    completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 5, userInfo: userInfo));
                                }
                            }
                            else {
                                let userInfo = [
                                    NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                                    NSLocalizedFailureReasonErrorKey: String("Could not extract \"sig\" parameter from JSON"),
                                    NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                                ];
                                completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 4, userInfo: userInfo));
                            }
                            
                        }
                        else {
                            let userInfo = [
                                NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                                NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                                NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                            ];
                            completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo));
                        }
                        break;
                    
                    default:
                        let userInfo = [
                            NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                            NSLocalizedFailureReasonErrorKey: String("The operation returned a status code of %d", httpResponse.statusCode),
                            NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided channel is valid")
                        ];
                        completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo));
                        break;
                }
            }
        }
        
        task.resume()
    }
    
    func getTopGamesWithOffset(offset : Int, limit : Int, completionHandler: (games: NSArray?, error: NSError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let gamesUrlString = "https://api.twitch.tv/kraken/games/top?limit=\(limit)&offset=\(offset)";
        let gamesUrl = NSURL(string: gamesUrlString);
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(gamesUrl!) {(data, response, error) in
            //First we check for any error
            if(error != nil){
                completionHandler(games: nil, error: error);
            }
            //We want the request to be a NSHTTPURLResponse since we want the status code
            if(response!.isKindOfClass(NSHTTPURLResponse.classForCoder())){
                let httpResponse = response as! NSHTTPURLResponse;
                
                switch(httpResponse.statusCode) {
                    //The only status code we accept
                case 200:
                    //We get json, now deserialize it
                    var parsedObject: AnyObject?
                    do {
                        parsedObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments);
                    } catch _ {
                        let userInfo = [
                            NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                            NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid JSON object"),
                            NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided url is valid")
                        ];
                        completionHandler(games: nil, error: NSError(domain: "TwitchAPI", code: 2, userInfo: userInfo));
                    }
                    if let gamesInfoDict = parsedObject as? NSDictionary {
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
                    }
                    else {
                        let userInfo = [
                            NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                            NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                            NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided url is valid")
                        ];
                        completionHandler(games: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo));
                    }
                    break;
                    
                default:
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("The operation returned a status code of %d", httpResponse.statusCode),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided url is valid")
                    ];
                    completionHandler(games: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo));
                    break;
                }
            }
        }
        
        task.resume();
    }
    
    func getTopStreamsForGameWithOffset(game : String, offset : Int, limit : Int, completionHandler: (streams: NSArray?, error: NSError?) -> ()) {
        //First we build the url according to the game we desire to get infos
        let streamsUrlString = "https://api.twitch.tv/kraken/streams?game=\(game)&limit=\(limit)&offset=\(offset)"
            .stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet());
        let gamesUrl = NSURL(string: streamsUrlString!);
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(gamesUrl!) {(data, response, error) in
            //First we check for any error
            if(error != nil){
                completionHandler(streams: nil, error: error);
            }
            //We want the request to be a NSHTTPURLResponse since we want the status code
            if(response!.isKindOfClass(NSHTTPURLResponse.classForCoder())){
                let httpResponse = response as! NSHTTPURLResponse;
                
                switch(httpResponse.statusCode) {
                    //The only status code we accept
                case 200:
                    //We get json, now deserialize it
                    var parsedObject: AnyObject?
                    do {
                        parsedObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments);
                    } catch _ {
                        let userInfo = [
                            NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                            NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid JSON object"),
                            NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided game is valid")
                        ];
                        completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 2, userInfo: userInfo));
                    }
                    if let streamsInfoDict = parsedObject as? NSDictionary {
                        
                        let streams = NSMutableArray();
                        let dateFormatter = NSDateFormatter();
                        dateFormatter.dateFormat = "yyyy-MM-ddTHH:mm:ssZ";
                        
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
                                        broadcasterLanguage : channelDict[""] as! String,
                                        language: channelDict[""] as! String,
                                        gameName : channelDict[""] as! String,
                                        logo : channelDict[""] as! String,
                                        status : channelDict[""] as! String,
                                        videoBanner : channelDict[""] as! String,
                                        lastUpdate : dateFormatter.dateFromString(channelDict[""] as! String)!,
                                        followers : channelDict[""] as! Int,
                                        views : channelDict[""] as! Int
                                    );
                                    streams.addObject(TwitchStream(
                                        id : streamDict[""] as! Int,
                                        gameName : streamDict[""] as! String,
                                        viewers : streamDict[""] as! Int,
                                        videoHeight : streamDict[""] as! Int,
                                        preview : streamDict[""] as! NSDictionary,
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
                                }
                            }
                        }
                        completionHandler(streams: streams, error: nil);
                    }
                    else {
                        let userInfo = [
                            NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                            NSLocalizedFailureReasonErrorKey: String("Could not parse data to a valid NSDictionnary object"),
                            NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided game is valid")
                        ];
                        completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 3, userInfo: userInfo));
                    }
                    break;
                    
                default:
                    let userInfo = [
                        NSLocalizedDescriptionKey : String("Operation was unsuccessful."),
                        NSLocalizedFailureReasonErrorKey: String("The operation returned a status code of %d", httpResponse.statusCode),
                        NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that the provided game is valid")
                    ];
                    completionHandler(streams: nil, error: NSError(domain: "TwitchAPI", code: 1, userInfo: userInfo));
                    break;
                }
            }
        }
        
        task.resume();
    }
}
