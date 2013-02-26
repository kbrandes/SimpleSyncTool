//
//  ContentLoader.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/20/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import "ContentLoader.h"

@interface ContentLoader ()
// takes local file tree as reference, completes only uploadable content
- (NSArray *)compareReferenceFileTree:(FileTree *)referenceTree withSecondaryFileTree:(FileTree *)secondaryTree;
@end

@implementation ContentLoader



// takes local file tree as reference, completes only uploadable content
- (NSArray *)compareReferenceFileTree:(FileTree *)referenceTree withSecondaryFileTree:(FileTree *)secondaryTree
{
    NSMutableArray *syncFiles = [[NSMutableArray alloc]init];
    if (referenceTree.isDirectory){
        for (FileTree *referenceContentTree in referenceTree.content) {
            FileTree *secondaryContentTree = [secondaryTree resourceWithName:referenceContentTree.filename];
            if (!secondaryContentTree)
                secondaryContentTree = [secondaryTree addSubResourceWithName:referenceContentTree.filename isDirectory:referenceContentTree.isDirectory];
            if (referenceContentTree.isDirectory) {
                NSArray *objects = [self compareReferenceFileTree:referenceContentTree withSecondaryFileTree:secondaryContentTree];
                [syncFiles addObjectsFromArray:objects];
            } else {
                if ([[referenceContentTree.lastUpdate laterDate:secondaryContentTree.lastUpdate] isEqualToDate:referenceContentTree.lastUpdate]) {
                    NSDictionary *fileDictionary = [NSDictionary dictionaryWithObjectsAndKeys:referenceContentTree.filePath, ReferenceFilePath, secondaryContentTree.filePath, SecondaryFilePath, nil];
                    [syncFiles addObject:fileDictionary];
                }
            }
        }
    } else {
        if ([[referenceTree.lastUpdate laterDate:secondaryTree.lastUpdate] isEqualToDate:referenceTree.lastUpdate]) {
            NSDictionary *fileDictionary = [NSDictionary dictionaryWithObjectsAndKeys:referenceTree.filePath, ReferenceFilePath, secondaryTree.filePath, SecondaryFilePath, nil];
            [syncFiles addObject:fileDictionary];
        }
    }
    return syncFiles;
}


@end
