//
//  FileTree.h
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 1/6/13.
//  Copyright (c) 2013 Kevin Brandes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileTree : NSObject

@property (nonatomic) BOOL isDirectory;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSDate *lastUpdate;
@property (nonatomic, readonly) NSString *filename;
@property (nonatomic, strong) NSArray *content;

// Adds a subtree to this tree node
- (void)addContent:(FileTree *)content;
// Gets content (if it contains) with a specific filename. Returns
// nil if tree does not contain expected resource
- (FileTree *)resourceWithName:(NSString *)name;
// Adds a sub directory to this tree node
- (FileTree *)addSubDirectoryWithName:(NSString *)name;
// Adds a sub file to this tree node
- (FileTree *)addSubFileWithName:(NSString *)name;
// checks if there is a sub resource with a specific name
- (BOOL)containsSubResourceWithName:(NSString *)name;
// Adds a sub resource to this tree node
- (FileTree *)addSubResourceWithName:(NSString *)name isDirectory:(BOOL)isDirectory;

@end
