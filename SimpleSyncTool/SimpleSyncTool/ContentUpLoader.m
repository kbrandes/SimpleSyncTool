//
//  ContentUpLoader.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/20/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import "ContentUpLoader.h"
#import "FileTree.h"
#import "FileTreeLoader.h"

@interface ContentUpLoader () <FileTreeLoaderDelegate, CloudServiceDelegate>

@property (nonatomic, strong) id<CloudService> service;
@property (nonatomic, strong) id<CloudServiceDelegate> oldDelegate;
@property (nonatomic, strong) FileTreeLoader *treeLoader;
@property (nonatomic, copy) NSString *sourcePath;
@property (nonatomic, copy) NSString *destinationPath;
@property (nonatomic, strong) NSMutableArray* uploadQueue;

@end
@implementation ContentUpLoader

#pragma mark - Property getter/setter

- (NSArray *)uploadQueue
{
    if (!_uploadQueue) {
        _uploadQueue = [[NSMutableArray alloc]init];
    }
    return _uploadQueue;
}

- (FileTreeLoader *)treeLoader
{
    if (!_treeLoader) {
        _treeLoader = [[FileTreeLoader alloc]init];
    }
    return _treeLoader;
}

# pragma mark - Public API

- (void)uploadContentFromSourcePath:(NSString *)sourcePath toDestinationPath:(NSString *)destinationPath withService:(id<CloudService>)service
{
    self.service = service;
    self.oldDelegate = self.service.delegate;
    self.service.delegate = self;
    self.sourcePath = sourcePath;
    self.destinationPath = destinationPath;
    [self.treeLoader loadCloudFileTreeWithCloudService:self.service andRootPath:destinationPath];
}

# pragma mark - FileTreeLoaderDelegate Protocol

- (void)didLoadCloudFileTree:(FileTree *)tree
{
    // check for error!!!
    FileTree *localTree = [self.treeLoader loadLocalFileTreeWithRootPath:self.sourcePath error:nil];
    self.uploadQueue = [[super compareReferenceFileTree:localTree withSecondaryFileTree:tree]mutableCopy];
    [self uploadNextFile];
}

- (void)errorWhileLoadingCloudFileTree:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(contentUpLoader:recognizedError:whileUploadingContentFromSourcePath:toDestinationPath:)]) {
        [self.delegate contentUpLoader:self recognizedError:error whileUploadingContentFromSourcePath:self.sourcePath toDestinationPath:self.destinationPath];
    }
}

#pragma mark - CloudServiceDelegate Protocol

- (void)didUploadFileFromLocalPath:(NSString *)localPath toCloudPath:(NSString *)cloudPath
{
    [self uploadNextFile];
}

- (void)errorOccurredWhileUploadingFile:(NSError *)error
{
    [self cancelProcessWithError:error];
}



# pragma mark - Private API

- (void)uploadNextFile
{
    NSDictionary *nextFile = [self dequeueFile];
    if (nextFile) {
        [self uploadFile:[nextFile valueForKey:ReferenceFilePath] toFile:[nextFile valueForKey:SecondaryFilePath]];
    } else {
        [self uploadingDone];
    }
}

- (NSDictionary *)dequeueFile
{
    if ([self.uploadQueue count]>0) {
        NSDictionary *file = [self.uploadQueue objectAtIndex:0];
        [self.uploadQueue removeObjectAtIndex:0];
        return file;
    } else {
        return nil;
    }
}

- (void)uploadFile:(NSString *)localPath toFile:(NSString *)cloudPath
{
    [self.service uploadFileFromLocalPath:localPath toCloudPath:cloudPath];
    if ([self.delegate respondsToSelector:@selector(contentUpLoader:statusUpdate:)]) {
        [self.delegate contentUpLoader:self statusUpdate:[NSString stringWithFormat:@"Uploading %@", [localPath lastPathComponent]]];
    }
}

- (void)cancelProcessWithError:(NSError *)error
{
    self.uploadQueue = nil;
    self.service.delegate = self.oldDelegate;
    if ([self.delegate respondsToSelector:@selector(contentUpLoader:recognizedError:whileUploadingContentFromSourcePath:toDestinationPath:)]) {
        [self.delegate contentUpLoader:self recognizedError:error whileUploadingContentFromSourcePath:self.sourcePath toDestinationPath:self.destinationPath];
    }
}

- (void)uploadingDone
{
    self.service.delegate = self.oldDelegate;
    if ([self.delegate respondsToSelector:@selector(contentUpLoader:didUploadContentFromSourcePath:toDestinationPath:)]) {
        [self.delegate contentUpLoader:self didUploadContentFromSourcePath:self.sourcePath toDestinationPath:self.destinationPath];
    }
}



@end
