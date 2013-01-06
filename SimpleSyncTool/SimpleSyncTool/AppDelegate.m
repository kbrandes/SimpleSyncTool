//
//  AppDelegate.m
//  SimpleSyncTool
//
//  Created by Fabian Introvigne on 12/15/12.
//  Copyright (c) 2012 Fabian Introvigne. All rights reserved.
//

#import "AppDelegate.h"
#import "GoogleDriveCloudService.h"

@interface AppDelegate ()
@property (nonatomic, strong) GoogleDriveCloudService *googleDriveService;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    self.googleDriveService = [[GoogleDriveCloudService alloc] initWithGoogleDriveCloudService:self.window];
}
- (IBAction)signInClicked:(NSButton *)sender
{
    [self.googleDriveService authenticate];
}
- (IBAction)getFileListClicked:(NSButton *)sender
{
    [self.googleDriveService loadContentOfCloudPath:@"./"];
}
- (IBAction)detailsClicked:(NSButton *)sender
{
    
}
- (IBAction)uploadClicked:(NSButton *)sender
{
    // Ask the user to choose a file.
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt:@"Upload"];
    [openPanel setCanChooseDirectories:NO];
    [openPanel beginSheetModalForWindow:[self window]
                      completionHandler:^(NSInteger result) {
                          // Callback.
                          if (result == NSOKButton) {
                              // The user chose a file and clicked OK.
                              //
                              // Start uploading (deferred briefly since
                              // we currently have a sheet displayed).
                              NSString *path = [[openPanel URL] path];
                              [self.googleDriveService uploadFileFromLocalPath:path toCloudPath:nil];
                              /*[self performSelector:@selector(uploadFileAtPath:)
                                         withObject:path
                                         afterDelay:0.1];*/
                          }
                      }];
}


@end
