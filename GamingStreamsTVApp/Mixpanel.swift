//
//  Mixpanel.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-28.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import Alamofire

class Mixpanel {
    private static let EVENTS_ENDPOINT = "https://api.mixpanel.com/track/"
    private static var instance : Mixpanel? = nil
    
    static func tracker(withToken token: String) -> Mixpanel {
        if instance == nil {
            instance = Mixpanel(token: token)
        }
        
        return instance!
    }
    
    static func tracker() -> Mixpanel? {
        return instance
    }
    
    private var token : String
    private var opQueue : dispatch_queue_t
    private var eventsBuffer : [Event]
    private let eventsMutex : dispatch_semaphore_t
    private var processTimer : dispatch_source_t?
    private var timerPaused : Bool = true
    
    private init(token : String) {
        self.token = token
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
        opQueue = dispatch_queue_create("com.mixpanel.tracker", queueAttr)
        eventsBuffer = [Event]()
        eventsMutex = dispatch_semaphore_create(1)
    }
    
    private func sendEventsBuffer() {
        dispatch_semaphore_wait(eventsMutex, DISPATCH_TIME_FOREVER)
        let count = eventsBuffer.count
        dispatch_semaphore_signal(eventsMutex)
        do {
            let events = Array(eventsBuffer[0..<count])
            let json = try NSJSONSerialization.dataWithJSONObject(events.getJSONConvertible(), options: [])
            print("MIXPANEL: Payload -> \(String(data: json, encoding: NSUTF8StringEncoding)!)")
            let base64 = json.base64EncodedStringWithOptions([]).stringByReplacingOccurrencesOfString("\n", withString: "")
            
            Alamofire.request(.GET, Mixpanel.EVENTS_ENDPOINT, parameters :
                ["data" : base64,
                 "ip"   : 1,
                 "verbose" : 1]
            ).responseJSON { response in
                
                if response.result.isSuccess {
                    if let responseJSON = response.result.value! as? [String : AnyObject] {
                        if let status = responseJSON["status"] as? Int where status == 1 {
                            //Sucess, let's remove events from buffer
                            dispatch_semaphore_wait(self.eventsMutex, DISPATCH_TIME_FOREVER)
                            self.eventsBuffer.removeRange(0..<count)
                            dispatch_semaphore_signal(self.eventsMutex)
                            print("MIXPANEL: Sent \(count) events correctly")
                            return
                        }
                        else if let error = responseJSON["error"] as? String {
                            print("MIXPANEL ERROR: \(error)")
                        }
                    }
                }
                
                print("MIXPANEL: Error sending data or mixpanel error")
            }

        }
        catch {
            print("MIXPANEL: Error encoding events")
        }
    }
    
    private func sendBuffer() {
        guard eventsBuffer.count > 0  else {
            print("MIXPANEL: no new events, stopping process")
            stopProcessing()
            return
        }
        print("MIXPANEL: Processing events buffer")
        sendEventsBuffer()
    }
    
    private func startProcessing() {
        if self.processTimer == nil && self.timerPaused {
            print("MIXPANEL: creating a new process timer")
            self.timerPaused = false
            self.processTimer = ConcurrencyHelpers.createDispatchTimer((20 * NSEC_PER_SEC), leeway: (1 * NSEC_PER_SEC)/2, queue: opQueue, block: {
                self.sendBuffer()
            })
        }
        else if self.processTimer != nil && self.timerPaused {
            print("MIXPANEL: resuming the process timer")
            self.timerPaused = false
            dispatch_resume(self.processTimer!)
        }
    }
    
    private func stopProcessing() {
        if processTimer != nil && !self.timerPaused {
            print("MIXPANEL: stopping to process")
            dispatch_suspend(self.processTimer!)
            self.timerPaused = true
        }
    }
    
    
    func trackEvents(events : [Event]) {
        print("MIXPANEL: new event added to queue")
        dispatch_async(opQueue){
            var mutableEvents = [Event]()
            for var event in events {
                mutableEvents.append(event.signedSelf(self.token))
            }
            dispatch_semaphore_wait(self.eventsMutex, DISPATCH_TIME_FOREVER)
            self.eventsBuffer.appendContentsOf(mutableEvents)
            dispatch_semaphore_signal(self.eventsMutex)
            self.startProcessing()
        }
    }
    
    
}