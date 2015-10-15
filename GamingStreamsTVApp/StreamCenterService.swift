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

class StreamCenterService {
    
    static func authenticateTwitch(withCode code: String, andUUID UUID: String, completionHandler: (token: String?, error: ServiceError?) -> ()) {
        let urlString = "http://streamcenterapp.com/oauth/twitch/\(UUID)/\(code)"
        Alamofire.request(.GET, urlString)
            .responseJSON { response in
                //sup
                print(response)
                
                if response.result.isSuccess {
                    if let dictionary = response.result.value as? [String : AnyObject] {
                        guard let token = dictionary["access_token"] as? String, date = dictionary["generated_date"] as? String else {
                            completionHandler(token: nil, error: .NoAuthTokenError)
                            return
                        }
                        print(date)
                        //date is formatted: '2015-10-13 20:35:12'
                        completionHandler(token: token, error: nil)
                    }
                } else {
                    completionHandler(token: nil, error: .URLError)
                    return
                }
                
        }
    }
    
    static func getCustomURL(fromCode code: String, completionHandler: (url: String?, error: ServiceError?) -> ()) {
        let urlString = "http://streamcenterapp.com/customURL/\(code)"
        Alamofire.request(.GET, urlString)
        .responseJSON { response in
            //this is the response
            print(response)
            //here's a test url
//            completionHandler(url: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8", error: nil)
//            return
            
            if response.result.isSuccess {
                if let dictionary = response.result.value as? [String : AnyObject] {
                    if let urlString = dictionary["customurl"] as? String {
                        completionHandler(url: urlString, error: nil)
                        return
                    }
                }
                completionHandler(url: nil, error: .JSONError)
            } else {
                completionHandler(url: nil, error: .URLError)
            }
        }
    }
    
}
