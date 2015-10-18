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
    
    typealias CommandHandlerFunc = ((sender : String?, user : String?, host : String?, command : String?, intentOrTags : [String : String], parameters : [String]) -> ())
    
    enum ChatConnectionStatus {
        case Disconnected
        case ServerDisconnected
        case Connecting
        case Connected
        case Suspended
    }
    
    //Constants
    private let PING_SERVER_INTERVAL : Double = 120
    private let QUEUE_WAIT_BEFORE_CONNECTED : Double = 120
    private let MAXIMUM_COMMAND_LENGHT : Int = 510
    private let END_CAPABILITY_TIMEOUT_DELAY : Double = 45
    
    //GCD
    private var chatConnection : GCDAsyncSocket?
    private var connectionQueue : dispatch_queue_t
    private let sendQueueLock : dispatch_semaphore_t
    
    //Send queue
    private var sendQueue : [NSData]
    private var sendQueueProcessing : Bool = false
    private var queueWait : NSDate?
    
    //Connection state
    private var status : ChatConnectionStatus
    private var connectedDate : NSDate?
    private var lastConnectAttempt : NSDate?
    private var lastCommand : NSDate?
    private var lastError : NSError?
    
    //Capability request state
    private var capabilities : IRCCapabilities?
    private var sendEndCapabilityCommandAtTime : NSDate?
    private var sentEndCapabilityCommand : Bool = false
    
    //Ping - keep alive
    private var nextPingTimeInterval : NSDate?
    
    //Credentials
    private var credentials : IRCCredentials?
    
    //Server state
    private var server : String?
    private var realServer : String?
    
    //Commands
    var commandHandlers = [String : CommandHandlerFunc]()
    
    //Delegate
    let delegate : IRCConnectionDelegate
    
////////////////////////////////////////
// MARK - Computed properties
////////////////////////////////////////
    
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
    
////////////////////////////////////////
// MARK - Lifecycle
////////////////////////////////////////
    
    init (delegate : IRCConnectionDelegate) {
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
        connectionQueue = dispatch_queue_create("com.twitch.ircchatconnection", queueAttr)
        status = .Disconnected
        sendQueue = [NSData]()
        sendQueueLock = dispatch_semaphore_create(1)
        self.delegate = delegate
    }
    
////////////////////////////////////////
// MARK - Public methods
////////////////////////////////////////
    
    func connect(endpoint : IRCEndpoint, credentials : IRCCredentials, capabilities : IRCCapabilities) {
        if status != .Disconnected &&
           status != .ServerDisconnected &&
           status != .Suspended
        { return }
        
        self.credentials = credentials
        self.capabilities = capabilities
        lastConnectAttempt = NSDate()
        queueWait = NSDate(timeIntervalSinceNow: QUEUE_WAIT_BEFORE_CONNECTED)

        connect(endpoint)
    }
    
////////////////////////////////////////
// MARK - Connection
////////////////////////////////////////
    
    private func connect(endpoint : IRCEndpoint) {
        chatConnection = GCDAsyncSocket(delegate: self, delegateQueue: connectionQueue, socketQueue: connectionQueue)
        chatConnection?.IPv6Enabled = true
        chatConnection?.IPv4PreferredOverIPv6 = true
        
        do {
            try chatConnection?.connectToHost(endpoint.host, onPort: endpoint.port)
            resetSendQueueInterval()
        }
        catch _ {
            dispatch_async(dispatch_get_main_queue(), {
                self.didNotConnect()
            })
        }
    }
    
    private func didConnect() {
        delegate.IRCConnectionDidConnect()
    }
    
    private func didNotConnect() {
        delegate.IRCConnectionDidNotConnect()
    }
    
    private func didDisconnect() {
        delegate.IRCConnectionDidDisconnect()
    }
    
