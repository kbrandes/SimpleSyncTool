//
//  AppDelegate.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/15/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxOSX/DropboxOSX.h>
#import <stdlib.h>
#import <time.h>


#define APPKEY @"DropboxAppKey"
#define APPSECRET @"DropboxAppSecret"

@interface AppDelegate () <DBRestClientOSXDelegate>

@property (nonatomic)  DBRestClient *dropboxClient;


@end

@implementation AppDelegate


@synthesize dropboxClient = _dropboxClient;
- (DBRestClient *)dropboxClient
{
    DBSession *session = [DBSession sharedSession];
    if (!_dropboxClient && [session isLinked]) {
        _dropboxClient = [[DBRestClient alloc] initWithSession:session];
        _dropboxClient.delegate = self;
    }
    return _dropboxClient;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self initializeDropboxConnection];
}

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
    [self.dropboxClient loadAccountInfo];
    [self.dropboxClient loadMetadata:@""];
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

- (IBAction)downloadButtonPressed:(NSButton *)sender
{
    [self.dropboxClient loadFile:self.dropboxPathTextField.stringValue intoPath:self.localPathTextField.stringValue];
}

- (IBAction)uploadButtonPressed:(NSButton *)sender
{
    [self.dropboxClient uploadFile:@"Phit2.pdf" toPath:self.dropboxPathTextField.stringValue withParentRev:nil fromPath:self.localPathTextField.stringValue];
}

#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    NSLog(@"Loaded metadata: %@", metadata.contents);
    for (DBMetadata *content in metadata.contents) {
        if (content.isDirectory) {
            NSLog(@"Folder: %@", content.filename);
        } else {
            NSLog(@"File: %@", content.filename);
        }
    }
    
    /*
    self.photosHash = metadata.hash;
    
    NSArray* validExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", nil];
    NSMutableArray* newPhotoPaths = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
        NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            [newPhotoPaths addObject:child.path];
        }
    }
    self.photosPaths = newPhotoPaths;
    [self loadRandomPhoto];
     */
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
    NSLog(@"Loaded metadata unchanged at path: %@", path);
    
    /*
    [self loadRandomPhoto];
     */
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    NSLog(@"Loaded metadata failed with error: %@", error);
    
    /*
    NSLog(@"restClient:loadMetadataFailedWithError: %@", error);
    self.randomPhotoButton.state = NSOnState;
     */
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
    NSLog(@"Loaded thumbnail: %@", destPath);
    
    /*
    self.randomPhotoButton.state = NSOnState;
    self.imageView.image = [[NSImage alloc] initWithContentsOfFile:destPath];
     */
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
    NSLog(@"Loaded thumbnail with error: %@", error);
    
    /*
    NSLog(@"restClient:loadThumbnailFailedWithError: %@", error);
    self.randomPhotoButton.state = NSOnState;
     */
}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info
{
    NSLog(@"Loaded account info: %@", info.displayName);
    self.dropboxOwnerLabel.stringValue = info.displayName;
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
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}




@end
