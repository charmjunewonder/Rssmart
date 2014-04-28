//
//  ECAddFolderController.h
//  Rssmart
//
//  Created by charmjunewonder on 4/28/14.
//  Copyright (c) 2014 Eric Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECAddFolderController : NSObject

@property (assign, nonatomic) IBOutlet NSWindow *mainWindow;
@property (assign, nonatomic) IBOutlet NSTextField *folderDialogTextField;
@property (assign, nonatomic) IBOutlet NSPanel *addFolderDialog;
@property (assign, nonatomic) IBOutlet NSButton *submitButton;

- (IBAction)showDialog:(id)sender;
- (IBAction)hideDialog:(id)sender;
- (void)didEndDialog:(NSWindow *)dialog returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (NSString *)getFolderName;
- (void)clearTextField;

@end
