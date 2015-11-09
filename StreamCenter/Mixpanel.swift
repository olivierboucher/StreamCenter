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
        if instance == nil {
            Logger.Warning("Returned an uninitialized mixpanel tracker")
        }
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
            let json = try NSJSONSerialization.dataWithJSONObject(events.map({ $0.jsonDictionary }), options: [])
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
                            Logger.Debug("Sent \(count) events correctly")
                            return
                        }
                        else if let error = responseJSON["error"] as? String {
                            Logger.Error("Error from mixpanel: \(error)")
                        }
                    }
                }
                else {
                    Logger.Error("Could not reach Mixpanel's endpoint")
                }
            }

        }
        catch let err as NSError {
            Logger.Error("Error encoding events : \(err)")
        }
    }
    
    private func sendBuffer() {
        guard eventsBuffer.count > 0  else {
            Logger.Debug("No new events, stopping process")
            stopProcessing()
            return
        }
        Logger.Info("Processing events buffer")
        sendEventsBuffer()
    }
    
    private func startProcessing() {
        if self.processTimer == nil && self.timerPaused {
            Logger.Info("Creating a new process timer")
            self.timerPaused = false
            self.processTimer = ConcurrencyHelpers.createDispatchTimer((20 * NSEC_PER_SEC), leeway: (1 * NSEC_PER_SEC)/2, queue: opQueue, block: {
                self.sendBuffer()
            })
        }
        else if self.processTimer != nil && self.timerPaused {
            Logger.Info("Resuming the process timer")
            self.timerPaused = false
            dispatch_resume(self.processTimer!)
        }
    }
    
    private func stopProcessing() {
        if processTimer != nil && !self.timerPaused {
            Logger.Info("Stopping process timer")
            dispatch_suspend(self.processTimer!)
            self.timerPaused = true
        }
    }
    
    func trackEvents(events : [Event]) {
        dispatch_async(opQueue){
            var mutableEvents = [Event]()
            for var event in events {
                mutableEvents.append(event.signedSelf(self.token))
            }
            dispatch_semaphore_wait(self.eventsMutex, DISPATCH_TIME_FOREVER)
            self.eventsBuffer.appendContentsOf(mutableEvents)
            dispatch_semaphore_signal(self.eventsMutex)
            Logger.Info("New event added to queue")
            self.startProcessing()
        }
    }
    
    
}