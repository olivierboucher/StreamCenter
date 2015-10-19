//
//  TwitchChatMessage.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.

import Foundation

struct TwitchChatMessage {
    
    var senderName : String
    var message : String
    var emotes = [String : [NSRange]]()
    var senderDisplayColor : String
}

extension IRCMessage {
    func toTwitchChatMessage() -> TwitchChatMessage? {
        
        guard parameters.count == 2 else {
            return nil
        }
        
        guard parameters[1].characters.count > 0 else {
            return nil
        }
        
        let message = parameters[1]
        var senderName = "Unknown"
        var senderDisplayColor = "#555555"
        var emotes = [String : [NSRange]]()
        
        if let emoteString = self.intentOrTags["emotes"] {
            if emoteString.characters.count > 0 {
                let emotesById = emoteString.containsString("/") ? emoteString.componentsSeparatedByString("/") : [emoteString]
                
                for emote in emotesById {
                    // id = [0] and values = [1]
                    let rangesById = emote.componentsSeparatedByString(":")
                    let emoteId = rangesById[0]
                    let emoteRawRanges = rangesById[1].componentsSeparatedByString(",")
                    
                    for rawRange in emoteRawRanges {
                        let startEnd = rawRange.componentsSeparatedByString("-")
                        let start = Int(startEnd[0])
                        let end = Int(startEnd[1])
                        
                        let range = NSMakeRange(start!, end! - start! + 1)
                        if emotes[emoteId] == nil {
                            emotes[emoteId] = [range]
                        }
                        else {
                            emotes[emoteId]?.append(range)
                        }
                    }
                }
            }
        }
        
        if let displayNameString = self.intentOrTags["display-name"] {
            if displayNameString.characters.count > 0 {
                senderName = displayNameString.sanitizedIRCString()
            }
        }
        
        if let colorString = self.intentOrTags["color"] {
            if colorString.characters.count == 7 {
                senderDisplayColor = colorString
            }
        }
        
        return TwitchChatMessage(senderName: senderName, message: message, emotes: emotes, senderDisplayColor: senderDisplayColor)
    }
}