//
//  RosterViewController.h
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-2-26.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RTCVideoView.h"

@interface RosterViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,RTCWorkerDelegate,XMPPWorkerSignalingDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) RTCVideoView *rtcVideoView;
@end
