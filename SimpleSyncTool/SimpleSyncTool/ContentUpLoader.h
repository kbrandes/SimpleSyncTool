//
//  ContentUpLoader.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/20/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentLoader.h"
#import "CloudService.h"

@class ContentUpLoader;
@protocol ContentUpLoaderDelegate <NSObject>

@optional
- (void)contentUpLoader:(ContentUpLoader *)upLoader didUploadContentFromSourcePath:(NSString *)sourcePath toDestinationPath:(NSString *)destinationPath;
- (void)contentUpLoader:(ContentUpLoader *)upLoader recognizedError:(NSError *)error whileUploadingContentFromSourcePath:(NSString *)sourcePath toDestinationPath:(NSString *)destinationPath;
- (void)contentUpLoader:(ContentUpLoader *)uploader statusUpdate:(NSString *)status;

@end


@interface ContentUpLoader : ContentLoader

@property (nonatomic, weak) id<ContentUpLoaderDelegate> delegate;

- (void)uploadContentFromSourcePath:(NSString *)sourcePath toDestinationPath:(NSString *)destinationPath withService:(id<CloudService>)service;

@end
