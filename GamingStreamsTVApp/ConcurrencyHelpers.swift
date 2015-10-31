//
//  ConcurrencyHelpers.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.

import Foundation

struct ConcurrencyHelpers {
    static func createDispatchTimer(interval: UInt64, leeway: UInt64, queue: dispatch_queue_t, block: dispatch_block_t) -> dispatch_source_t
    {
        let timer : dispatch_source_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        
        dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), interval, leeway)
        dispatch_source_set_event_handler(timer, block)
        dispatch_resume(timer)
        
        return timer
    }
}