////////////////////////////////////////
// MARK - Send Queue
////////////////////////////////////////
    
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
            self.treatSendQueue()
        })
    }
    
    private func stopSendQueue() {
        sendQueueProcessing = false
    }
    
    private func treatSendQueue() {
        dispatch_semaphore_wait(sendQueueLock, DISPATCH_TIME_FOREVER)
        if (self.sendQueue.count <= 0){
            sendQueueProcessing = false
            return
        }
        dispatch_semaphore_signal(sendQueueLock)
        
        if queueWait != nil && queueWait?.timeIntervalSinceNow > 0 {
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(queueWait!.timeIntervalSinceNow * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.treatSendQueue()
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
                self.treatSendQueue()
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
    
////////////////////////////////////////
// MARK - Outgoing data
////////////////////////////////////////
    
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
    
    private func sendStringMessage(message : String, immedtiately now : Bool) {
        sendRawMessage(message.dataUsingEncoding(NSUTF8StringEncoding)!, immeditately: now)
    }
    
    private func sendRawMessage(raw : NSData, immeditately now : Bool) {
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

////////////////////////////////////////
// MARK - Capability requests
////////////////////////////////////////

    private func cancelScheduledSendEndCapabilityCommand() {
        sendEndCapabilityCommandAtTime = nil
    }
    
    private func sendEndCapabilityCommandAfterTimeout() {
        cancelScheduledSendEndCapabilityCommand()
        
        sendEndCapabilityCommandAtTime = NSDate(timeIntervalSinceReferenceDate: NSDate.timeIntervalSinceReferenceDate().advancedBy(END_CAPABILITY_TIMEOUT_DELAY))
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((UInt64(END_CAPABILITY_TIMEOUT_DELAY) * NSEC_PER_SEC))), connectionQueue, {
            self.sendEndCapabilityCommand(forcefully: false)
        })
        
    }
    
    private func sendEndCapabilityCommandSoon() {
        cancelScheduledSendEndCapabilityCommand()
        
        sendEndCapabilityCommandAtTime = NSDate(timeIntervalSinceReferenceDate: NSDate.timeIntervalSinceReferenceDate().advancedBy(1))
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((UInt64(END_CAPABILITY_TIMEOUT_DELAY) * NSEC_PER_SEC))), connectionQueue, {
            self.sendEndCapabilityCommand(forcefully: false)
        })
    }
    
    private func sendEndCapabilityCommand(forcefully force : Bool) {
        if sentEndCapabilityCommand { return }
        
        if !force && sendEndCapabilityCommandAtTime == nil { return }
        
        sentEndCapabilityCommand = true
        
        sendStringMessage("CAP END", immedtiately: true)
    }
    
////////////////////////////////////////
// MARK - Pinging
////////////////////////////////////////

    private func pingServer() {
        let server = realServer == nil ? self.server : realServer
        sendStringMessage("PING \(server)", immedtiately: true)
    }
    
    private func pingServerAfterInterval() {
        if status != .Connecting &&
           status != .Connected
        { return }
        
        nextPingTimeInterval = NSDate(timeIntervalSinceReferenceDate: NSDate.timeIntervalSinceReferenceDate().advancedBy(PING_SERVER_INTERVAL))
        let delayInSeconds = UInt64(PING_SERVER_INTERVAL + 1)
        
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * NSEC_PER_SEC))
        
        dispatch_after(popTime, connectionQueue, {
            let nowTimeInterval = NSDate.timeIntervalSinceReferenceDate()
            
            if self.nextPingTimeInterval!.timeIntervalSinceReferenceDate < nowTimeInterval {
                self.nextPingTimeInterval = NSDate(timeIntervalSinceReferenceDate: nowTimeInterval.advancedBy(self.PING_SERVER_INTERVAL))
                self.pingServer()
            }
        })
    }
    
