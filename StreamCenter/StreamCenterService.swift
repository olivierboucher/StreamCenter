//
//  StreamCenterService.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/15/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import Alamofire

enum ServiceError: ErrorType {
    case URLError
    case JSONError
    case DataError
    case AuthError
    case NoAuthTokenError
    case OtherError(String)
    
    var errorDescription: String {
        get {
            switch self {
            case .URLError:
                return "There was an error with the request."
            case .JSONError:
                return "There was an error parsing the JSON."
            case .DataError:
                return "The response contained bad data"
            case .AuthError:
                return "The user is not authenticated."
            case .NoAuthTokenError:
                return "There was no auth token provided in the response data."
            case .OtherError(let message):
                return message
            }
        }
    }
    
    //only use this top log, do not present this to the user
    var developerSuggestion: String {
        get {
            switch self {
            case .URLError:
                return "Please make sure that the url is formatted correctly."
            case .JSONError, .DataError:
                return "Please check the request information and response."
            case .AuthError:
                return "Please make sure to authenticate with Twitch before attempting to load this data."
            case .NoAuthTokenError:
                return "Please check the server logs and response."
            case .OtherError: //change to case .OtherError(let message):if you want to be able to utilize an error message
                return "Sorry, there's no provided solution for this error."
            }
        }
    }
}

class StreamCenterService {
    
    static func authenticateTwitch(withCode code: String, andUUID UUID: String, completionHandler: (token: String?, error: ServiceError?) -> ()) {
        let urlString = "http://streamcenterapp.com/oauth/twitch/\(UUID)/\(code)"
        Alamofire.request(.GET, urlString, parameters: [
                "token" : AppDelegate.STREAMCENTER_TOKEN
            ])
            .responseJSON { response in
                
                if response.result.isSuccess {
                    if let dictionary = response.result.value as? [String : AnyObject] {
                        guard let token = dictionary["access_token"] as? String, date = dictionary["generated_date"] as? String else {
                            Logger.Error("Could not retrieve desired information from response:\naccess_token\ngenerated_date")
                            completionHandler(token: nil, error: .NoAuthTokenError)
                            return
                        }
                        //NOTE: date is formatted: '2015-10-13 20:35:12'
                        
                        Mixpanel.tracker()?.trackEvents([Event.ServiceAuthenticationEvent("Twitch")])
                        Logger.Debug("User sucessfully retrieved Oauth token generated: \(date)")
                        completionHandler(token: token, error: nil)
                    }
                    else {
                        Logger.Error("Could not parse response as JSON")
                        completionHandler(token: nil, error: .JSONError)
                    }
                } else {
                    Logger.Error("Could not request Twitch Oauth service")
                    completionHandler(token: nil, error: .URLError)
                    return
                }
                
        }
    }
    
    static func getCustomURL(fromCode code: String, completionHandler: (url: String?, error: ServiceError?) -> ()) {
        let urlString = "http://streamcenterapp.com/customurl/\(code)"
        Alamofire.request(.GET, urlString,  parameters: [
            "token" : AppDelegate.STREAMCENTER_TOKEN
            ])
        .responseJSON { response in
            
            //here's a test url
//            completionHandler(url: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8", error: nil)
//            return
            
            if response.result.isSuccess {
                if let dictionary = response.result.value as? [String : AnyObject] {
                    if let urlString = dictionary["url"] as? String {
                        Logger.Debug("Returned: \(urlString)")
                        completionHandler(url: urlString, error: nil)
                        return
                    }
                    if let errorMessage = dictionary["message"] as? String {
                        Logger.Error("Custom url service returned an error:\n\(errorMessage)")
                        completionHandler(url: nil, error: .OtherError(errorMessage))
                        return
                    }
                }
                Logger.Error("Could not parse response as JSON")
                completionHandler(url: nil, error: .JSONError)
            } else {
                Logger.Error("Could not request the custom url service")
                completionHandler(url: nil, error: .URLError)
            }
        }
    }
    
}
