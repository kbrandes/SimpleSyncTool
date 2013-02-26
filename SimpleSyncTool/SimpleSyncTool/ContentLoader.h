//
//  ContentLoader.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/20/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileTree.h"


#define ReferenceFilePath @"ReferenceFilePath"
#define SecondaryFilePath @"SecondaryFilePath"

@interface ContentLoader : NSObject

// takes local file tree as reference, completes only uploadable content
- (NSArray *)compareReferenceFileTree:(FileTree *)referenceTree withSecondaryFileTree:(FileTree *)secondaryTree;

@end
