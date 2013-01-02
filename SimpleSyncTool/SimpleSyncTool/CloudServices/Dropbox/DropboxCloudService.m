//
//  DropboxCloudService.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/26/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import "DropboxCloudService.h"
#import <DropboxOSX/DropboxOSX.h>

@interface DropboxCloudService () <DBRestClientOSXDelegate>

@property (nonatomic, strong) DBRestClient *client;
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;

@end
@implementation DropboxCloudService

#pragma mark - Initializer

+ (id)cloudServiceWithAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret
{
    return [[self alloc] initWithAppKey:appKey andAppSecret:appSecret];
}

- (id)initWithAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret
{
    self = [super init];
    if (self) {
        self.appKey = appKey;
        self.appSecret = appSecret;
    }
    return self;
}

#pragma mark - Property getter/setter

- (DBRestClient *)client
{
    DBSession *serviceSession = [DBSession sharedSession];
    if (!_client && [serviceSession isLinked]) {
        _client = [[DBRestClient alloc] initWithSession:serviceSession];
        _client.delegate = self;
    }
    return _client;
}

#pragma mark - CloudService Protocol

- (void)authenticate
{
    // Check if appkey and appsecret are initialized
    if (self.appKey && self.appSecret) {
        DBSession *session = [[DBSession alloc] initWithAppKey:self.appKey appSecret:self.appSecret root:kDBRootDropbox];
        [DBSession setSharedSession:session];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHelperStateChangedNotification:) name:DBAuthHelperOSXStateChangedNotification object:[DBAuthHelperOSX sharedHelper]];
        if (![[DBSession sharedSession] isLinked])
            [[DBAuthHelperOSX sharedHelper] authenticate];
        else
            [self.delegate didAuthenticate];
    } else {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Authetication failed, invalid App Key and App Secret." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:CloudServiceErrorDomain code:CloudServiceAutheticationFailedError userInfo:errorDetail];
        [self.delegate errorOccurredWhileAuthentication:error];
    }
}

- (void)loadContentOfCloudPath:(NSString *)path
{
    // check if client is connected to service (authentication occurred)
    if (self.client) {
        [self.client loadMetadata:path];
    } else {
        NSError *error = [self createDefaultErrorWithMessage:@"Client is not authenticated." andErrorCode:CloudServiceNotAutheticatedError];
        [self.delegate errorOccurredWhileLoadingContent:error];
    }
}

- (void)uploadFileFromLocalPath:(NSString *)localPath toCloudPath:(NSString *)cloudPath
{
    // check if client is connected to service (authentication occurred)
    if (self.client) {
        NSString *filename = [localPath lastPathComponent];
        [self.client uploadFile:filename toPath:cloudPath withParentRev:nil fromPath:localPath];
    } else {
        NSError *error = [self createDefaultErrorWithMessage:@"Client is not authenticated." andErrorCode:CloudServiceNotAutheticatedError];
        [self.delegate errorOccurredWhileUploadingFile:error];
    }
}

- (void)downloadFileFromCloudPath:(NSString *)cloudPath toLocalPath:(NSString *)localPath
{
    // check if client is connected to service (authentication occurred)
    if (self.client) {
        [self.client loadFile:cloudPath intoPath:localPath];
    } else {
        NSError *error = [self createDefaultErrorWithMessage:@"Client is not authenticated." andErrorCode:CloudServiceNotAutheticatedError];
        [self.delegate errorOccurredWhileDownloadingFile:error];
    }
}

#pragma mark - DBRestClientOSXDelegate Protocol

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    // convert metadata into array of dictionaries
    NSMutableArray *content = [[NSMutableArray alloc] init];
    for (DBMetadata *contentMetadata in metadata.contents) {
        NSArray *contentKeys = [NSArray arrayWithObjects:CloudServiceContentName,CloudServiceContentPath,CloudServiceContentSize,CloudServiceContentIsDirectory,CloudServiceContentLastModifiedDate,nil];
        NSString *filename = contentMetadata.filename;
        NSString *path = contentMetadata.path;
        NSNumber *size = [NSNumber numberWithLong:contentMetadata.totalBytes];
        NSNumber *isDirectory = [NSNumber numberWithBool:contentMetadata.isDirectory];
        NSDate *lastModified = contentMetadata.lastModifiedDate;
        NSArray *contentValues = [NSArray arrayWithObjects:filename,path,size,isDirectory,lastModified, nil];
        NSDictionary *contentInformation = [NSDictionary dictionaryWithObjects:contentValues forKeys:contentKeys];
        [content addObject:contentInformation];
    }
    [self.delegate didLoadContent:content ofPath:metadata.path];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    NSError *cloudServiceError = [self createDefaultErrorWithMessage:error.localizedDescription andErrorCode:CloudServiceLoadContentFailedError];
    [self.delegate errorOccurredWhileLoadingContent:cloudServiceError];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    
    [self.delegate didUploadFileFromLocalPath:srcPath toCloudPath:destPath];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSError *cloudError = [self createDefaultErrorWithMessage:error.localizedDescription andErrorCode:CloudServiceUploadFileFailedError];
    [self.delegate errorOccurredWhileUploadingFile:cloudError];
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath
{
    [self.delegate didDownloadFileToLocalPath:destPath];
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    NSError *cloudError = [self createDefaultErrorWithMessage:error.localizedDescription andErrorCode:CloudServiceDownloadFileFailedError];
    [self.delegate errorOccurredWhileDownloadingFile:cloudError];
}

/*
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
*/

#pragma mark - Private utility methods

- (void)authHelperStateChangedNotification:(NSNotification *)notification
{
    if ([[DBSession sharedSession] isLinked]) {
        [self.delegate didAuthenticate];
    } else {
        NSError *error = [self createDefaultErrorWithMessage:@"Authetication failed, unable to connect to service." andErrorCode:CloudServiceAutheticationFailedError];
        [self.delegate errorOccurredWhileAuthentication:error];
    }
}

- (NSError *)createDefaultErrorWithMessage:(NSString *)message andErrorCode:(NSInteger)errorCode
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:message forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:CloudServiceErrorDomain code:errorCode userInfo:errorDetail];
    return error;
}

@end
