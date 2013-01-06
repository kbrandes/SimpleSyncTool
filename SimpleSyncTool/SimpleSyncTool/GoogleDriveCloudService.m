//
//  GoogleDriveCloudService.m
//  SimpleSyncTool
//
//  Created by Kevin Brandes on 12/26/12.
//  Copyright (c) 2012 Kevin Brandes. All rights reserved.
//

#import "GoogleDriveCloudService.h"
#import "GTL/GTLUtilities.h"
#import "GTL/GTMHTTPFetcherLogging.h"

static NSString *const kKeychainItemName = @"Google Drive Test";
static NSString *const kClientID = @"649976549881.apps.googleusercontent.com";
static NSString *const kClientSecret = @"6cwhrofN_qjgSvTQ2ATgYBLf";

@interface GoogleDriveCloudService ()
@property (nonatomic, weak) NSWindow *window;
@property (nonatomic, strong) GTLServiceDrive *driveService;
@property (nonatomic, strong) NSMutableArray *childrenFiles;
@property (nonatomic, strong) NSArray *pathElements;
@property (nonatomic) int numberOfDataToLoad;
@property (nonatomic) int numberOfLevels;
@property (nonatomic) int actualLevelIndex;
@end

@implementation GoogleDriveCloudService

- (id)initWithGoogleDriveCloudService:(NSWindow *)window
{
    self = [super init];
    if(self){
        self.window = window;
    }
    return self;
    
}

- (void)authenticate
{
    if([self isSignedIn]) return;
    self.driveService = [[GTLServiceDrive alloc] init];
    
    // Authorizer via Login bei Google
    //[self runSigninWebView];
    
    // Authorizer aus dem Schlüsselbund
    self.driveService.authorizer = [GTMOAuth2WindowController authForGoogleFromKeychainForName: kKeychainItemName clientID:kClientID clientSecret:kClientSecret];
}

- (void)loadContentOfCloudPath:(NSString *)path
{
    unichar lastChar = [path characterAtIndex:path.length -1];
    if(lastChar == '/') path = [path substringToIndex:path.length-1];
    
    self.pathElements = [path pathComponents];
    self.numberOfLevels = self.pathElements.count;
    self.actualLevelIndex = 0;
    [self getChildrenIdsAtId:@"root"];
}

- (void)uploadFileFromLocalPath:(NSString *)localPath toCloudPath:(NSString *)cloudPath
{
    [self uploadFileAtPath:localPath];
}

- (void)downloadFileFromCloudPath:(NSString *)cloudPath toLocalPath:(NSString *)localPath
{
    
}

- (void)runSigninWebView
{
    // Show the OAuth 2 sign-in controller
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[GTMOAuth2WindowController class]];
    GTMOAuth2WindowController *windowController;
    
    // Applications that only need to access files created by this app should
    // use kGTLAuthScopeDriveFile.
    windowController = [GTMOAuth2WindowController controllerWithScope:kGTLAuthScopeDrive
                                                             clientID:kClientID
                                                         clientSecret:kClientSecret
                                                     keychainItemName:kKeychainItemName
                                                       resourceBundle:frameworkBundle];
    
    [windowController signInSheetModalForWindow:[self window]
                              completionHandler:^(GTMOAuth2Authentication *auth,
                                                  NSError *error) {
                                  // Callback
                                  if (error == nil) {
                                      self.driveService.authorizer = auth;
                                  } else {
                                      
                                  }
                              }];
}

- (BOOL)isSignedIn
{
    NSString *name = [self signedInUsername];
    return (name != nil);
}
- (NSString *)signedInUsername {
    // Get the email address of the signed-in user.
    GTMOAuth2Authentication *auth = self.driveService.authorizer;
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn) {
        return auth.userEmail;
    } else {
        return nil;
    }
}

#pragma mark Tests Google Drive

- (void)getChildrenIdsAtId:(NSString *)identifier
{
    GTLQueryDrive *query =
    [GTLQueryDrive queryForChildrenListWithFolderId:identifier];
    // queryTicket can be used to track the status of the request.
    GTLServiceTicket *queryTicket =
    [self.driveService executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveChildList *children, NSError *error) {
                      if (error == nil) {
                          [self getChildrenDetails:children];
                      } else {
                          NSLog(@"An error occurred: %@", error);
                      }
                  }];
    queryTicket = nil;
}

