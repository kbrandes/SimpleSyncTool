//
//  DropboxCloudService.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/26/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import "DropboxCloudService.h"
#import <DropboxOSX/DropboxOSX.h>

#define APPKEY @"DropboxAppKey"
#define APPSECRET @"DropboxAppSecret"

@interface DropboxCloudService () <DBRestClientOSXDelegate>

@property (nonatomic, strong) DBRestClient *client;

@end
@implementation DropboxCloudService

# pragma mark - Property getter/setter

- (DBRestClient *)client
{
    DBSession *session = [DBSession sharedSession];
    if (!_client && [session isLinked]) {
        _client = [[DBRestClient alloc] initWithSession:session];
        _client.delegate = self;
    }
    return _client;
}

# pragma mark - Public api

// designated initializer
- (id)initWithAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret
{
    if (self = [super init]) {
        // initialize object
    }
    return self;
}

- (void)loadContentOfPath:(NSString *)path
{
    // Todo: Put logic here
}

- (void)uploadFileFrom:(NSString *)localPath to:(NSString *)cloudPath
{
    // Todo: Put logic here
}

- (void)downloadFileFrom:(NSString *)cloudPath to:(NSString *)localPath
{
    // Todo: Put logic here
}

# pragma mark - Private api

- (void)initializeDropboxConnection
{
    NSDictionary *connectionSettings = [NSDictionary dictionaryWithContentsOfFile:@"/Users/kevinbrandes/Developer/SimpleSyncTool/SST-DropboxDev/SimpleSyncTool/SimpleSyncTool/ConnectionSettings.plist"];
    NSString *appKey = [connectionSettings valueForKey:APPKEY];
    NSString *appSecret = [connectionSettings valueForKey:APPSECRET];
    DBSession *session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:kDBRootDropbox];
    [DBSession setSharedSession:session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHelperStateChangedNotification:) name:DBAuthHelperOSXStateChangedNotification object:[DBAuthHelperOSX sharedHelper]];
    if (![[DBSession sharedSession] isLinked])
        [[DBAuthHelperOSX sharedHelper] authenticate];
}

- (void)authHelperStateChangedNotification:(NSNotification *)notification
{
    if ([[DBSession sharedSession] isLinked]) {
        // You can now start using the API!
        NSLog(@"Connected");
    } else {
        NSLog(@"Disconnected");
    }
}

#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    NSLog(@"Loaded metadata: %@", metadata.contents);
    for (DBMetadata *content in metadata.contents) {
        if (content.isDirectory) {
            NSLog(@"Folder: %@", content.filename);
        } else {
            NSLog(@"File: %@", content.filename);
        }
    }
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
    NSLog(@"Loaded metadata unchanged at path: %@", path);
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    NSLog(@"Loaded metadata failed with error: %@", error);
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath
{
    NSLog(@"Loaded thumbnail: %@", destPath);
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error
{
    NSLog(@"Loaded thumbnail with error: %@", error);
}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info
{
    NSLog(@"Loaded account info: %@", info.displayName);
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath
{
    NSLog(@"loaded File: %@", destPath);
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    NSLog(@"Load file failed: %@", error);
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"File upload failed with error - %@", error);
}


@end
