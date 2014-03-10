//
//  XMPPMessage+Signaling.h
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-2-26.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import "XMPPMessage.h"

@interface XMPPMessage (Signaling)
+ (XMPPMessage *)signalingMessageTo:(XMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement *)childElement;
- (id)initSignalingMessageTo:(XMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement*)childElement;

- (BOOL)isSignalingMessage;
- (BOOL)isSignalingMessageWithBody;
@end
