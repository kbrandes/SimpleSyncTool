//
//  CloudService.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/26/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CloudServiceDelegate <NSObject>

// Delegate gets called when content is ready. Array contains dictionaries with fileinformation
- (void)didLoadContent:(NSArray *)content ofPath:(NSString *)path;
- (void)errorOccurred:(NSError *)error whileLoadingContentOfPath:(NSString *)path;
// Delegate gets called when a file upload finished
- (void)didUploadFileFromLocalPath:(NSString *)localPath toCloudPath:(NSString *)cloudPath;
- (void)errorOccurred:(NSError *)error whileUploadingFileFromLocalPath:(NSString *)localPath toCloudPath:(NSString *)cloudPath;
// Delegate gets callwhen a file download finished
- (void)didDownloadFileFromCloudPath:(NSString *)cloudPath toLocalPath:(NSString *)localPath;
- (void)errorOccurred:(NSError *)error whileDownloadingFileFromCloudPath:(NSString *)cloudPath toLocalPath:(NSString *)localPath;

@end


@protocol CloudService <NSObject>

// Load content of a specific path in the cloud (Async)
- (void)loadContentOfCloudPath:(NSString *)path;
// Upload a file from the local file system into the cloud (Async)
- (void)uploadFileFromLocalPath:(NSString *)localPath toCloudPath:(NSString *)cloudPath;
// Download a file from the cloud into the local file system (Async)
- (void)downloadFileFromCloudPath:(NSString *)cloudPath toLocalPath:(NSString *)localPath;

// Receive data updates via delegate
@property (nonatomic, weak) id<CloudServiceDelegate> delegate;

@end
