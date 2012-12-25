//
//  AppDelegate.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/15/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import "AppDelegate.h"
#import "GTL/GTLUtilities.h"
#import "GTL/GTMHTTPFetcherLogging.h"

static NSString *const kKeychainItemName = @"Google Drive Quickstart";
static NSString *const kClientID = @"649976549881.apps.googleusercontent.com";
static NSString *const kClientSecret = @"6cwhrofN_qjgSvTQ2ATgYBLf";

@interface AppDelegate ()
@property (nonatomic, readonly) GTLServiceDrive *driveService;
@end

@implementation AppDelegate

- (IBAction)signInClicked:(NSButton *)sender {
}

- (NSString *)signedInUsername {
    // Get the email address of the signed-in user.
    GTMOAuth2Authentication *auth = self.driveService.authorizer;
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn) {
        return auth.userEmail;
    } else {
        return nil;
    }
}

- (BOOL)isSignedIn {
    NSString *name = [self signedInUsername];
    return (name != nil);
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
