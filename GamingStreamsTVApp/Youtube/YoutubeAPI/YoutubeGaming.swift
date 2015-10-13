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
    
    private static var nextPageToken: String = ""
    private static var APIKey: String?
    private static let baseURL: String = "https://www.googleapis.com/youtube/v3/search"
    
    static var streams : Array<YoutubeStream>?
    
    /**
     Sets the API Key. Call this in applicationDidFinishLaunching.
     
     - parameter apiKey: The key Google provides you with.
     */
    static func setAPIKey(apiKey: String) {
        APIKey = apiKey
        streams = Array()
    }
    
    /**
     Fetches for 20 youtube gaming streams.
     
     - parameter pageToken: nil if you want the first 20 streams, otherwise, YoutubeGaming.nextPageToken
     */
    static func streamsWithPageToken(var pageToken : String?, completionHandler : (Array<YoutubeStream>?, error: NSError?) -> Void) {
        
        guard confirmAPIKey() else {
            
            let userInfo = [
                NSLocalizedDescriptionKey : String("No API Key."),
                NSLocalizedFailureReasonErrorKey: String("No API Key"),
                NSLocalizedRecoverySuggestionErrorKey: String("Please ensure that you provide an API Key.")
            ];
            
            completionHandler(nil, error: NSError(domain: "YoutubeGaming", code: 1, userInfo: userInfo));
            return
        }
        
        if pageToken == nil {
            pageToken = ""
        }
        
        Alamofire.request(.GET, baseURL, parameters:
            ["part"           : "snippet",
            "eventType"       : "live",
            "type"            : "video",
            "videoCategoryId"  : 20,
            "regionCode"      : "US",
            "maxResults"      : 20,
            "pageToken"       : pageToken!,
            "key"             : APIKey!])
            .responseJSON { response in
                
                if response.result.isSuccess {
                    let parsedResponse = parseStreamResponse(response.result.value! as! Dictionary<String, AnyObject>)
                    completionHandler(parsedResponse, error: nil)
                } else {
                    // Handle error here
                    completionHandler(nil, error: response.result.error)
                }
        }
    }
    
    // MARK: - Private
    
    private static func confirmAPIKey() -> Bool {
        
        guard let _ = APIKey else {
            print("Please ensure that you provide an API Key.")
            return false
        }
        
        return true
    }
    
    private static func parseStreamResponse(data : Dictionary<String, AnyObject>) -> Array<YoutubeStream>? {
        
        var parsedArray : Array<YoutubeStream>? = Array()
        
        if let nextPage = data["nextPageToken"] as? String {
            nextPageToken = nextPage
            print("Next Page Token : \(nextPageToken)")
        } else {
            nextPageToken = ""
        }
        
        if let streamsData : Array<AnyObject> = data["items"] as? [Dictionary<String, AnyObject>] {
            
            for stream in streamsData {
                print(stream)
                
                if let snippet : Dictionary<String, AnyObject> = stream["snippet"] as? Dictionary<String, AnyObject> {
                    var thumbnails = snippet["thumbnails"]! as! Dictionary<String, Dictionary<String, String>>
                    
                    let id = stream["id"] as! Dictionary<String, String>
                    let videoId = id["videoId"]!
                    
                    let newStream = YoutubeStream(
                        id: videoId,
                        title: snippet["title"]! as! String,
                        channelId: snippet["channelId"]! as! String,
                        channelName: snippet["channelTitle"]! as! String,
                        description: snippet["description"]! as! String,
                        thumbnails: [
                            YoutubeThumbnailResolution.Low : thumbnails["default"]!["url"]!,
                            YoutubeThumbnailResolution.Medium : thumbnails["medium"]!["url"]!,
                            YoutubeThumbnailResolution.High: thumbnails["high"]!["url"]!
                        ])
                    
                    streams?.append(newStream)
                    parsedArray?.append(newStream)
                }
            }
        }
        
        return parsedArray
    }
}