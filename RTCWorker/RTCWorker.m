//
//  RTCWorker.m
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-2-26.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import "RTCWorker.h"
#import "RTCICEServer.h"
#import "RTCICECandidate.h"
#import "RTCICEServer.h"
#import "RTCMediaConstraints.h"
#import "RTCMediaStream.h"
#import "RTCPair.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCSessionDescription.h"
#import "RTCVideoRenderer.h"
#import "RTCVideoCapturer.h"
#import "RTCVideoTrack.h"

#import <AVFoundation/AVFoundation.h>

@interface RTCWorker()
@property(nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property(nonatomic, strong) RTCMediaConstraints *pcConstraints;
@property(nonatomic, strong) RTCMediaConstraints *sdpConstraints;
@property(nonatomic, strong) RTCMediaConstraints *videoConstraints;
@property(nonatomic, strong) NSMutableArray *queuedSignalingMessages;
@property(nonatomic, strong) RTCPeerConnection *peerConnection;
@property(nonatomic, strong) RTCVideoCapturer *localVideoCapture;
@property(nonatomic, strong) RTCVideoSource *localVideoSource;
@property(nonatomic, strong) RTCVideoTrack *localVideoTrack;
@property(nonatomic, strong) RTCAudioTrack *localAudioTrack;
@property(nonatomic, assign) BOOL hasCreatedPeerConnection;

- (NSArray *)getLastICEServers;
- (void)processSignalingMessage:(NSString *)message;
- (void)callerStart;
- (void)calleeStart;

//Utility Methods for RTCSessionDescripton
+ (NSString *)firstMatch:(NSRegularExpression *)pattern
              withString:(NSString *)string;
+ (NSString *)preferISAC:(NSString *)origSDP;
@end

@implementation RTCWorker
@synthesize rtcTarget;
@synthesize isInitiator;
@synthesize delegate;
@synthesize peerConnectionFactory,peerConnection;
@synthesize pcConstraints,sdpConstraints,videoConstraints;
@synthesize queuedSignalingMessages;
@synthesize localVideoCapture,localVideoSource,localVideoTrack,localAudioTrack;
@synthesize hasCreatedPeerConnection;

+ (RTCWorker *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static RTCWorker *_sharedRTCWorker = nil;
    dispatch_once(&pred, ^{
        _sharedRTCWorker = [[self alloc] init];
    });
    return _sharedRTCWorker;
}

- (id)init
{
    self = [super init];
    if (self) {
        rtcTarget = Nil;
    }
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - public methods
- (void)startEngine
{
    [RTCPeerConnectionFactory initializeSSL];
    
    self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];

    self.queuedSignalingMessages = [NSMutableArray array];
    
    
    //set RTCPeerConnection's constraints
    //TODO:FindBug-when DtlsSrtpKeyAgreement=true,can't push down offer/answer SDP
    self.pcConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@[[[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"], [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]] optionalConstraints:@[[[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"false"]]];
    
    
    //set SDP's(offer/answer) Constraints
    self.sdpConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@[[[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"], [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]] optionalConstraints:nil];
    
    
    //set RTCVideoSource's(localVideoSource) constraints
    RTCPair *maxAspectRatio = [[RTCPair alloc] initWithKey:@"maxAspectRatio" value:@"4:3"];
    
    //when maxWidth=640,maxHeight=480,the video transmission is slow
    RTCPair *maxWidth = [[RTCPair alloc] initWithKey:@"maxWidth" value:@"320"];
    RTCPair *minWidth = [[RTCPair alloc] initWithKey:@"minWidth" value:@"160"];
    
    RTCPair *maxHeight = [[RTCPair alloc] initWithKey:@"maxHeight" value:@"240"];
    RTCPair *minHeight = [[RTCPair alloc] initWithKey:@"minHeight" value:@"120"];
    
    RTCPair *maxFrameRate = [[RTCPair alloc] initWithKey:@"maxFrameRate" value:@"30"];
    RTCPair *minFrameRate = [[RTCPair alloc] initWithKey:@"minFrameRate" value:@"24"];
    
    NSArray *mandatory = @[maxAspectRatio,maxWidth,minWidth,maxHeight,minHeight, maxFrameRate ,minFrameRate];
    self.videoConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory optionalConstraints:nil];
    
}

- (void)stopEngine
{    
    [RTCPeerConnectionFactory deinitializeSSL];

    [self.queuedSignalingMessages removeAllObjects];
    self.queuedSignalingMessages = nil;
    
    self.pcConstraints = nil;
    self.sdpConstraints = nil;
    self.videoConstraints = nil;
    
    self.peerConnectionFactory = nil;
}

- (BOOL)startRTCTaskAsInitiator:(BOOL)flag withTarget:(NSString *)targetJID
{
    isInitiator = flag;
    self.rtcTarget = targetJID;
    
    NSArray *servers = [self getLastICEServers];
    
    //TODO:FixBUG-[RTCPeerConnection updateICEServers:constraints] can't connect to TURN Server,BUT [RTCPeerConnectionFactory peerConnectionWithICEServers:constraints:delegate:] can!
    self.peerConnection = [self.peerConnectionFactory peerConnectionWithICEServers:servers constraints:self.pcConstraints delegate:self];
    self.hasCreatedPeerConnection = YES;
    
    EASYLogInfo(@"Adding Audio and Video devices ...");
    //setup local media stream
    RTCMediaStream *lms = [self.peerConnectionFactory mediaStreamWithLabel:@"ARDAMS"];
    
    //add local video track
    if (!self.localVideoCapture) {
        NSString *cameraID = nil;
        //** front camera
        for (AVCaptureDevice *captureDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] ) {
            if (!cameraID || captureDevice.position == AVCaptureDevicePositionFront) {
                cameraID = [captureDevice localizedName];
            }
        }
        self.localVideoCapture = [RTCVideoCapturer capturerWithDeviceName:cameraID];
    }
    if (!self.localVideoSource) {
        self.localVideoSource = [self.peerConnectionFactory videoSourceWithCapturer:self.localVideoCapture constraints:self.videoConstraints];
    }
    if (!self.localVideoTrack) {
        self.localVideoTrack = [self.peerConnectionFactory videoTrackWithID:@"ARDAMSv0" source:self.localVideoSource];
    }
    if (self.localVideoTrack) {
        [lms addVideoTrack:self.localVideoTrack];
    }
    
    //add local audio track
    if(!self.localAudioTrack){
        self.localAudioTrack = [self.peerConnectionFactory audioTrackWithID:@"ARDAMSa0"];
    }
    if(self.localAudioTrack){
        [lms addAudioTrack:self.localAudioTrack];
    }
    
    //add local stream
    [self.peerConnection addStream:lms constraints:self.pcConstraints];
    
    if (isInitiator) {
        [self callerStart];
    }else{
        [self calleeStart];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcWorkerDidStartRTCTask:)]) {
        [self.delegate rtcWorkerDidStartRTCTask:self];
    }
    return YES;
}

- (void)stopRTCTaskAsInitiator:(BOOL)flag
{
    if (self.peerConnection) {
        [self.queuedSignalingMessages removeAllObjects];
        
        [self.peerConnection close];
        self.peerConnection = nil;
        self.hasCreatedPeerConnection = NO;
        isInitiator = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(rtcWorkerDidStopRTCTask:)]) {
            [self.delegate rtcWorkerDidStopRTCTask:self];
        }
        
        if(flag){
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSDictionary *jsonDict = @{ @"type" : @"bye"};
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
                NSAssert(!error,@"%@",[NSString stringWithFormat:@"Error: %@", error.description]);
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                NSAssert(rtcTarget != Nil, @"rtcTarget can't be nil");
                if (self.delegate && [self.delegate respondsToSelector:@selector(rtcWorker:sendSignalingMessage:toUser:)]) {
                    [self.delegate rtcWorker:self sendSignalingMessage:jsonStr toUser:rtcTarget];
                }

            });
        }
    }
}

