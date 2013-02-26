//
//  AppDelegate.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/15/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import "AppDelegate.h"
#import "DropboxCloudService.h"

@interface AppDelegate () <CloudServiceDelegate>

@property (nonatomic, strong) id<CloudService> service;
@property (nonatomic, strong) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.barMenu];
    [self.statusItem setTitle:@"SST"];
    [self.statusItem setHighlightMode:YES];
    
    // Cloud service
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionSettings" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *appKey = [dict objectForKey:@"DropboxAppKey"];
    NSString *appSecret = [dict objectForKey:@"DropboxAppSecret"];
    self.service = [DropboxCloudService cloudServiceWithAppKey:appKey andAppSecret:appSecret];
    //self.service.delegate = self;
    //[self.service authenticate];
}



// Delegate gets called when client did authenticate.
- (void)didAuthenticate
{
    NSLog(@"Did authenticate");
    //[self.service uploadFileFromLocalPath:@"/Users/kevinbrandes/Desktop/Phit.pdf" toCloudPath:@"/TestFolder/"];
    //[self.service downloadFileFromCloudPath:@"/TestFolder/Phit.pdf" toLocalPath:@"/Users/kevinbrandes/Desktop/Phit.pdf"];
    //[self.service loadContentOfCloudPath:@"/TestFolder/"];
}

- (void)errorOccurredWhileAuthentication:(NSError *)error
{
    NSLog(@"Error while authentication: %@", error);
}

// Delegate gets called when content is ready. Array contains dictionaries with fileinformation
- (void)didLoadContent:(NSArray *)content ofPath:(NSString *)path
{
    NSLog(@"Did load content: %@\nFrom path: %@", content, path);
}

- (void)errorOccurredWhileLoadingContent:(NSError *)error
{
    NSLog(@"Error while loading content: %@", error);
}

// Delegate gets called when a file upload finished
- (void)didUploadFileFromLocalPath:(NSString *)localPath toCloudPath:(NSString *)cloudPath
{
    NSLog(@"Did upload file from path: %@ \n to path: %@", localPath, cloudPath);
}

- (void)errorOccurredWhileUploadingFile:(NSError *)error
{
    NSLog(@"Error while uploading file: %@", error);
}

// Delegate gets callwhen a file download finished
- (void)didDownloadFileToLocalPath:(NSString *)localPath
{
    NSLog(@"Did download file to path: %@", localPath);
}

- (void)errorOccurredWhileDownloadingFile:(NSError *)error
{
    NSLog(@"Error while downloading file: %@", error);
}

- (IBAction)statusBarMenuItemClicked:(NSMenuItem *)sender
{
    NSLog(@"Item clicked: %@", sender.title);
}



@end
