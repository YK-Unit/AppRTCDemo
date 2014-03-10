//
//  RTCVideoView.m
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-3-5.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import "RTCVideoView.h"
#import "RTCVideoRenderer.h"

@interface RTCVideoView()
@property (nonatomic, strong) UIView<RTCVideoRenderView> *videoRenderView;
@property (nonatomic, strong) RTCVideoRenderer *videoRenderer;
@property (nonatomic, strong) RTCVideoTrack *videoTrack;
@end

@implementation RTCVideoView
@synthesize videoRenderView,videoRenderer,videoTrack;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor lightGrayColor]];

        CGRect renderViewFrame = CGRectMake(0, 0, 320, 240);
        self.videoRenderView = [RTCVideoRenderer newRenderViewWithFrame:renderViewFrame];
        self.videoRenderer = [[RTCVideoRenderer alloc] initWithRenderView:[self videoRenderView]];
        [self addSubview:self.videoRenderView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)pause:(id)sender {
    [self.videoRenderer stop];
}

-(void)resume:(id)sender {
    [self.videoRenderer start];
}

- (void)stop:(id)sender {
    [self.videoRenderer stop];
    [self.videoTrack removeRenderer:self.videoRenderer];
    self.videoTrack = nil;
}

- (void)stopRender
{
    [self stop:nil];
}

- (void)renderVideoTrackInterface:(RTCVideoTrack *)_videoTrack {
    if (self.videoTrack) {
        [self stop:nil];
    }
    
    self.videoTrack = _videoTrack;
    
    if (self.videoTrack && self.videoRenderer) {
        [self.videoTrack addRenderer:self.videoRenderer];
        [self resume:self];
        EASYLogInfo(@"start render video...");
    }
}

@end
