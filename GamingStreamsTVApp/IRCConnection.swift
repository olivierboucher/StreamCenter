//
//  IRCConnection.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-17.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import CocoaAsyncSocket



class IRCConnection {
    
    enum ChatConnectionStatus {
        case Disconnected
        case ServerDisconnected
        case Connecting
        case Connected
        case Suspended
    }
    
    private let QUEUE_WAIT_BEFORE_CONNECTED : Double = 120
    private let MAXIMUM_COMMAND_LENGHT : Int = 510
    
    private var chatConnection : GCDAsyncSocket?
    private var connectionQueue : dispatch_queue_t
    private let sendQueueLock : dispatch_semaphore_t
    private var sendQueue : [NSData]
    private var status : ChatConnectionStatus
    private var credentials : IRCCredentials?
    private var capabilities : IRCCapabilities?
    private var lastConnectAttempt : NSDate?
    private var lastCommand : NSDate?
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
        sendQueue = [NSData]()
        sendQueueLock = dispatch_semaphore_create(1)
    }
    
    func connect(credentials : IRCCredentials, capabilities : IRCCapabilities) {
        if status != .Disconnected &&
           status != .ServerDisconnected &&
           status != .Suspended
        { return }
        
        self.credentials = credentials
        self.capabilities = capabilities
        lastConnectAttempt = NSDate()
        queueWait = NSDate(timeIntervalSinceNow: QUEUE_WAIT_BEFORE_CONNECTED)
        
        willConnect()
        _connect()
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
        dispatch_semaphore_wait(sendQueueLock, DISPATCH_TIME_FOREVER)
        if (self.sendQueue.count > 0){
            startSendQueue()
        }
        dispatch_semaphore_signal(sendQueueLock)
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
        dispatch_semaphore_wait(sendQueueLock, DISPATCH_TIME_FOREVER)
        if (self.sendQueue.count <= 0){
            sendQueueProcessing = false
            return
        }
        dispatch_semaphore_signal(sendQueueLock)
        
        if queueWait != nil && queueWait?.timeIntervalSinceNow > 0 {
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(queueWait!.timeIntervalSinceNow * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self._sendQueue()
            })
            return
        }
        
        dispatch_semaphore_wait(sendQueueLock, DISPATCH_TIME_FOREVER)
        let data = sendQueue.first
        sendQueue.removeFirst()
        dispatch_semaphore_signal(sendQueueLock)
        
        if sendQueue.count > 0 {
            let calculatedQueueDelay = (minimumSendQueueDelay + (Double(sendQueue.count) * sendQueueDelayIncrement))
            let delay = calculatedQueueDelay > maximumSendQueueDelay ? maximumSendQueueDelay : calculatedQueueDelay
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self._sendQueue()
            })
        }
        else {
            sendQueueProcessing = false
        }
        
        dispatch_async(connectionQueue, {
            self.lastCommand = NSDate()
            self.writeDataToServer(data!)
        })
    }
    
    private func writeDataToServer(data : NSData) {
        // IRC messages are always lines of characters terminated with a CR-LF
        // (Carriage Return - Line Feed) pair, and these messages SHALL NOT
        // exceed 512 characters in length, counting all characters including
        // the trailing CR-LF. Thus, there are 510 characters maximum allowed
        // for the command and its parameters.
        var vdata : NSMutableData = NSMutableData()
        
        if data.length > MAXIMUM_COMMAND_LENGHT {
            vdata = NSMutableData(data: data.subdataWithRange(NSRange(location: 0, length: MAXIMUM_COMMAND_LENGHT)))
        } else {
            vdata = NSMutableData(data: data)
        }
        
        
        if vdata.hasSuffix(bytes: [0x0D]) {
            vdata.appendBytes(bytes: [0x0A])
        }
        else if !vdata.hasSuffix(bytes: [0x0D, 0x0A]){
            if vdata.hasSuffix(bytes: [0x0A]){
                vdata.replaceBytesInRange(NSRange(location: vdata.length - 1, length: 1), bytes: [0x0D, 0x0A])
            }
            else {
                vdata.appendBytes(bytes: [0x0D, 0x0A])
            }
        }
        
        chatConnection!.writeData(vdata, withTimeout: -1, tag: 0)
//        
//        NSMutableString *mutableString = [string mutableCopy];
//        [mutableString replaceOccurrencesOfRegex:@"(^PASS |^AUTHENTICATE (?!\\+$|PLAIN$)|IDENTIFY (?:[^ ]+ )?|(?:LOGIN|AUTH|JOIN) [^ ]+ )[^ ]+$" withString:@"$1********" options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, string.length) error:NULL];
//        
//        [[NSNotificationCenter chatCenter] postNotificationOnMainThreadWithName:MVChatConnectionGotRawMessageNotification object:self userInfo:@{ @"message": [mutableString copy], @"messageData": data, @"outbound": @(YES) }];

    }

