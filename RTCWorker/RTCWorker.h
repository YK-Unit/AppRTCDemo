//
//  RTCWorker.h
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-2-26.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCSessionDescriptonDelegate.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCVideoTrack.h"
@protocol RTCWorkerDelegate;

@interface RTCWorker : NSObject
<RTCPeerConnectionDelegate,RTCSessionDescriptonDelegate,XMPPWorkerSignalingDelegate>
{
    NSString *rtcTarget;
    BOOL isInitiator;
    __weak id<RTCWorkerDelegate> delegate;

}
@property (nonatomic, copy) NSString *rtcTarget;
@property (nonatomic, assign) BOOL isInitiator;
@property (nonatomic, weak) id<RTCWorkerDelegate> delegate;

+ (RTCWorker *)sharedInstance;
/*
 best to run it IN THIS ORDER
 startEngine ➝ [startRTCTask ⇄ stopRTCTask] ➝ stopEngine
 */
- (void)startEngine;
- (void)stopEngine;
- (BOOL)startRTCTaskAsInitiator:(BOOL)flag withTarget:(NSString *)targetJID;
- (void)stopRTCTaskAsInitiator:(BOOL)flag;
@end

@protocol RTCWorkerDelegate <NSObject>
@optional
- (void)rtcWorkerDidStartRTCTask:(RTCWorker *)sender;
- (void)rtcWorker:(RTCWorker *)sender onRenderVideoTrackInterface:(RTCVideoTrack *)videoTrack;
- (void)rtcWorker:(RTCWorker *)sender didReceiveRemoteStream:(RTCMediaStream *)stream;
- (void)rtcWorkerDidStopRTCTask:(RTCWorker *)sender;
- (void)rtcWorkerDidReceiveRTCTaskRequest:(RTCWorker *)sender fromUser:(NSString *)bareJID;
@end

