//
//  CloudService.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/26/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CloudServiceDelegate <NSObject>

- (void)didLoadContent:(NSArray *)content ofPath:(NSString *)path;
- (void)didUploadFileFrom:(NSString *)localPath to:(NSString *)cloudPath;
- (void)didDownloadFileFrom:(NSString *)cloudPath to:(NSString *)localPath;

@end


@protocol CloudService <NSObject>

- (void)loadContentOfPath:(NSString *)path;
- (void)uploadFileFrom:(NSString *)localPath to:(NSString *)cloudPath;
- (void)downloadFileFrom:(NSString *)cloudPath to:(NSString *)localPath;

@property (nonatomic, weak) id<CloudServiceDelegate> delegate;

@end
