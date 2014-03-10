/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

/*
 Thanks to Kevin Ballard for suggesting the UITextField as subview approach
 All credit to Kenny TM. Mistakes are mine. 
 To Do: Ensure that only one runs at a time -- is that possible?
 */

#import "ModalAlert.h"
#import <stdarg.h>

#define TEXT_FIELD_TAG	9999
#define OTHER_TEXT_FIELD_TAG  9998

#define IS_IOS_5Plus  ([[UIDevice currentDevice].systemVersion doubleValue] >= 5.0f)


@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate, UITextFieldDelegate> 
{
	CFRunLoopRef currentLoop;
	NSString *text;
	NSUInteger index;
    
    NSString *otherText;
}
@property (assign) NSUInteger index;
@property (retain) NSString *text;
@property (retain) NSString *otherText;
@end

@implementation ModalAlertDelegate
@synthesize index;
@synthesize text;
@synthesize otherText;

-(id) initWithRunLoop: (CFRunLoopRef)runLoop 
{
	if (self = [super init]) currentLoop = runLoop;
	return self;
}

// User pressed button. Retrieve results
/*
-(void)alertView:(UIAlertView*)aView clickedButtonAtIndex:(NSInteger)anIndex 
{
    UITextField *tf = nil;
    UITextField *other_tf = nil;
    
    if (IS_IOS_5Plus) {
        if (aView.alertViewStyle == UIAlertViewStylePlainTextInput) {
            tf = (UITextField *)[aView textFieldAtIndex:0];
        }else if(aView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput){
            tf = (UITextField *)[aView textFieldAtIndex:0];
            other_tf = (UITextField *)[aView textFieldAtIndex:1];
        }
    }else{
    	tf = (UITextField *)[aView viewWithTag:TEXT_FIELD_TAG];
        other_tf = (UITextField *)[aView viewWithTag:OTHER_TEXT_FIELD_TAG];
    }
    
	if (tf) self.text = tf.text;
	self.index = anIndex;
    
    if (other_tf) {
        self.otherText = other_tf.text;
    }
    
	CFRunLoopStop(currentLoop);
}
*/

- (void)alertView:(UIAlertView *)aView didDismissWithButtonIndex:(NSInteger)anIndex
{
    UITextField *tf = nil;
    UITextField *other_tf = nil;
    
    if (IS_IOS_5Plus) {
        if (aView.alertViewStyle == UIAlertViewStylePlainTextInput) {
            tf = (UITextField *)[aView textFieldAtIndex:0];
        }else if(aView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput){
            tf = (UITextField *)[aView textFieldAtIndex:0];
            other_tf = (UITextField *)[aView textFieldAtIndex:1];
        }
    }else{
    	tf = (UITextField *)[aView viewWithTag:TEXT_FIELD_TAG];
        other_tf = (UITextField *)[aView viewWithTag:OTHER_TEXT_FIELD_TAG];
    }
    
	if (tf) self.text = tf.text;
	self.index = anIndex;
    
    if (other_tf) {
        self.otherText = other_tf.text;
    }
    
	CFRunLoopStop(currentLoop);
}

- (BOOL) isLandscape
{
	return ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) || ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight);
}

// Move alert into place to allow keyboard to appear
- (void) moveAlert: (UIAlertView *) alertView
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	if (![self isLandscape])
		alertView.center = CGPointMake(160.0f, 180.0f);
	else 
		alertView.center = CGPointMake(240.0f, 90.0f);
	[UIView commitAnimations];
	
	[[alertView viewWithTag:TEXT_FIELD_TAG] becomeFirstResponder];
}

- (void) dealloc
{
	self.text = nil;
    self.otherText = nil;
	[super dealloc];
}

@end

@implementation ModalAlert

