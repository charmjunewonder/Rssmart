//
//  ECAddFeedController.m
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import "ECAddFeedController.h"
#import "ECSubscriptionFolder.h"

@implementation ECAddFeedController

@synthesize mainWindow;
@synthesize addFeedDialog;
@synthesize feedDialogTextField;
@synthesize folderArray;

-(id)init
{
    self = [super init];
    if (self != nil) {
        folderArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)reloadDataOfPopUp
{
    NSAssert(addFeedDialog != nil, @"AddFeedDialog is nil");

//    NSMenu *menu = [categoryPopUp menu];
//    NSUInteger i, itemCount;
//    itemCount = [folderArray count];
//    
//    for (i = 0; i < itemCount; i++) {
//        ECSubscriptionFolder *folder = [folderArray objectAtIndex:i];
//        NSMenuItem *mi = [[NSMenuItem alloc] init];
//        [mi setTitle:[folder title]];
//        [mi setTag:i];
//        [mi setValue:folder forKey:@"folder"];
//        [menu addItem:mi];
//    }
    // Initially show the first controller

}

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
