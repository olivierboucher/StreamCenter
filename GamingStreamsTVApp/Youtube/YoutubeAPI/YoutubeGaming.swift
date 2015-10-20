//
//  YoutubeGaming.swift
//  GamingStreamsTVApp
//
//  Created by Chayel Heinsen on 10/10/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import Alamofire

class YoutubeGaming {
    
//    YoutubeGaming.setAPIKey("AIzaSyAFLrfWAIk9gdaBbC3h7ymNpAtp9gLiWkY")
    
    private static var nextPageToken: String = ""
    private static var APIKey: String?
    private static let baseURL: String = "https://www.googleapis.com/youtube/v3/search"
    
    static var streams : [YoutubeStream]?
    
    /**
     Sets the API Key. Call this in applicationDidFinishLaunching.
     
     - parameter apiKey: The key Google provides you with.
     */
    static func setAPIKey(apiKey: String) {
        APIKey = apiKey
        streams = [YoutubeStream]()
    }
    
    /**
     Fetches for 20 youtube gaming streams.
     
     - parameter pageToken: nil if you want the first 20 streams, otherwise, YoutubeGaming.nextPageToken
     */
    static func getStreams(withPageToken pageToken : String = "", completionHandler : ([YoutubeStream]?, error: ServiceError?) -> ()) {
        
        guard let key = confirmAPIKey() else {
            completionHandler(nil, error: .APIKeyError);
            return
        }
        
        Alamofire.request(.GET, baseURL, parameters:
            ["part"             : "snippet",
            "eventType"         : "live",
            "type"              : "video",
            "videoCategoryId"   : 20,
            "regionCode"        : "US",
            "maxResults"        : 20,
            "pageToken"         : pageToken,
            "key"               : key         ])
            .responseJSON { response in
                
                if response.result.isSuccess {
                    let parsedResponse = parseStreamResponse(response.result.value! as! [String : AnyObject])
                    completionHandler(parsedResponse, error: nil)
                } else {
                    // Handle error here
                    completionHandler(nil, error: .URLError)
                }
        }
    }
    
    static func getLiveStreamURL(forVideo videoID: String, completionHandler: (url: NSURL?, error: ServiceError?) -> ()) {
        let urlString = "http://youtube.com/get_video_info?video_id=\(videoID)&el=player_embedded"
        Alamofire.request(.GET, urlString, parameters:["video_id" : videoID, "el" : "player_embedded"]).responseString { response in
            if response.result.isSuccess {
                if let responseString = response.result.value {
                    let parameters = responseString.componentsSeparatedByString("&")
                    for parameter in parameters {
                        if parameter.hasPrefix("hlsvp=") {
                            guard let index = parameter.rangeOfString("hlsvp=") else {
                                completionHandler(url: nil, error: .DataError)
                                return
                            }
                            
                            guard let parsedURLString = parameter.substringFromIndex(index.endIndex).stringByRemovingPercentEncoding, url = NSURL(string: parsedURLString) else {
                                completionHandler(url: nil, error: .DataError)
                                return
                            }
                            completionHandler(url: url, error: nil)
                            return
                        }
                    }
                }
                completionHandler(url: nil, error: .DataError)
            } else {
                completionHandler(url: nil, error: .URLError)
            }
        }
    }
    
    // MARK: - Private
    
    private static func confirmAPIKey() -> String? {
        
        guard let key = APIKey else {
            print("Please ensure that you provide an API Key.")
            return nil
        }
        
        return key
    }
    
    private static func parseStreamResponse(data : [String : AnyObject]) -> [YoutubeStream]? {
        
        var parsedArray = [YoutubeStream]()
        
        if let nextPage = data["nextPageToken"] as? String {
            nextPageToken = nextPage
            print("Next Page Token : \(nextPageToken)")
        } else {
            nextPageToken = ""
        }
        
        if let streamsData = data["items"] as? [[String : AnyObject]] {
            
            for streamDict in streamsData {
                
                if let stream = YoutubeStream(dict: streamDict) {
                    streams?.append(stream)
                    parsedArray.append(stream)
                }
            }
        }
        
        return parsedArray
    }
}