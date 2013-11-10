//
//  CacheManager.h
//  SPoT
//
//  Created by Marcin Ekonomiuk on 18.10.2013.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject
-(NSData*)getFromCache:(NSURL*)url;
-(void)cacheData:(NSData*)data url:(NSURL*)url;
+(id)sharedInstance;
@end
