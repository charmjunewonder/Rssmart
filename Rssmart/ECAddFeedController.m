//
//  ECAddFeedController.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECAddFeedController.h"
//#import <Foundation/Foundation.h>

@implementation ECAddFeedController

@synthesize mainWindow;
@synthesize addFeedDialog;
@synthesize feedDialogTextField;

- (IBAction)showDialog:(id)sender {
	[NSApp beginSheet:addFeedDialog modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(didEndDialog:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)hideDialog:(id)sender {
	[NSApp endSheet:addFeedDialog];
}

- (void)didEndDialog:(NSWindow *)dialog returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [dialog orderOut:self];
}

- (NSString *)getUrl{
    return [feedDialogTextField stringValue];
}

- (void)clearTextField{
    [feedDialogTextField setStringValue:@""];
}
@end