//    - (void) _cancelScheduledSendEndCapabilityCommand {
//    _sendEndCapabilityCommandAtTime = 0.;
//    }
//    
//    - (void) _sendEndCapabilityCommandAfterTimeout {
//    [self _cancelScheduledSendEndCapabilityCommand];
//    
//    _sendEndCapabilityCommandAtTime = [NSDate timeIntervalSinceReferenceDate] + JVEndCapabilityTimeoutDelay;
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(JVEndCapabilityTimeoutDelay * NSEC_PER_SEC)), _connectionQueue, ^{
//    [self _sendEndCapabilityCommandForcefully:NO];
//    });
//    }
//    
//    - (void) _sendEndCapabilityCommandSoon {
//    [self _cancelScheduledSendEndCapabilityCommand];
//    
//    _sendEndCapabilityCommandAtTime = [NSDate timeIntervalSinceReferenceDate] + 1.;
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), _connectionQueue, ^{
//    [self _sendEndCapabilityCommandForcefully:NO];
//    });
//    }
//    
//    - (void) _sendEndCapabilityCommandForcefully:(BOOL) forcefully {
//    if( _sentEndCapabilityCommand )
//    return;
//    
//    if( !forcefully && (!_sendEndCapabilityCommandAtTime || [NSDate timeIntervalSinceReferenceDate] < _sendEndCapabilityCommandAtTime))
//    return;
//    
//    [self _cancelScheduledSendEndCapabilityCommand];
//    
//    _sentEndCapabilityCommand = YES;
//    
//    [self sendRawMessageImmediatelyWithFormat:@"CAP END"];
//    }
    func sendStringMessage(message : String, immedtiately now : Bool) {
        sendRawMessage(message.dataUsingEncoding(NSUTF8StringEncoding)!, immeditately: now)
    }
    
    func sendRawMessage(raw : NSData, immeditately now : Bool) {
        var nnow = now
        if !nnow {
            dispatch_semaphore_wait(sendQueueLock, DISPATCH_TIME_FOREVER)
            nnow = sendQueue.count == 0
            dispatch_semaphore_signal(sendQueueLock)
        }
        
        if nnow {
            nnow = queueWait == nil || queueWait!.timeIntervalSinceNow <= 0
        }
        if nnow {
            nnow = lastCommand == nil || lastCommand?.timeIntervalSinceNow <= (-minimumSendQueueDelay)
        }
        
        if nnow {
            dispatch_async(connectionQueue, {
                self.lastCommand = NSDate()
                self.writeDataToServer(raw)
            })
        }
        else {
            dispatch_semaphore_wait(sendQueueLock, DISPATCH_TIME_FOREVER)
            sendQueue.append(raw)
            dispatch_semaphore_signal(sendQueueLock)
            
            if !sendQueueProcessing {
                dispatch_async(dispatch_get_main_queue(), {
                    self.startSendQueue()
                })
            }
        }
    }
}

extension IRCConnection : GCDAsyncSocketDelegate {
    @objc
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {

//        { // schedule an end to the capability negotiation in case it stalls the connection
//            [self _sendEndCapabilityCommandAfterTimeout];
//            
        let capabilitiesCommand = capabilities!.getIRCCommandString()
        if let cmd = capabilitiesCommand as String! {
            sendStringMessage(cmd, immedtiately: true)
        }
        
        if credentials?.password.characters.count > 0 {
            sendStringMessage("PASS \(credentials?.password)", immedtiately: true)
        }
        
        self.sendStringMessage("NICK \(credentials?.nick)", immedtiately: true)
        //TODO(Olivier): In with twitch we don't deal with the USER ... command. Implement it if necessary
        //[self sendRawMessageImmediatelyWithFormat:@"USER %@ 0 * :%@", username, ( _realName.length ? _realName : @"Anonymous User" )];

//        dispatch_async(dispatch_get_main_queue(), ^{
//        [self performSelector:@selector(_periodicEvents) withObject:nil afterDelay:JVPeriodicEventsInterval];
//        });
//        
//        [self _pingServerAfterInterval];
//        
//        [self _readNextMessageFromServer];
    }
    
    @objc
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
//        @autoreleasepool {
//            [self _processIncomingMessage:data fromServer:YES];
//            
//            [self _readNextMessageFromServer];
//        }
    }
    
    @objc
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        
    }
}