- (void)processSignalingMessage:(NSString *)message fromUser:(NSString *)from
{
    //TODO:code to JUST process signaling from rtcTarget(jidFrom==rtcTarget)
    NSString *jidFrom = from;
    NSString *jsonStr = message;
    if (!jidFrom || !jsonStr) {
        return;
    }
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSAssert(!error,@"%@",[NSString stringWithFormat:@"Error: %@", error.description]);
    NSString *type = [jsonDict objectForKey:@"type"];
    
    if (!isInitiator && !hasCreatedPeerConnection) {
        if ([type compare:@"offer"] == NSOrderedSame) {
            [self.queuedSignalingMessages insertObject:jsonStr atIndex:0];
            
            //TODO:ChangeIt-NOW FOR CONVENIENCE we assume that we ONLY have a targetJID. When have more targetJIDs, we should change it
            if (self.delegate && [self.delegate respondsToSelector:@selector(rtcWorkerDidReceiveRTCTaskRequest:fromUser:)]) {
                [self.delegate rtcWorkerDidReceiveRTCTaskRequest:self fromUser:jidFrom];
            }
        }else{
            [self.queuedSignalingMessages addObject:jsonStr];
        }
    }else{
        [self processSignalingMessage:jsonStr];
    }
    
}

#pragma mark - private methods
- (NSArray *)getLastICEServers
{

    NSMutableArray *ICEServers = [NSMutableArray array];

#warning - set yourself STUN/TURN servers.\
           If have none, you ONLY have p2p RTC in the SAME LAN
    //if you have a TURN server ,then add it to ICEServers like this
    /*
    NSString *url = @"turn:192.168.10.10:3478";
    NSString *username = @"name";
    NSString *credential = @"pwd";
    
    RTCICEServer *ICEServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:url]username:username password:credential];
    [ICEServers addObject:ICEServer];
    */
    
    return ICEServers;
}

