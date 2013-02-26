//
//  ContentDownLoader.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/26/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import "ContentLoader.h"

@class ContentDownLoader;
@protocol ContentDownLoaderDelegate <NSObject>

@optional
- (void)contentDownLoader:(ContentDownLoader *)downLoader didDownlaodContentFromSourcePath:(NSString *)sourcePath toDestinationPath:(NSString *)destinationPath;
- (void)contentDownLoader:(ContentDownLoader *)downLoader recognizedError:(NSError *)error whileDownloadingContentFromSourcePath:(NSString *)sourcePath toDestinationPath:(NSString *)destinationPath;
- (void)contentDownLoader:(ContentDownLoader *)uploader statusUpdate:(NSString *)status;

@end

@interface ContentDownLoader : ContentLoader

@end
