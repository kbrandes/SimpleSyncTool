//
//  AppDelegate.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/15/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DropboxOSX/DropboxOSX.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSTextField *dropboxOwnerLabel;
@property (nonatomic, weak) IBOutlet NSTextField *dropboxPathTextField;
@property (nonatomic, weak) IBOutlet NSTextField *localPathTextField;

@end