- (void)callerStart
{
    //create offer
    [self.peerConnection createOfferWithDelegate:self constraints:self.sdpConstraints];
    EASYLogInfo(@"create offer ...");
}

- (void)calleeStart
{
    for (int i = 0; i < [self.queuedSignalingMessages count]; i++) {
        NSString *message = [self.queuedSignalingMessages objectAtIndex:i];
        [self processSignalingMessage:message];
    }
    [self.queuedSignalingMessages removeAllObjects];
}

- (void)processSignalingMessage:(NSString *)message
{
    if (!hasCreatedPeerConnection) {
        EASYLogError(@"has NOT created peerConnection...");
        return;
    }
    
    NSString *jsonStr = message;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSAssert(!error,@"%@",[NSString stringWithFormat:@"Error: %@", error.description]);
    NSString *type = [jsonDict objectForKey:@"type"];
    if ([type compare:@"offer"] == NSOrderedSame) {
        NSString *sdpString = [jsonDict objectForKey:@"sdp"];
        RTCSessionDescription *sdp = [[RTCSessionDescription alloc]
                                      initWithType:type sdp:[RTCWorker preferISAC:sdpString]];
        [self.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdp];
        
        //create answer
        [self.peerConnection createAnswerWithDelegate:self constraints:self.sdpConstraints];
        EASYLogInfo(@"crate answer ...");
        
    }else if ([type compare:@"answer"] == NSOrderedSame) {
        NSString *sdpString = [jsonDict objectForKey:@"sdp"];
        RTCSessionDescription *sdp = [[RTCSessionDescription alloc]
                                      initWithType:type sdp:[RTCWorker preferISAC:sdpString]];
        [self.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdp];
        
    }else if ([type compare:@"candidate"] == NSOrderedSame) {
        NSString *mid = [jsonDict objectForKey:@"id"];
        NSNumber *sdpLineIndex = [jsonDict objectForKey:@"label"];
        NSString *sdp = [jsonDict objectForKey:@"candidate"];
        RTCICECandidate *candidate =
        [[RTCICECandidate alloc] initWithMid:mid
                                       index:sdpLineIndex.intValue
                                         sdp:sdp];
        
        [self.peerConnection addICECandidate:candidate];
        
    }else if ([type compare:@"bye"] == NSOrderedSame) {
        [self stopRTCTaskAsInitiator:NO];
    }
    
}

#pragma mark Utility Methods for RTCSessionDescripton
// Match |pattern| to |string| and return the first group of the first
// match, or nil if no match was found.
+ (NSString *)firstMatch:(NSRegularExpression *)pattern
              withString:(NSString *)string
{
    NSTextCheckingResult* result =
    [pattern firstMatchInString:string
                        options:0
                          range:NSMakeRange(0, [string length])];
    if (!result)
        return nil;
    return [string substringWithRange:[result rangeAtIndex:1]];
}

// Mangle |origSDP| to prefer the ISAC/16k audio codec.
+ (NSString *)preferISAC:(NSString *)origSDP
{
    int mLineIndex = -1;
    NSString* isac16kRtpMap = nil;
    NSArray* lines = [origSDP componentsSeparatedByString:@"\n"];
    NSRegularExpression* isac16kRegex = [NSRegularExpression
                                         regularExpressionWithPattern:@"^a=rtpmap:(\\d+) ISAC/16000[\r]?$"
                                         options:0
                                         error:nil];
    for (int i = 0;
         (i < [lines count]) && (mLineIndex == -1 || isac16kRtpMap == nil);
         ++i) {
        NSString* line = [lines objectAtIndex:i];
        if ([line hasPrefix:@"m=audio "]) {
            mLineIndex = i;
            continue;
        }
        isac16kRtpMap = [self firstMatch:isac16kRegex withString:line];
    }
    if (mLineIndex == -1) {
        NSLog(@"No m=audio line, so can't prefer iSAC");
        return origSDP;
    }
    if (isac16kRtpMap == nil) {
        NSLog(@"No ISAC/16000 line, so can't prefer iSAC");
        return origSDP;
    }
    NSArray* origMLineParts =
    [[lines objectAtIndex:mLineIndex] componentsSeparatedByString:@" "];
    NSMutableArray* newMLine =
    [NSMutableArray arrayWithCapacity:[origMLineParts count]];
    int origPartIndex = 0;
    // Format is: m=<media> <port> <proto> <fmt> ...
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:isac16kRtpMap];
    for (; origPartIndex < [origMLineParts count]; ++origPartIndex) {
        if ([isac16kRtpMap compare:[origMLineParts objectAtIndex:origPartIndex]]
            != NSOrderedSame) {
            [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex]];
        }
    }
    NSMutableArray* newLines = [NSMutableArray arrayWithCapacity:[lines count]];
    [newLines addObjectsFromArray:lines];
    [newLines replaceObjectAtIndex:mLineIndex
                        withObject:[newMLine componentsJoinedByString:@" "]];
    return [newLines componentsJoinedByString:@"\n"];
}