////////////////////////////////////////
// MARK - Incoming data
////////////////////////////////////////

    private func readNextMessageFromServer() {
        // IRC messages end in \x0D\x0A, but some non-compliant servers only use \x0A during the connecting phase
        chatConnection?.readDataToData(GCDAsyncSocket.LFData(), withTimeout: -1, tag: 0)
    }
    
    private func processIncomingMessage(data : NSData, fromServer : Bool) {

        if var messageString = String(data: data, encoding: NSUTF8StringEncoding) {
            //TODO(Olivier): Check if line ending causes problems
            //const char *line = (const char *)[data bytes];
            //            NSUInteger len = data.length;
            //            const char *end = line + len - 2; // minus the line endings
            //
            //            if( *end != '\x0D' )
            //            end = line + len - 1; // this server only uses \x0A for the message line ending, lets work with it
            var currentIndex = 0
            let len = messageString.characters.count
            var sender : String?
            var user : String?
            var host : String?
            var command : String?
            var intentOrTags : String?
            var parameters = [String]()
            
            var done : Bool = false
            
            func checkAndMarkIfDone() { if currentIndex == len - 1 { done = true } }
            func consumeWhitespace() { while(messageString[currentIndex] == " " && currentIndex != len - 1 && !done) { currentIndex++ } }
            func notEndOfLine() -> Bool { return currentIndex != len - 1 && !done }
            
            if len > 2 {
                if notEndOfLine() {
                    if messageString[currentIndex] == "@" {
                        let startIndex = currentIndex++
                        while notEndOfLine() && messageString[currentIndex] != " " { currentIndex++ }
                        let endIndex = currentIndex
                        
                        intentOrTags = messageString[startIndex...endIndex]
                        checkAndMarkIfDone()
                        consumeWhitespace()
                    }
                }
                
                if notEndOfLine() && messageString[currentIndex] == ":" {
                    // prefix: ':' <sender> [ '!' <user> ] [ '@' <host> ] ' ' { ' ' }
                    let senderStartIndex = currentIndex++
                    while notEndOfLine() &&
                        messageString[currentIndex] != " " &&
                        messageString[currentIndex] != "!" &&
                        messageString[currentIndex] != "@"
                        { currentIndex++ }
                    let senderEndIndex = currentIndex
                    
                    sender = messageString[senderStartIndex...senderEndIndex]
                    checkAndMarkIfDone()
                    
                    if !done && messageString[currentIndex] != "!" {
                        let userStartIndex = currentIndex++
                        while notEndOfLine() &&
                            messageString[currentIndex] != " " &&
                            messageString[currentIndex] != "@"
                            { currentIndex++ }
                        let userEndIndex = currentIndex
                        
                        user = messageString[userStartIndex...userEndIndex]
                        checkAndMarkIfDone()
                    }
                    
                    if !done && messageString[currentIndex] != "@" {
                        let hostStartIndex = currentIndex++
                        while notEndOfLine() && messageString[currentIndex] != " " { currentIndex++ }
                        let hostEndIndex = currentIndex
                        
                        host = messageString[hostStartIndex...hostEndIndex]
                        checkAndMarkIfDone()
                    }
                    
                    if !done { currentIndex++ }
                    consumeWhitespace()
                }
                
                if notEndOfLine() {
                    // command: <letter> { <letter> } | <number> <number> <number>
                    // letter: 'a' ... 'z' | 'A' ... 'Z'
                    // number: '0' ... '9'
                    let cmdStartIndex = currentIndex
                    while notEndOfLine() && messageString[currentIndex] != " " { currentIndex++ }
                    let cmdEndIndex = currentIndex
                    
                    command = messageString[cmdStartIndex...cmdEndIndex]
                    
                    checkAndMarkIfDone()
                    if !done { currentIndex++ }
                    consumeWhitespace()
                }
                
                while notEndOfLine() {
                    // params: [ ':' <trailing data> | <letter> { <letter> } ] [ ' ' { ' ' } ] [ <params> ]
                    var currentParameter : String?
                    
                    if messageString[currentIndex] == ":" {
                        let currentParamStartIndex = currentIndex++
                        
                        currentParameter = messageString[currentParamStartIndex...len - 1]
                    }
                    else {
                        let currentParamStartIndex = currentIndex
                        while notEndOfLine() && messageString[currentIndex] != " " { currentIndex++ }
                        let currentParamEndIndex = currentIndex
                        
                        currentParameter = messageString[currentParamStartIndex...currentParamEndIndex]
                        
                        checkAndMarkIfDone()
                        if !done { currentIndex++ }
                    }
                    
                    if let param = currentParameter as String! {
                        parameters.append(param)
                    }
                    
                    consumeWhitespace()
                }
            }
            
            var intentOrTagDict = [String : String]()
            
            for anItentOrTag in intentOrTags!.componentsSeparatedByString(";") {
                let intentOrTagPair = anItentOrTag.componentsSeparatedByString("=")
                
                if intentOrTagPair.count != 2 { continue }
                
                intentOrTagDict[intentOrTagPair[0]] = intentOrTagPair[1]
            }
            //[[NSNotificationCenter chatCenter] postNotificationOnMainThreadWithName:MVChatConnectionGotRawMessageNotification object:self userInfo:@{ @"message": rawString, @"messageData": data, @"sender": (senderString ?: @""), @"command": (commandString ?: @""), @"parameters": parameters, @"outbound": @(NO), @"fromServer": @(fromServer), @"message-tags": intentOrTagsDictionary }]
            
            if let handler = commandHandlers[command!] {
                handler(sender: sender, user: user, host: host, command: command, intentOrTags: intentOrTagDict, parameters: parameters)
            }
            
            pingServerAfterInterval()
        }
        else {
            //Could not convert data to utf8 string
        }
    }
}

////////////////////////////////////////
// MARK - GCDAsyncSocketDelegate protocol
////////////////////////////////////////

extension IRCConnection : GCDAsyncSocketDelegate {
    @objc
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {

        sendEndCapabilityCommandAfterTimeout()
        
        let capabilitiesCommand = capabilities!.getIRCCommandString()
        if let cmd = capabilitiesCommand as String! {
            sendStringMessage(cmd, immedtiately: true)
        }
        
        if credentials?.password?.characters.count > 0 {
            sendStringMessage("PASS \(credentials?.password)", immedtiately: true)
        }
        
        sendStringMessage("NICK \(credentials?.nick)", immedtiately: true)
        //TODO(Olivier): In with twitch we don't deal with the USER ... command. Implement it if necessary
        //[self sendRawMessageImmediatelyWithFormat:@"USER %@ 0 * :%@", username, ( _realName.length ? _realName : @"Anonymous User" )];
        
        dispatch_async(dispatch_get_main_queue(), {
            self.didConnect()
        })

        pingServerAfterInterval()

        readNextMessageFromServer()
    }
    
    @objc
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        processIncomingMessage(data, fromServer: true)
        readNextMessageFromServer()
    }
    
    @objc
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        
        if sock != chatConnection { return }
        
        lastError = err
        
        dispatch_async(dispatch_get_main_queue(), {
            self.stopSendQueue()
        })
        
        dispatch_semaphore_wait(sendQueueLock, DISPATCH_TIME_FOREVER)
        self.sendQueue.removeAll()
        dispatch_semaphore_signal(sendQueueLock)
        
        if status == .Connecting {
            if lastError == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.didNotConnect()
                })
            }
        }
        else {
            if lastError != nil && status != .Disconnected {
                status = .Disconnected
                dispatch_async(dispatch_get_main_queue(), {
                    self.didDisconnect()
                })
            }
        }
    }
}