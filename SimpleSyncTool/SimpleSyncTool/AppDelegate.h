//
//  AppDelegate.h
//  SimpleSyncTool
//
//  Created by Fabian Introvigne on 12/15/12.
//  Copyright (c) 2012 Fabian Introvigne. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSScrollView *fileListView;

@end
