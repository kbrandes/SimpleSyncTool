//
//  SyncFile.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/3/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudService.h"

@interface SyncFile : NSObject <NSCopying>

@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *cloudPath;
@property (nonatomic) BOOL isDirectory;

// designated initializer
- (id)initWithLocalPath:(NSString *)localPath cloudPath:(NSString *)cloudPath;
+ (id)syncFileWithLocalPath:(NSString *)local cloudPath:(NSString *)cloudPath;

@end
