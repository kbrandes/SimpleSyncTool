//
//  GoogleDriveCloudService.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/26/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudService.h"
#import "GTLDrive.h"
#import "GTL/GTMOAuth2WindowController.h"

@interface GoogleDriveCloudService : NSObject <CloudService>

@property (nonatomic, weak) id<CloudServiceDelegate> delegate;
- (id)initWithGoogleDriveCloudService:(NSWindow *)window;

@end

