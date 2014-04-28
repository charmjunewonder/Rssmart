//
//  ECAddFolderController.m
//  Rssmart
//
//  Created by charmjunewonder on 4/28/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECAddFolderController.h"

@implementation ECAddFolderController

@synthesize mainWindow;
@synthesize addFolderDialog;
@synthesize folderDialogTextField;
@synthesize submitButton;

- (IBAction)showDialog:(id)sender {
	[NSApp beginSheet:addFolderDialog modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(didEndDialog:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)hideDialog:(id)sender {
	[NSApp endSheet:addFolderDialog];
}

- (void)didEndDialog:(NSWindow *)dialog returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [dialog orderOut:self];
}

- (NSString *)getFolderName{
    return [folderDialogTextField stringValue];
}

- (void)clearTextField{
    [folderDialogTextField setStringValue:@""];
}

@end
