//
//  LoginViewController.h
//  AppRTCDemo
//
//  Created by zhang zhiyu on 14-2-26.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
@protected
    id _handler;
}
@property (weak, nonatomic) IBOutlet UITextField *jidField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UITextField *hostNameField;
- (IBAction)doLogin:(id)sender;
- (id)initWithHandler:(void(^)(NSString *jid,NSString *pwd,NSString *hostName))handler;

@end
