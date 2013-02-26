//
//  CloudSynchronizer.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/3/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudService.h"
#import "SyncFile.h"

@class CloudSynchronizer;
@protocol CloudSynchronizerDelegate <NSObject>

- (void)synchronizer:(CloudSynchronizer *)synchronizer autheticationDidFailWithError:(NSError *)error;
- (void)synchronizerAuthenticationDidSucceed:(CloudSynchronizer *)synchronizer;
- (void)synchronizer:(CloudSynchronizer *)synchronizer isCurrentlySyncingFile:(SyncFile *)file;
- (void)synchronizerDidFinishSyncing:(CloudSynchronizer *)synchronizer;

@end

@interface CloudSynchronizer : NSObject

@property (nonatomic, strong) id<CloudService> service;
@property (nonatomic, strong) NSArray *files;

@property (nonatomic, weak) id<CloudSynchronizerDelegate> delegate;

// Designated initializer
- (id)initWithCloudService:(id<CloudService>)service files:(NSArray *)files;
+ (id)synchronizerWithCloudService:(id<CloudService>)service files:(NSArray *)files;
- (id)initWithCloudService:(id<CloudService>)service;
+ (id)synchronizerWithCloudService:(id<CloudService>)service;

- (void)addFile:(SyncFile *)file;
- (void)removeFile:(SyncFile *)file;
- (void)sync;

@end
