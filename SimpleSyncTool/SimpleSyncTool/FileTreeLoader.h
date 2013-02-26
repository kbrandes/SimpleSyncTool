//
//  CloudFileTreeLoader.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/8/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudService.h"
#import "FileTree.h"

@protocol FileTreeLoaderDelegate <NSObject>

@optional
- (void)didLoadCloudFileTree:(FileTree *)tree;
- (void)errorWhileLoadingCloudFileTree:(NSError *)error;

@end

@interface FileTreeLoader : NSObject

// Load the file tree of a specific folder in the cloud (Async)
- (void)loadCloudFileTreeWithCloudService:(id<CloudService>)service andRootPath:(NSString *)root;
// Load the file tree of a local folder
- (FileTree *)loadLocalFileTreeWithRootPath:(NSString *)root error:(NSError **)error;

@property (nonatomic, weak) id<FileTreeLoaderDelegate> delegate;

@end
