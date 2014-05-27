//
//  ECAddFeedController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/25/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

@class ECSubscriptionFolder;

@interface ECAddFeedController : NSWindowController

//@property (retain, nonatomic) NSMutableArray *folderArray;
@property (assign, nonatomic) IBOutlet NSWindow *mainWindow;
@property (assign, nonatomic) IBOutlet NSTextField *feedDialogTextField;
@property (assign, nonatomic) IBOutlet NSPanel *addFeedDialog;
@property (assign, nonatomic) IBOutlet NSButton *submitButton;

- (IBAction)showDialog:(id)sender;
- (IBAction)hideDialog:(id)sender;
- (void)didEndDialog:(NSWindow *)dialog returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (NSString *)getUrl;
- (void)clearTextField;
- (void)reloadDataOfPopUp;
@end
