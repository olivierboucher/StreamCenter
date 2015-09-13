//
//  M3UParser.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class M3UParser {
    
    static func parseToDict(data : String) -> NSArray? {
        let dataByLine = data.componentsSeparatedByString("\n");
        
        let resultArray = NSMutableArray();
        
        if(dataByLine[0] == "#EXTM3U"){
            for(var i = 1; i < dataByLine.count ; i++) {
                if(dataByLine[i].hasPrefix("#EXT-X-STREAM-INF:PROGRAM-ID=1,")){
                    let line = dataByLine[i];
                    var codecs : String?;
                    var quality : String?;
                    var url : NSURL?;
                    
                    if let codecsRange = line.rangeOfString("CODECS=\"") {
                        if let videoRange = line.rangeOfString("VIDEO=\"") {
                            codecs = line.substringWithRange(Range<String.Index>(start: codecsRange.endIndex, end:videoRange.startIndex.advancedBy(-2)));
                            quality = line.substringWithRange(Range<String.Index>(start: videoRange.endIndex, end:line.endIndex.advancedBy(-1)));
                            
                            if(dataByLine[i+1].hasPrefix("http")){
                                url = NSURL(string: dataByLine[i+1].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!);
                            }
                        }
                    }
                    
                    if(codecs != nil && quality != nil && url != nil){
                        resultArray.addObject(TwitchStreamVideo(quality: quality!, url: url!, codecs: codecs!));
                    }
                    
                }
            }
        }
        else {
            NSLog("Data is not a valid M3U file");
        }
    
        return resultArray;
    }
}