- (void)getChildrenDetails:(GTLDriveChildList *)children
{
    self.childrenFiles = [[NSMutableArray alloc] init];
    NSArray *items = children.items;
    self.numberOfDataToLoad = items.count;
    for(GTLDriveChildReference *forChildReference in items){
        [self getFileDetailsFromIdAndAddToArray:forChildReference.identifier toArray:self.childrenFiles];
    }
}

- (void)getFileDetailsFromIdAndAddToArray:(NSString *)fileId toArray:(NSMutableArray *)array
{
    GTLQuery *query = [GTLQueryDrive queryForFilesGetWithFileId:fileId];
    GTLServiceTicket *queryTicket =
    [self.driveService executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *file,
                                      NSError *error) {
                      if (error == nil) {
                          [array addObject:file];
                          self.numberOfDataToLoad--;
                          if(self.numberOfDataToLoad == 0) [self finishedLoadData];
                      } else {
                          NSLog(@"An error occurred: %@", error);
                      }
                  }];
}

- (void)finishedLoadData
{
    if((self.numberOfLevels -1) != self.actualLevelIndex){
        self.actualLevelIndex++;
        NSString *nextId = [self nextFileId];
        [self getChildrenIdsAtId:nextId];
    }else{
        // stop loading more levels
        for(GTLDriveFile *forFile in self.childrenFiles){
            NSLog(@"%@", forFile.title);
        }
    }
}

- (NSString *)nextFileId
{
    NSString *nextElementInPath = self.pathElements[self.actualLevelIndex];
    for(GTLDriveFile *forFile in self.childrenFiles){
        if([forFile.title isEqualToString:nextElementInPath]){
            NSLog(@"%@", forFile.title);
            return forFile.identifier;
        }
    }
    return nil; // exception if file doesnt exists
}




#pragma mark - Upload
- (void)uploadFileAtPath:(NSString *)path {
    // Queries that support file uploads take an uploadParameters object.
    // The uploadParameters include the MIME type of the file being uploaded,
    // and either an NSData with the file contents, or an NSFileHandler for
    // the file path.
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (fileHandle) {
        GTLServiceDrive *service = self.driveService;
        
        NSString *filename = [path lastPathComponent];
        NSString *mimeType = [self MIMETypeFileName:filename
                                    defaultMIMEType:@"binary/octet-stream"];
        GTLUploadParameters *uploadParameters =
        [GTLUploadParameters uploadParametersWithFileHandle:fileHandle
                                                   MIMEType:mimeType];
        GTLDriveFile *newFile = [GTLDriveFile object];
        newFile.title = filename;
        
        GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:newFile
                                                           uploadParameters:uploadParameters];
        GTLServiceTicket *_uploadFileTicket = [service executeQuery:query
                                completionHandler:^(GTLServiceTicket *ticket,
                                                    GTLDriveFile *uploadedFile,
                                                    NSError *error) {
                                    // Callback
                                    if (error == nil) {
                                       // [self displayAlert:@"Created"
                                        //            format:@"Uploaded file \"%@\"",
                                      //   uploadedFile.title];
                                       // [self fetchFileList];
                                    } else {
                                        //[self displayAlert:@"Upload Failed"
                                       //             format:@"%@", error];
                                    }
//                                    [_uploadProgressIndicator setDoubleValue:0.0];
//                                    [self updateUI];
                                }];
        
//        NSProgressIndicator *uploadProgressIndicator = _uploadProgressIndicator;
//        _uploadFileTicket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
//                                                  unsigned long long numberOfBytesRead,
//                                                  unsigned long long dataLength) {
//            [uploadProgressIndicator setMaxValue:(double)dataLength];
//            [uploadProgressIndicator setDoubleValue:(double)numberOfBytesRead];
//        };
//        [self updateUI];
    } else {
        // Could not read file data.
        //[self displayAlert:@"No Upload File Found" format:@"Path: %@", path];
    }
}

- (NSString *)MIMETypeFileName:(NSString *)path
               defaultMIMEType:(NSString *)defaultType {
    NSString *result = defaultType;
    NSString *extension = [path pathExtension];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)extension, NULL);
    if (uti) {
        CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        if (cfMIMEType) {
            result = CFBridgingRelease(cfMIMEType);
        }
        CFRelease(uti);
    }
    return result;
}

@end