+ (NSUInteger) ask: (NSString *) question withCancel: (NSString *) cancelButtonTitle withButtons: (NSArray *) buttons
{
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	
	// Create Alert
	ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
    //this way to fix bug for ios7+.
    //the bug is:if otherButtonTitles is seted nil,then [alertView addButtonWithTitle:buttonTitle] from buttons,the view will be frozen

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:madelegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    for (int i = 0;i < [buttons count]; i++) {
        NSString *buttonTitle = [buttons objectAtIndex:i];
        [alertView addButtonWithTitle:buttonTitle];
    }
	[alertView show];
	
	// Wait for response
	CFRunLoopRun();
	
	// Retrieve answer
	NSUInteger answer = madelegate.index;
	[alertView release];
	[madelegate release];
	return answer;
}

+ (void) say: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	[ModalAlert ask:statement withCancel:@"YES" withButtons:nil];
	[statement release];
}

+ (BOOL) ask: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	BOOL answer = ([ModalAlert ask:statement withCancel:nil withButtons:[NSArray arrayWithObjects:@"YES", @"NO", nil]] == 0);
	[statement release];
	return answer;
}

+ (BOOL) confirm: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	BOOL answer = [ModalAlert ask:statement withCancel:@"NO" withButtons:[NSArray arrayWithObject:@"YES"]];
	[statement release];
	return	answer;
}

+(NSString *) textQueryWith: (NSString *)question withKeyborType:(UIKeyboardType)type prompt: (NSString *)prompt button1: (NSString *)button1 button2:(NSString *) button2
{
	// Create alert
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
	UIAlertView *alertView = nil;
	
    if (IS_IOS_5Plus) {
        alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:madelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        UITextField *tf = (UITextField *)[alertView textFieldAtIndex:0];
        tf.placeholder = prompt;
        tf.keyboardType = type;
        
        [alertView show];
    }else{
        alertView = [[UIAlertView alloc] initWithTitle:question message:@"\n" delegate:madelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];

        // Build text field
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 30.0f)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        tf.tag = TEXT_FIELD_TAG;
        tf.placeholder = prompt;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        //tf.keyboardType = UIKeyboardTypeAlphabet;
        tf.keyboardType = type;
        tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // Show alert and wait for it to finish displaying
        [alertView show];
        while (CGRectEqualToRect(alertView.bounds, CGRectZero));
        
        // Find the center for the text field and add it
        CGRect bounds = alertView.bounds;
        tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 10.0f);
        [alertView addSubview:tf];
        [tf release];
        
        // Set the field to first responder and move it into place
        [madelegate performSelector:@selector(moveAlert:) withObject:alertView afterDelay: 0.7f];
    }
    
	// Start the run loop
	CFRunLoopRun();
	
	// Retrieve the user choices
	NSUInteger index = madelegate.index;
	NSString *answer = [[madelegate.text copy] autorelease];
	if (index == 0) answer = nil; // assumes cancel in position 0
	
	[alertView release];
	[madelegate release];
	return answer;
}

+(NSDictionary *) textQuestionWith: (NSString *)question withKeyborType:(UIKeyboardType)type defualtText:(NSString *)defaultText placeHolder: (NSString *)placeholder button1: (NSString *)button1 button2:(NSString *) button2
{
	// Create alert
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
	UIAlertView *alertView = nil;
	
    if (IS_IOS_5Plus) {
        alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:madelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];

        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *tf = (UITextField *)[alertView textFieldAtIndex:0];
        tf.placeholder = placeholder;
        tf.keyboardType = type;
        
        [alertView show];
    }else{
        alertView = [[UIAlertView alloc] initWithTitle:question message:@"\n" delegate:madelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];

        // Build text field
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 30.0f)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        tf.tag = TEXT_FIELD_TAG;
        tf.placeholder = placeholder;
        tf.text = defaultText;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        //tf.keyboardType = UIKeyboardTypeAlphabet;
        tf.keyboardType = type;
        tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // Show alert and wait for it to finish displaying
        [alertView show];
        while (CGRectEqualToRect(alertView.bounds, CGRectZero));
        
        // Find the center for the text field and add it
        CGRect bounds = alertView.bounds;
        tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 10.0f);
        [alertView addSubview:tf];
        [tf release];
        
        // Set the field to first responder and move it into place
        [madelegate performSelector:@selector(moveAlert:) withObject:alertView afterDelay: 0.7f];

    }
		
	// Start the run loop
	CFRunLoopRun();
	
	// Retrieve the user choices
	NSUInteger index = madelegate.index;
	NSString *answer = [[madelegate.text copy] autorelease];
	if (index == 0) answer = nil; // assumes cancel in position 0
	
	[alertView release];
	[madelegate release];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:index],@"buttonindex",answer,@"answer", nil];
    
	return dict;
}

