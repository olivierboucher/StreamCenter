//
//  IRCConnection.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-17.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import CocoaAsyncSocket



class IRCChatConnection {
    
    enum ChatConnectionStatus {
        case Disconnected
        case ServerDisconnected
        case Connecting
        case Connected
        case Suspended
    }
    
    private let QUEUE_WAIT_BEFORE_CONNECTED : Double = 120
    
    private var chatConnection : GCDAsyncSocket?
    private var connectionQueue : dispatch_queue_t
    private let queueLock : dispatch_semaphore_t
    private var sendQueue : [AnyObject]
    private var status : ChatConnectionStatus
    private var lastConnectAttempt : NSDate?
    private var queueWait : NSDate?
    private var sendQueueProcessing : Bool = false
    private var connectedDate : NSDate?
    
    private var recentlyConnected : Bool {
        get {
            guard let connectedDate = connectedDate as NSDate! else {
                return false
            }
            return NSDate.timeIntervalSinceReferenceDate() - connectedDate.timeIntervalSinceReferenceDate > 10
        }
    }
    
    private var minimumSendQueueDelay : Double {
        get {
            return self.recentlyConnected ? 0.5 : 0.25
        }
    }
    
    private var maximumSendQueueDelay : Double {
        get {
            return self.recentlyConnected ? 1.5 : 0.3
        }
    }
    
    private var sendQueueDelayIncrement : Double {
        get {
            return self.recentlyConnected ? 0.25 : 0.15
        }
    }
    
    init? () {
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
        connectionQueue = dispatch_queue_create("com.twitch.ircchatconnection", queueAttr)
        status = .Disconnected
        sendQueue = [AnyObject]()
        queueLock = dispatch_semaphore_create(1)
    }
    
    func connect() {
        if status != .Disconnected &&
           status != .ServerDisconnected &&
           status != .Suspended
        { return }
        
        lastConnectAttempt = NSDate()
        queueWait = NSDate(timeIntervalSinceNow: QUEUE_WAIT_BEFORE_CONNECTED)
        
        
    }
    
    private func _connect() {
        chatConnection = GCDAsyncSocket(delegate: self, delegateQueue: connectionQueue, socketQueue: connectionQueue)
        chatConnection?.IPv6Enabled = true
        chatConnection?.IPv4PreferredOverIPv6 = true
        
        do {
            try chatConnection?.connectToHost("", onPort: 6667)
            resetSendQueueInterval()
        }
        catch _ {
            dispatch_async(dispatch_get_main_queue(), {
                self.didNotConnect()
            })
        }
    }
    
    private func willConnect() {
//        MVAssertMainThreadRequired();
//        MVSafeAdoptAssign( _lastError, nil );
//        
//        _nextAltNickIndex = 0;
//        _status = MVChatConnectionConnectingStatus;
//        
//        [[self localUser] _setIdentified:NO];
//        
//        [[NSNotificationCenter chatCenter] postNotificationName:MVChatConnectionWillConnectNotification object:self];
    }
    
    private func didNotConnect() {
        
    }
    
    private func resetSendQueueInterval() {
        self.stopSendQueue()
        dispatch_semaphore_wait(queueLock, DISPATCH_TIME_FOREVER)
        if (self.sendQueue.count > 0){
            startSendQueue()
        }
        dispatch_semaphore_signal(queueLock)
    }
    
    private func startSendQueue() {
        if sendQueueProcessing { return }
        
        sendQueueProcessing = true

        let timeInterval = (queueWait != nil && queueWait!.timeIntervalSinceNow > 0) ? queueWait!.timeIntervalSinceNow : minimumSendQueueDelay
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(timeInterval * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self._sendQueue()
        })
    }
    
    private func stopSendQueue() {
        sendQueueProcessing = false
    }
    
    private func _sendQueue() {
        dispatch_semaphore_wait(queueLock, DISPATCH_TIME_FOREVER)
        if (self.sendQueue.count <= 0){
            sendQueueProcessing = false
            return
        }
        dispatch_semaphore_signal(queueLock)
        
        if queueWait != nil && queueWait?.timeIntervalSinceNow > 0 {
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(queueWait!.timeIntervalSinceNow * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self._sendQueue()
            })
            return
        }
        
        dispatch_semaphore_wait(queueLock, DISPATCH_TIME_FOREVER)
        
        //        NSData *data = nil;
        //        @synchronized( _sendQueue ) {
        //            data = _sendQueue[0];
        //            [_sendQueue removeObjectAtIndex:0];
        //
        //            if( _sendQueue.count )
        //            [self performSelector:@selector( _sendQueue ) withObject:nil afterDelay:MIN( [self minimumSendQueueDelay] + ( _sendQueue.count * [self sendQueueDelayIncrement] ), [self maximumSendQueueDelay] )];
        //            else _sendQueueProcessing = NO;
        //        }
        //
        //        __weak __typeof__((self)) weakSelf = self;
        //        dispatch_async(_connectionQueue, ^{
        //            __strong __typeof__((weakSelf)) strongSelf = weakSelf;
        //            MVSafeAdoptAssign( strongSelf->_lastCommand, [[NSDate alloc] init] );
        //            [strongSelf _writeDataToServer:data];
        //            });
        
        dispatch_semaphore_signal(queueLock)
    }
}

extension IRCChatConnection : GCDAsyncSocketDelegate {
    
}