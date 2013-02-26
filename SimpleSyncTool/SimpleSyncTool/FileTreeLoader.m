//
//  CloudFileTreeLoader.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/8/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import "FileTreeLoader.h"


@interface FileTreeLoader () <CloudServiceDelegate>

@property (nonatomic, strong) id<CloudService> service;
@property (nonatomic, strong) FileTree *rootFileTree;
@property (nonatomic, strong) NSMutableDictionary *cloudLookUpTable;

@property (nonatomic, weak) id<CloudServiceDelegate> oldServiceDelegate;

@end
@implementation FileTreeLoader

#pragma mark - Property getters/setters

- (NSMutableDictionary *)cloudLookUpTable
{
    if (!_cloudLookUpTable) {
        _cloudLookUpTable = [[NSMutableDictionary alloc]init];
    }
    return _cloudLookUpTable;
}

#pragma mark - Public API

- (void)loadCloudFileTreeWithCloudService:(id<CloudService>)service andRootPath:(NSString *)root;
{
    // register as delegate and store old delegate
    self.service = service;
    self.oldServiceDelegate = self.service.delegate;
    self.service.delegate = self;
    [self.cloudLookUpTable removeAllObjects];
    
    // start querrying
    FileTree *rootTree = [[FileTree alloc]init];
    self.rootFileTree = rootTree;
    rootTree.filePath = root;
    [self.cloudLookUpTable setObject:rootTree forKey:root];
    [self.service loadAttributesOfCloudPath:root];
}

- (FileTree *)loadLocalFileTreeWithRootPath:(NSString *)root error:(NSError **)error
{
    FileTree *tree = [[FileTree alloc]init];
    tree.filePath = root;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager]attributesOfItemAtPath:root error:error];
    tree.lastUpdate = [fileAttributes objectForKey:NSFileModificationDate];
    BOOL isDirectory;
    [[NSFileManager defaultManager]fileExistsAtPath:root isDirectory:&isDirectory];
    if (isDirectory) {
        tree.isDirectory = YES;
        NSArray *content = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:root error:error];
        for (NSString *pathComponent in content) {
            NSString *fullPath = [root stringByAppendingPathComponent:pathComponent];
            FileTree *subContent = [self loadLocalFileTreeWithRootPath:fullPath error:error];
            [tree addContent:subContent];
        }
    } else {
        tree.isDirectory = NO;
    }
    return tree;
}

#pragma mark - CloudServiceDelegate Protocol

- (void)didLoadAttributes:(NSDictionary *)attributes ofPath:(NSString *)path
{
    FileTree *currentTree = [self.cloudLookUpTable objectForKey:path];
    [self.cloudLookUpTable removeObjectForKey:path];
    currentTree.isDirectory = [[attributes objectForKey:CloudServiceFileAttributeIsDirectory] boolValue];
    currentTree.lastUpdate = [attributes objectForKey:CloudServiceFileAttributeLastModifiedDate];
    for (NSString *content in [attributes objectForKey:CloudServiceFileAttributeContent]) {
        FileTree *tree = [[FileTree alloc]init];
        tree.filePath = content;
        [currentTree addContent:tree];
        [self.cloudLookUpTable setObject:tree forKey:tree.filePath];
        [self.service loadAttributesOfCloudPath:content];
    }
    
    // restore old delegate of service when done
    if ([self.cloudLookUpTable count] == 0) {
        self.service.delegate = self.oldServiceDelegate;
        if ([self.delegate respondsToSelector:@selector(didLoadCloudFileTree:)])
            [self.delegate didLoadCloudFileTree:self.rootFileTree];
    }
}

- (void)errorOccurredWhileLoadingAttributes:(NSError *)error
{
    // clear look up table
    [self.cloudLookUpTable removeAllObjects];
    
    // restore old delegate of service
    self.service.delegate = self.oldServiceDelegate;
    
    if ([self.delegate respondsToSelector:@selector(errorWhileLoadingCloudFileTree:)])
        [self.delegate errorWhileLoadingCloudFileTree:error];
}

#pragma mark - Private API



@end
