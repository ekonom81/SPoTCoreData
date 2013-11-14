//
//  SharedUIManagmentDocument.h
//  SPoTDataCore
//
//  Created by Marcin Ekonomiuk on 14.11.2013.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^OnDocumentReady) (UIManagedDocument *document);

@interface SharedUIManagmentDocument : NSObject

@property (strong,nonatomic) UIManagedDocument *document;

+(SharedUIManagmentDocument*) sharedDocument;
- (void)performWithDocument:(OnDocumentReady)onDocumentReady;
@end
