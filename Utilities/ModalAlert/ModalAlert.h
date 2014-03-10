/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface ModalAlert : NSObject
+ (NSDictionary *) ask: (NSString *)question withKeyborType:(UIKeyboardType)type withPlaceHolder:(NSString *)placeholder withDefaultText:(NSString *)defaultText;
+ (NSString *) ask: (NSString *) question withKeyborType:(UIKeyboardType)type withTextPrompt: (NSString *) prompt;
+ (NSUInteger) ask: (NSString *) question withCancel: (NSString *) cancelButtonTitle withButtons: (NSArray *) buttons;
+ (void) say: (id)formatstring,...;
+ (BOOL) ask: (id)formatstring,...;
+ (BOOL) confirm: (id)formatstring,...;
+ (NSArray *) ask:(NSString *)question withKeyborType:(UIKeyboardType)type withTextPrompt:(NSString *)prompt  withOtherKeyborType:(UIKeyboardType)otherType withOtherTextPrompt:(NSString *)otherPrompt;

@end
