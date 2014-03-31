//
//  XMPPWorker.h
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-2-25.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"

@protocol XMPPWorkerSignalingDelegate;

@interface XMPPWorker : NSObject
<XMPPStreamDelegate,XMPPRosterDelegate>
{
    NSString *hostName;
    UInt16 hostPort;
    BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
    
    NSString *userName;
    NSString *userPwd;
    
    BOOL isXmppConnected;
    BOOL isEngineRunning;
    
    __weak id<XMPPWorkerSignalingDelegate> signalingDelegate;
    
    XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    NSFetchedResultsController *fetchedResultsController_roster;
}
@property (nonatomic,copy) NSString *hostName;
@property (nonatomic,assign) UInt16 hostPort;
@property (nonatomic,assign) BOOL allowSelfSignedCertificates;
@property (nonatomic,assign) BOOL allowSSLHostNameMismatch;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *userPwd;
@property (nonatomic,assign) BOOL isXmppConnected;
@property (nonatomic,assign) BOOL isEngineRunning;
@property (nonatomic,weak) id<XMPPWorkerSignalingDelegate> signalingDelegate;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController_roster;



+ (XMPPWorker *)sharedInstance;

/*
best to run it IN THIS ORDER
startEngine ➝ [connect ⇄ disconnect] ➝ stopEngine
 */
- (void)startEngine;
- (void)stopEngine;
- (BOOL)connect;
- (void)disconnect;

- (void)sendSignalingMessage:(NSString *)message toUser:(NSString *)jidStr;
@end


@protocol XMPPWorkerSignalingDelegate <NSObject>
@required
// Called when receive a signaling message.
- (void)xmppWorker:(XMPPWorker *)sender didReceiveSignalingMessage:(XMPPMessage *)message;
@end
