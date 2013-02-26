//
//  CloudSynchronizer.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/3/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import "CloudSynchronizer.h"
#import "FileTree.h"
#import "FileTreeLoader.h"


@interface CloudSynchronizer () <CloudServiceDelegate, FileTreeLoaderDelegate>

@property (nonatomic) BOOL serviceIsReadyToUse;
@property (nonatomic, strong) NSDictionary *loadingDict;
@property (nonatomic, strong) FileTreeLoader *fileTreeloader;
@property (nonatomic, strong) NSMutableArray *filesToUpload;
@property (nonatomic, strong) NSMutableArray *filesToDownload;

@end
@implementation CloudSynchronizer

#pragma mark - Property getter/setter

- (NSMutableArray *)filesToDownload
{
    if (!_filesToDownload) {
        _filesToDownload = [[NSMutableArray alloc]init];
    }
    return _filesToDownload;
}

- (NSMutableArray *)filesToUpload
{
    if (!_filesToUpload) {
        _filesToUpload = [[NSMutableArray alloc]init];
    }
    return _filesToUpload;
}

- (NSDictionary *)loadingDict
{
    if (!_loadingDict) {
        _loadingDict = [[NSDictionary alloc]init];
    }
    return _loadingDict;
}

- (NSArray *)files
{
    if (!_files) {
        _files = [[NSArray alloc]init];
    }
    return _files;
}

- (void)setService:(id<CloudService>)service
{
    if (_service != service) {
        _service = service;
        _service.delegate = self;
        [_service authenticate];
    }
}

- (FileTreeLoader *)fileTreeloader
{
    if (!_fileTreeloader) {
        _fileTreeloader = [[FileTreeLoader alloc]init];
        _fileTreeloader.delegate = self;
    }
    return _fileTreeloader;
}

#pragma mark - Initializers

// Designated initializer
- (id)initWithCloudService:(id<CloudService>)service files:(NSArray *)files
{
    self = [super init];
    if (self) {
        self.service = service;
        self.files = files;
    }
    return self;
}

+ (id)synchronizerWithCloudService:(id<CloudService>)service files:(NSArray *)files
{
    return [[self alloc]initWithCloudService:service files:files];
}

- (id)initWithCloudService:(id<CloudService>)service
{
    return [self initWithCloudService:service files:[[NSArray alloc]init]];
}

+ (id)synchronizerWithCloudService:(id<CloudService>)service
{
    return [[self alloc] initWithCloudService:service];
}

#pragma mark - Public API

- (void)addFile:(SyncFile *)file
{
    NSMutableArray *files = [self.files mutableCopy];
    [files addObject:file];
    self.files = files;
}

- (void)removeFile:(SyncFile *)file
{
    NSMutableArray *files = [self.files mutableCopy];
    [files removeObject:file];
    self.files = files;
}

- (void)sync
{
    //NSLog(@"%@", tree.content )
    /*
    if (self.serviceIsReadyToUse) {
        for (SyncFile *currentFile in self.files)
            // 1. load local and remote file trees
            // 2. get sync files
            // 3. uload sync files
            //[self syncFileToCloud:currentFile];
        for (SyncFile *currentFile in self.files)
            // 1. load local and remote file trees
            // 2. get sync files
            // 3. download sync files
            //[self syncFileToLocal:currentFile];
    } else {
        
    }*/
}

#pragma mark - FileTreeLoaderDelegate Protocol

- (void)didLoadCloudFileTree:(FileTree *)tree
{
    NSLog(@"Did load File tree from cloud.");
    NSLog(@"%@", tree);
}

- (void)errorWhileLoadingFileTree:(NSError *)error
{
    NSLog(@"Error while loading file tree!");
}


#pragma mark - CloudServiceDelegate Protocol


// Delegate gets called when client did authenticate.
- (void)didAuthenticate
{
    self.serviceIsReadyToUse = YES;
    [self.delegate synchronizerAuthenticationDidSucceed:self];
}

- (void)errorOccurredWhileAuthentication:(NSError *)error
{
    self.serviceIsReadyToUse = NO;
    [self.delegate synchronizer:self autheticationDidFailWithError:error];
}

// Delegate gets called when content is ready. Array contains dictionaries with fileinformation
- (void)didLoadContent:(NSArray *)content ofPath:(NSString *)path
{
    
}

- (void)errorOccurredWhileLoadingContent:(NSError *)error
{
    
}

// Delegate gets called when a file upload finished
- (void)didUploadFileFromLocalPath:(NSString *)localPath toCloudPath:(NSString *)cloudPath
{
    
}

- (void)errorOccurredWhileUploadingFile:(NSError *)error
{
    
}

// Delegate gets callwhen a file download finished
- (void)didDownloadFileToLocalPath:(NSString *)localPath
{
    
}

- (void)errorOccurredWhileDownloadingFile:(NSError *)error
{
    
}

#pragma mark - Private API

- (void)syncFileToCloud:(SyncFile *)file
{
    [self.service uploadFileFromLocalPath:file.localPath toCloudPath:file.cloudPath];
}

- (void)syncFileToLocal:(SyncFile *)file
{
    [self.service downloadFileFromCloudPath:file.cloudPath toLocalPath:file.localPath];
}



/*
- (void)addContentOfReferenceTree:(FileTree *)referenceTree toSecondaryTree:(FileTree *)secondaryTree
{
    if (referenceTree.isDirectory) {
        for (FileTree *referenceContentTree in referenceTree.content) {
            FileTree *secondaryContentTree = nil;
            if (![secondaryTree containsSubResourceWithName:referenceContentTree.filename])
                secondaryContentTree = [secondaryTree addSubResourceWithName:referenceContentTree.filename isDirectory:referenceContentTree.isDirectory];
            else
                secondaryContentTree = [secondaryTree resourceWithName:referenceContentTree.filename];
            if (referenceContentTree.isDirectory) {
                [self addContentOfReferenceTree:referenceContentTree toSecondaryTree:secondaryContentTree];
            }
        }
    }
}
*/



/*
- (FileTree *)getLocalFileTreeOfPath:(NSString *)localPath
{
    FileTree *tree = [[FileTree alloc]init];
    tree.filePath = localPath;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager]attributesOfItemAtPath:localPath error:nil];
    tree.lastUpdate = [fileAttributes objectForKey:NSFileModificationDate];
    BOOL isDirectory;
    [[NSFileManager defaultManager]fileExistsAtPath:localPath isDirectory:&isDirectory];
    if (isDirectory) {
        tree.isDirectory = YES;
        NSArray *content = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:localPath error:nil];
        for (NSString *pathComponent in content) {
            NSString *fullPath = [localPath stringByAppendingPathComponent:pathComponent];
            FileTree *subContent = [self getLocalFileTreeOfPath:fullPath];
            [tree addContent:subContent];
        }
    } else {
        tree.isDirectory = NO;
    }
    return tree;
}
 */
/*
- (void)getCloudFileTreeOfPath:(NSString *)cloudPath
{
    FileTree *tree = [[FileTree alloc]init];
    tree.filePath = cloudPath;
    
    //[self.service loadContentOfCloudPath:cloudPath];
}
*/


@end
