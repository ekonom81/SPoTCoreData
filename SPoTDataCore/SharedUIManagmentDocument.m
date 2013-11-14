//
//  SharedUIManagmentDocument.m
//  SPoTDataCore
//
//  Created by Marcin Ekonomiuk on 14.11.2013.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "SharedUIManagmentDocument.h"

#define DIRECTORY_NAME @"SpotDB"

@implementation SharedUIManagmentDocument

+(SharedUIManagmentDocument*) sharedDocument
{
    __strong static id _sharedObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}


- (id)init
{
    self = [super init];
    if(self) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:DIRECTORY_NAME];
        self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return self;
}

- (void)performWithDocument:(OnDocumentReady)onDocumentReady
{
    void (^OnDocumentDidLoad)(BOOL) = ^(BOOL success) {
        onDocumentReady(self.document);
    };
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) {
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:OnDocumentDidLoad];
    } else if (self.document.documentState == UIDocumentStateClosed) {
        [self.document openWithCompletionHandler:OnDocumentDidLoad];
    } else if (self.document.documentState == UIDocumentStateNormal) {
        OnDocumentDidLoad(YES);
    }
}
@end