+ (NSString *) ask: (NSString *) question withKeyborType:(UIKeyboardType)type withTextPrompt: (NSString *) prompt
{
	return [ModalAlert textQueryWith:question withKeyborType:type prompt:prompt button1:@"NO" button2:@"YES"];
}

+ (NSDictionary *) ask: (NSString *)question withKeyborType:(UIKeyboardType)type withPlaceHolder:(NSString *)placeholder withDefaultText:(NSString *)defaultText
{
    return [ModalAlert textQuestionWith:question withKeyborType:type defualtText:defaultText placeHolder:placeholder button1:@"NO" button2:@"YES"];
}

+ (NSArray *) ask:(NSString *)question withKeyborType:(UIKeyboardType)type withTextPrompt:(NSString *)prompt  withOtherKeyborType:(UIKeyboardType)otherType withOtherTextPrompt:(NSString *)otherPrompt
{
    // Create alert
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
	UIAlertView *alertView = nil;
	
    if (IS_IOS_5Plus) {
        alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:madelegate cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        
        UITextField *tf = (UITextField *)[alertView textFieldAtIndex:0];
        tf.placeholder = prompt;
        tf.keyboardType = type;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        UITextField *other_tf = (UITextField *)[alertView textFieldAtIndex:1];
        other_tf.secureTextEntry = NO;
        other_tf.placeholder = otherPrompt;
        other_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        other_tf.keyboardType = otherType;

        [alertView show];
    }else{
        alertView = [[UIAlertView alloc] initWithTitle:question message:@"\n\n\n" delegate:madelegate cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];

        // Build text field
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 30.0f)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        tf.tag = TEXT_FIELD_TAG;
        tf.placeholder = prompt;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        //tf.keyboardType = UIKeyboardTypeAlphabet;
        tf.keyboardType = type;
        tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // Build text field
        UITextField *other_tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 32.0f, 260.0f, 30.0f)];
        other_tf.borderStyle = UITextBorderStyleRoundedRect;
        other_tf.tag = OTHER_TEXT_FIELD_TAG;
        other_tf.placeholder = otherPrompt;
        other_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        other_tf.keyboardType = otherType;
        other_tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        other_tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        other_tf.autocorrectionType = UITextAutocorrectionTypeNo;
        other_tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // Show alert and wait for it to finish displaying
        [alertView show];
        while (CGRectEqualToRect(alertView.bounds, CGRectZero));
        
        // Find the center for the text field and add it
        CGRect bounds = alertView.bounds;
        tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 30.0f);
        [alertView addSubview:tf];
        [tf release];
        
        other_tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f + 10.0f);
        [alertView addSubview:other_tf];
        [other_tf release];
        
        // Set the field to first responder and move it into place
        [madelegate performSelector:@selector(moveAlert:) withObject:alertView afterDelay: 0.7f];
    }
	
	// Start the run loop
	CFRunLoopRun();
	
	// Retrieve the user choices
	NSUInteger index = madelegate.index;
	NSString *answer = [[madelegate.text copy] autorelease];
    if (!answer) {
        answer = @"";
    }
    NSString *otherAnswer = [[madelegate.otherText copy] autorelease];
    if (!otherAnswer) {
        otherAnswer = @"";
    }
    NSArray *answers = [NSArray arrayWithObjects:answer,otherAnswer, nil];
	if (index == 0) answers = nil; // assumes cancel in position 0
	
	[alertView release];
	[madelegate release];
	return answers;
}

@end

