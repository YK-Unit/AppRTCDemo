//
//  RTCVideoView.h
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-3-5.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTCVideoTrack.h"

@interface RTCVideoView : UIView
- (void)stopRender;
- (void)renderVideoTrackInterface:(RTCVideoTrack *)track;
@end
