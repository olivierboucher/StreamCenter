//
//  TwitchChatMessage.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.

import Foundation

struct TwitchChatMessage {
    
    var senderName : String
    var message : String
    var emotes = [String : String]()
    var senderDisplayColor : String
}

extension IRCMessage {
    func toTwitchChatMessage() -> TwitchChatMessage? {
        //print("\nMutating IRCMessage to TwitchChatMessage") //DEBUG
        guard parameters.count == 2 else {
            return nil
        }
        
        guard parameters[1].characters.count > 0 else {
            return nil
        }
        
        let message = parameters[1]
        var senderName = "Unknown"
        var senderDisplayColor = "#555555"
        var emotes = [String : String]()
        
        if let emoteString = self.intentOrTags["emotes"] {
            if emoteString.characters.count > 0 {
                //print("Emote string: \(emoteString)") //DEBUG
                let emotesById = emoteString.containsString("/") ? emoteString.componentsSeparatedByString("/") : [emoteString]
                
                for emote in emotesById {
                    // id = [0] and values = [1]
                    let rangesById = emote.componentsSeparatedByString(":")
                    let emoteId = rangesById[0]
                    let emoteRawRanges = rangesById[1].componentsSeparatedByString(",")
                    
                    if let rawRange = emoteRawRanges.first {
                        let startEnd = rawRange.componentsSeparatedByString("-")
                        if let start = Int(startEnd[0]){
                            if let end = Int(startEnd[1]) {
                                let emote = message[start...end]
                                
                                emotes[emoteId] = emote
                            }
                        }
                    }
                }
            }
        }
        
        
        if let displayNameString = self.intentOrTags["display-name"] {
            if displayNameString.characters.count > 0 {
                //print("Display name: \(displayNameString)") //DEBUG
                senderName = displayNameString.sanitizedIRCString()
                //print("Sanitized name: \(senderName)") //DEBUG
            }
        }
        
        if let colorString = self.intentOrTags["color"] {
            if colorString.characters.count == 7 {
                senderDisplayColor = colorString
            }
        }
        //print("\n") //DEBUG
        return TwitchChatMessage(senderName: senderName, message: message, emotes: emotes, senderDisplayColor: senderDisplayColor)
    }
}