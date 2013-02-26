//
//  MainMenuController.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/2/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import "MainMenuController.h"
#import "CloudSynchronizer.h"
#import "DropboxCloudService.h"


@interface MainMenuController ()

@property (nonatomic, weak) IBOutlet NSMenuItem *lastUpdateMenuItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *foldersMenuItem;
@property (nonatomic, strong) CloudSynchronizer *dropboxSynchronizer;

@end
@implementation MainMenuController


- (void)awakeFromNib
{
    [self setupObject];
}

- (IBAction)aboutItemClicked:(NSMenuItem *)sender
{
    
}

- (IBAction)settingsItemClicked:(NSMenuItem *)sender
{
    
}

- (IBAction)syncItemClicked:(NSMenuItem *)sender
{
    [self.dropboxSynchronizer sync];
}

- (void)setupObject
{
    // initialize dropbox synchronizer
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionSettings" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *appKey = [dict objectForKey:@"DropboxAppKey"];
    NSString *appSecret = [dict objectForKey:@"DropboxAppSecret"];
    DropboxCloudService *service = [DropboxCloudService cloudServiceWithAppKey:appKey andAppSecret:appSecret];
    self.dropboxSynchronizer = [[CloudSynchronizer alloc]initWithCloudService:service];
    [service authenticate];
}

@end
