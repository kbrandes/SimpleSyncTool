//
//  DropboxCloudService.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/26/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudService.h"

@interface DropboxCloudService : NSObject <CloudService>

+ (id)cloudServiceWithAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret;
- (id)initWithAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret;

@property (nonatomic, weak) id<CloudServiceDelegate> delegate;

@end
