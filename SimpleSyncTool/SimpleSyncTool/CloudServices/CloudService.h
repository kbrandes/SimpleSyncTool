//
//  CloudService.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/26/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CloudServiceDelegate <NSObject>

// Delegate gets called when client did authenticate.
- (void)didAuthenticate;
- (void)errorOccurredWhileAuthentication:(NSError *)error;

// Delegate gets called when content is ready. Array contains dictionaries with fileinformation
- (void)didLoadContent:(NSArray *)content ofPath:(NSString *)path;
- (void)errorOccurredWhileLoadingContent:(NSError *)error;
// Delegate gets called when a file upload finished
- (void)didUploadFileFromLocalPath:(NSString *)localPath toCloudPath:(NSString *)cloudPath;
- (void)errorOccurredWhileUploadingFile:(NSError *)error;
// Delegate gets callwhen a file download finished
- (void)didDownloadFileToLocalPath:(NSString *)localPath;
- (void)errorOccurredWhileDownloadingFile:(NSError *)error;

@end


@protocol CloudService <NSObject>

// This needs to be called before you use the api. If the client did not authenticate
// properly all following actions will fail. (Async)
- (void)authenticate;

// Load content of a specific path in the cloud (Async)
- (void)loadContentOfCloudPath:(NSString *)path;
// Upload a file from the local file system into the cloud (Async)
- (void)uploadFileFromLocalPath:(NSString *)localPath toCloudPath:(NSString *)cloudPath;
// Download a file from the cloud into the local file system (Async)
- (void)downloadFileFromCloudPath:(NSString *)cloudPath toLocalPath:(NSString *)localPath;

// Receive data updates via delegate
@property (nonatomic, weak) id<CloudServiceDelegate> delegate;

@end


// Content information tags
// ************************
//
#define CloudServiceContentName @"Name"
#define CloudServiceContentLastModifiedDate @"LastModifiedDate"
#define CloudServiceContentIsDirectory @"IsDirectory"
#define CloudServiceContentPath @"Path"
#define CloudServiceContentSize @"Size"



// Error Codes
// ***********
//
// 100 - Authetication failed, unable to connect to service
//
//
// add more codes here
#define CloudServiceErrorDomain @"CloudService"

#define CloudServiceNotAutheticatedError 100
#define CloudServiceAutheticationFailedError 110
#define CloudServiceLoadContentFailedError 210
#define CloudServiceDownloadFileFailedError 220
#define CloudServiceUploadFileFailedError 230