#pragma mark - RTCPeerConnectionDelegate
// Triggered when there is an error.
- (void)peerConnectionOnError:(RTCPeerConnection *)peerConnection
{
	EASYLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

// Triggered when the SignalingState changed.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
 signalingStateChanged:(RTCSignalingState)stateChanged
{
	EASYLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

}

// Triggered when media is received on a new stream from remote peer.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
           addedStream:(RTCMediaStream *)stream
{
	EASYLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    dispatch_async(dispatch_get_main_queue(), ^(void) {
    
        if(self.delegate && [self.delegate respondsToSelector:@selector(rtcWorker:didReceiveRemoteStream:)]){
            [self.delegate rtcWorker:self didReceiveRemoteStream:stream];
        }
    });
}

// Triggered when a remote peer close a stream.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
         removedStream:(RTCMediaStream *)stream
{
	EASYLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [stream removeVideoTrack:[stream.videoTracks objectAtIndex:0]];
}

// Triggered when renegotation is needed, for example the ICE has restarted.
- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{
	EASYLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

// Called any time the ICEConnectionState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
  iceConnectionChanged:(RTCICEConnectionState)newState
{
	EASYLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

// Called any time the ICEGatheringState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState
{
	EASYLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

// New Ice candidate have been found.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate
{
	EASYLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    NSDictionary *jsonDict =
    @{ @"type" : @"candidate",
       @"label" : [NSNumber numberWithInt:candidate.sdpMLineIndex],
       @"id" : candidate.sdpMid,
       @"candidate" : candidate.sdp };
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    if (!error) {
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        EASYLogInfo(@"candidate:%@",jsonStr);
        
        NSAssert(rtcTarget != Nil, @"rtcTarget can't be nil");
        if (self.delegate && [self.delegate respondsToSelector:@selector(rtcWorker:sendSignalingMessage:toUser:)]) {
            [self.delegate rtcWorker:self sendSignalingMessage:jsonStr toUser:rtcTarget];
        }
    } else {
        NSAssert(NO, @"Unable to serialize JSON object with error: %@",
                 error.localizedDescription);
    }
}

#pragma mark - RTCSessionDescriptonDelegate
// Called when creating a session.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didCreateSessionDescription:(RTCSessionDescription *)origSdp
                 error:(NSError *)error
{
	EASYLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    if (error) {
        NSAssert(NO, error.description);
        return;
    }
    
    RTCSessionDescription* sdp = [[RTCSessionDescription alloc] initWithType:origSdp.type sdp:[RTCWorker preferISAC:origSdp.description]];
    [self.peerConnection setLocalDescriptionWithDelegate:self
                                      sessionDescription:sdp];

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSDictionary *jsonDict = @{ @"type" : sdp.type, @"sdp" : sdp.description };
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSAssert(!error,@"%@",[NSString stringWithFormat:@"Error: %@", error.description]);
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        EASYLogInfo(@"SDP:%@",jsonStr);

        NSAssert(rtcTarget != Nil, @"rtcTarget can't be nil");
        if (self.delegate && [self.delegate respondsToSelector:@selector(rtcWorker:sendSignalingMessage:toUser:)]) {
            [self.delegate rtcWorker:self sendSignalingMessage:jsonStr toUser:rtcTarget];
        }
    });
}

// Called when setting a local or remote description.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didSetSessionDescriptionWithError:(NSError *)error
{
    EASYLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if (error) {
        NSAssert(NO, error.description);
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // TODO(hughv): Handle non-initiator case.  http://s10/46622051
        if (self.peerConnection.remoteDescription) {
            EASYLogVerbose(@"SDP onSuccess - drain candidates");
            //[self drainRemoteCandidates];
        } else {
            EASYLogVerbose(@"*** self.peerConnection.remoteDescription is NULL");
        }
    });
}

@end
