//
//  SyncFile.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/3/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import "SyncFile.h"

@interface SyncFile ()

@end
@implementation SyncFile

#pragma mark - Initializers

// Designated initializer
- (id)initWithLocalPath:(NSString *)localPath cloudPath:(NSString *)cloudPath
{
    self = [super init];
    if (self) {
        self.cloudPath = cloudPath;
        self.localPath = localPath;
    }
    return self;
}

+ (id)syncFileWithLocalPath:(NSString *)localPath cloudPath:(NSString *)cloudPath
{
    return [[self alloc]initWithLocalPath:localPath cloudPath:cloudPath];
}

#pragma mark - NSCopying Protocol
- (id)copyWithZone:(NSZone *)zone
{
    SyncFile *copyFile = [SyncFile syncFileWithLocalPath:self.localPath cloudPath:self.cloudPath];
    return copyFile;
}

#pragma mark - NSObject


- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    } else {
        return [self isEqualToSyncFile:other];
    }
}

- (BOOL)isEqualToSyncFile:(SyncFile *)file
{
    if (self == file || ([self.localPath isEqualToString:file.localPath] && [self.cloudPath isEqualToString:file.cloudPath])) {
        return YES;
    } else {
        return NO;
    }
}


@end
