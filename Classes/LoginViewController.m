//
//  LoginViewController.m
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-2-26.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import "LoginViewController.h"
#import "ModalAlert.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithHandler:(void (^)(NSString *, NSString *, NSString *))handler
{
    self = [self init];
    
    if (self) {
        _handler = [handler copy];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (_handler) {
        _handler = Nil;
    }
}

- (IBAction)doLogin:(id)sender {
    NSString *jid = self.jidField.text;
    NSString *pwd = self.pwdField.text;
    NSString *hostName = self.hostNameField.text;
    if (jid && pwd) {
        if (_handler) {
            ((void(^)(NSString *,NSString *,NSString *))_handler)(jid,pwd,hostName);
            [self dismissViewControllerAnimated:YES completion:Nil];
        }
    }
}
@end
