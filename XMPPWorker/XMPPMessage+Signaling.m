//
//  XMPPMessage+Signaling.m
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-2-26.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import "XMPPMessage+Signaling.h"
#define TYPE_SIGNALING      @"signaling"


@implementation XMPPMessage (Signaling)

+ (XMPPMessage *)signalingMessageTo:(XMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement *)childElement
{
    return [[XMPPMessage alloc] initSignalingMessageTo:jid elementID:eid child:childElement];
}

- (id)initSignalingMessageTo:(XMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement*)childElement
{
    return [[XMPPMessage alloc] initWithType:TYPE_SIGNALING to:jid elementID:eid child:childElement];
}

- (BOOL)isSignalingMessage
{
	return [[[self attributeForName:@"type"] stringValue] isEqualToString:TYPE_SIGNALING];
}
- (BOOL)isSignalingMessageWithBody
{
    if ([self isSignalingMessage])
	{
		return [self isMessageWithBody];
	}
	
	return NO;
}

@end
