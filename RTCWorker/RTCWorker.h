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

@protocol RTCWorkerDelegate;

@interface RTCWorker : NSObject
<RTCPeerConnectionDelegate,RTCSessionDescriptonDelegate>
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
- (void)processSignalingMessage:(NSString *)message fromUser:(NSString *)from;
@end

@protocol RTCWorkerDelegate <NSObject>
@required
- (void)rtcWorker:(RTCWorker *)sender sendSignalingMessage:(NSString *)message toUser:(NSString *)user;
@optional
- (void)rtcWorkerDidStartRTCTask:(RTCWorker *)sender;
- (void)rtcWorker:(RTCWorker *)sender didReceiveRemoteStream:(RTCMediaStream *)stream;
- (void)rtcWorkerDidReceiveRTCTaskRequest:(RTCWorker *)sender fromUser:(NSString *)bareJID;
- (void)rtcWorkerDidStopRTCTask:(RTCWorker *)sender;
@end

