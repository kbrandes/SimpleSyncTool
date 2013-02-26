//
//  FileTree.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/6/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import "FileTree.h"


@interface FileTree ()

@property (nonatomic, readwrite) NSString *filename;

@end
@implementation FileTree

#pragma mark - Property getters/setters

- (NSArray *)content
{
    if (!_content) {
        _content = [[NSArray alloc]init];
    }
    return _content;
}

- (void)setFilePath:(NSString *)filePath
{
    _filePath = filePath;
    self.filename = [filePath lastPathComponent];
}

#pragma mark - Public API

- (void)addContent:(FileTree *)content
{
    // Return if node is not a directory
    if (!self.isDirectory)
        return;
    NSMutableArray *mutableContent = [self.content mutableCopy];
    [mutableContent addObject:content];
    self.content = mutableContent;
}

- (FileTree *)addSubDirectoryWithName:(NSString *)name
{
    // Return nil if node is not a directory
    if (!self.isDirectory)
        return nil;
    NSString *path = [self.filePath stringByAppendingPathComponent:name];
    FileTree *subDirectory = [[FileTree alloc]init];
    subDirectory.filePath = path;
    subDirectory.isDirectory = YES;
    subDirectory.lastUpdate = [NSDate dateWithString:@"0000-00-00 00:00:00 +0100"];
    [self addContent:subDirectory];
    return subDirectory;
}

- (FileTree *)addSubFileWithName:(NSString *)name
{
    // return nil if node is not a directory
    if (!self.isDirectory)
        return nil;
    NSString *path = [self.filePath stringByAppendingPathComponent:name];
    FileTree *subFile = [[FileTree alloc]init];
    subFile.filePath = path;
    subFile.isDirectory = NO;
    subFile.lastUpdate = [NSDate dateWithString:@"0000-00-00 00:00:00 +0100"];
    [self addContent:subFile];
    return subFile;
}

- (FileTree *)addSubResourceWithName:(NSString *)name isDirectory:(BOOL)isDirectory
{
    // return nil if node is not a directory
    if (!self.isDirectory)
        return nil;
    NSString *path = [self.filePath stringByAppendingPathComponent:name];
    FileTree *subResource = [[FileTree alloc]init];
    subResource.filePath = path;
    subResource.isDirectory = isDirectory;
    subResource.lastUpdate = [NSDate dateWithString:@"0000-00-00 00:00:00 +0100"];
    [self addContent:subResource];
    return subResource;
}

- (BOOL)containsSubResourceWithName:(NSString *)name
{
    for (FileTree *currentContent in self.content) {
        if ([[currentContent.filePath lastPathComponent]isEqualToString:name])
            return YES;
    }
    return NO;
}

- (FileTree *)resourceWithName:(NSString *)name
{
    for (FileTree *currentContent in self.content) {
        if ([[currentContent.filePath lastPathComponent]isEqualToString:name])
            return currentContent;
    }
    return nil;

}

#pragma mark - NSObject

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"Path: %@, Filename: %@, IsDirecoty: %d, Last update: %@ \n", self.filePath, self.filename, self.isDirectory, self.lastUpdate];
    for (FileTree *contentTree in self.content) {
        description = [description stringByAppendingFormat:@"%@", contentTree];
    }
    return description;
}

@end
