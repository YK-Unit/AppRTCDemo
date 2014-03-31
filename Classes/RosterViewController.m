//
//  RosterViewController.m
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-2-26.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import "RosterViewController.h"
#import "LoginViewController.h"
#import "ModalAlert.h"
#import "RTCMediaStream.h"

@interface RosterViewController ()
- (void)doLogout;
- (void)addVideoView;
- (void)removeVideoView;
- (void)doStopRTCTask;
@end

@implementation RosterViewController
@synthesize rtcVideoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"AppRTCDemo";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(doLogout)];
    self.navigationItem.leftBarButtonItem = logoutItem;
    
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    
    [RTCWorker sharedInstance].delegate = self;
    [XMPPWorker sharedInstance].signalingDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![XMPPWorker sharedInstance].isXmppConnected) {
        self.navigationItem.title = [XMPPWorker sharedInstance].userName;
        
        [[XMPPWorker sharedInstance] connect];
        
        [[[XMPPWorker sharedInstance] fetchedResultsController_roster] setDelegate:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[XMPPWorker sharedInstance] disconnect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doLogout
{
    [[XMPPWorker sharedInstance] disconnect];
    
    LoginViewController *loginVC = [[LoginViewController alloc] initWithHandler:^(NSString *jid,NSString *pwd,NSString *hostName){
        
        [[XMPPWorker sharedInstance] setUserName:jid];
        [[XMPPWorker sharedInstance] setUserPwd:pwd];
        if (hostName) {
            [[XMPPWorker sharedInstance] setHostName:hostName];
        }
    }];
    [self.navigationController presentViewController:loginVC animated:YES completion:NULL];
}

- (void)doStopRTCTask
{
    [[RTCWorker sharedInstance] stopRTCTaskAsInitiator:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController
{
	return [[XMPPWorker sharedInstance] fetchedResultsController_roster];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate,
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
		{
			case 0  : return @"Available";
			case 1  : return @"Away";
			default : return @"Offline";
		}
	}
	
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
	}
	
	XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	cell.textLabel.text = user.displayName;
    
	[self configurePhotoForCell:cell user:user];
	
    NSInteger state = [user.sectionNum integerValue];
    if (state == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
	return cell;
}

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	
	if (user.photo != nil)
	{
		cell.imageView.image = user.photo;
	}
	else
	{
		NSData *photoData = [[[XMPPWorker sharedInstance] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
			cell.imageView.image = [UIImage imageWithData:photoData];
		else
			cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSInteger state = [user.sectionNum integerValue];
    if (state == 0) {
        [self performSelectorOnMainThread:@selector(doDealWithSelectionAtIndex:) withObject:indexPath waitUntilDone:NO];
    }
}

- (void)doDealWithSelectionAtIndex:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    BOOL flag = [ModalAlert ask:[NSString stringWithFormat:@"to have RTC with %@?",user.displayName]];
    if (flag) {
        NSString *bareJID = [user.jid bare];
        [[RTCWorker sharedInstance] startRTCTaskAsInitiator:YES withTarget:bareJID];
    }
}

#pragma mark - RTCWorkerDelegate
- (void)rtcWorker:(RTCWorker *)sender sendSignalingMessage:(NSString *)message toUser:(NSString *)user
{
    [[XMPPWorker sharedInstance] sendSignalingMessage:message toUser:user];
}

- (void)rtcWorkerDidStartRTCTask:(RTCWorker *)sender
{
    [self addVideoView];
    
    UIBarButtonItem *stopItem = [[UIBarButtonItem alloc]initWithTitle:@"StopRTC" style:UIBarButtonItemStylePlain target:self action:@selector(doStopRTCTask)];
    self.navigationItem.rightBarButtonItem = stopItem;

}

- (void)rtcWorker:(RTCWorker *)sender didReceiveRemoteStream:(RTCMediaStream *)stream
{
    NSAssert([stream.audioTracks count] >= 1,
             @"Expected at least 1 audio stream");
    
    NSAssert([stream.videoTracks count] >= 1,
             @"Expected at least 1 video stream");
    
    if ([stream.videoTracks count] > 0) {
        [self.rtcVideoView renderVideoTrackInterface:[stream.videoTracks objectAtIndex:0]];
    }
}

- (void)rtcWorkerDidStopRTCTask:(RTCWorker *)sender
{
    [self removeVideoView];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)rtcWorkerDidReceiveRTCTaskRequest:(RTCWorker *)sender fromUser:(NSString *)bareJID
{
    [self performSelectorOnMainThread:@selector(doDealWithRTCRequestFromUser:) withObject:bareJID waitUntilDone:NO];
}

- (void)doDealWithRTCRequestFromUser:(NSString *)bareJID
{
    BOOL flag = [ModalAlert ask:[NSString stringWithFormat:@"to accept RTC request from %@?",bareJID]];
    
    if (flag) {
        [[RTCWorker sharedInstance] startRTCTaskAsInitiator:NO withTarget:bareJID];
    }else{
        NSDictionary *jsonDict = @{ @"type" : @"bye"};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSAssert(!error,@"%@",[NSString stringWithFormat:@"Error: %@", error.description]);
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        //TODO:To Decouple
        [[XMPPWorker sharedInstance] sendSignalingMessage:jsonStr toUser:bareJID];
    }
}

#pragma mark - XMPPWorkerSignalingDelegate
- (void)xmppWorker:(XMPPWorker *)sender didReceiveSignalingMessage:(XMPPMessage *)message
{
    if ([message isMessageWithBody]) {
        NSString *fromUser = [[message from] bare];
        NSString *signalingMessage = [message body];
        
        [[RTCWorker sharedInstance] processSignalingMessage:signalingMessage fromUser:fromUser];
    }
}

#pragma mark - RTCVideoView
- (void)addVideoView
{
    self.rtcVideoView = [[RTCVideoView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.rtcVideoView];
}

- (void)removeVideoView
{
    [self.rtcVideoView stopRender];
    [self.rtcVideoView removeFromSuperview];
    self.rtcVideoView = nil;
}
@end
