//
//  CacheManager.m
//  SPoT
//
//  Created by Marcin Ekonomiuk on 18.10.2013.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "CacheManager.h"

#define CACHE_DIRECTORY_NAME @"Images/"
#define MAX_CACHE_SIZE 3 * 1048576
#define MAX_CACHE_IPAD_FACTOR 4

@interface CacheManager()
@property (strong,nonatomic) NSString *cacheDirectory;
@property (strong,nonatomic) NSFileManager *fileManager;
@property (nonatomic, readwrite) NSUInteger cacheSize;
@property (nonatomic, readwrite) NSUInteger maxCacheSize;
@property (nonatomic, getter = isRunningOniPad) BOOL runningOniPad;

@end

@implementation CacheManager

-(NSData*)getFromCache:(NSURL*)url
{
    NSString *urlStr=[[url path] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *urlWithPath = [self.cacheDirectory stringByAppendingPathComponent:urlStr];
    
    if([self.fileManager fileExistsAtPath:urlWithPath]){
        NSLog(@"urlWithPath exist : %@",urlWithPath);
        return [self.fileManager contentsAtPath:urlWithPath];
    }
    
    return nil;
}
-(void)cacheData:(NSData*)data url:(NSURL*)url{
    NSString *urlStr=[[url path] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *urlWithPath = [self.cacheDirectory stringByAppendingPathComponent:urlStr];
    
    NSArray *directoryContents = [self.fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.cacheDirectory]
                                                 includingPropertiesForKeys:@[NSURLContentAccessDateKey]
                                                                    options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    NSMutableArray *contentFilesSortedByLastAccessDateNewerToOlderArray = [[directoryContents sortedArrayUsingComparator: ^(NSURL* url1, NSURL* url2) {
        NSDate *date1 = [url1 resourceValuesForKeys:@[NSURLContentAccessDateKey] error:nil][NSURLContentAccessDateKey];
        NSDate *date2 = [url2 resourceValuesForKeys:@[NSURLContentAccessDateKey] error:nil][NSURLContentAccessDateKey];
        
        return [date2 compare: date1];
        
    }] mutableCopy];
    
    while (self.cacheSize >= self.maxCacheSize && directoryContents.count > 0) {
        NSLog(@"cachSize: %i , maxCacheSize: %i , directoryContents.count: %lu ",self.cacheSize, self.maxCacheSize, (unsigned long)directoryContents.count);
        
        NSError *hardimitzn = nil;
        if (![self.fileManager removeItemAtURL:[contentFilesSortedByLastAccessDateNewerToOlderArray lastObject] error:&hardimitzn]) NSLog(@"%@", [hardimitzn localizedDescription]);
        else [contentFilesSortedByLastAccessDateNewerToOlderArray removeLastObject];
    }
    
    if(![self.fileManager fileExistsAtPath:urlWithPath])
    {
        [self.fileManager createFileAtPath:urlWithPath contents:data attributes:Nil];
    }
}


-(NSString*) cacheDirectory{
    
    if(!_cacheDirectory){
             
        NSURL *baseCacheURL = [self.fileManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *cachedImagesURL = [baseCacheURL URLByAppendingPathComponent:CACHE_DIRECTORY_NAME];
  
        NSError *error = nil;
        NSString *cachedImagesStr=[cachedImagesURL path];
    
        if(![self.fileManager fileExistsAtPath:cachedImagesStr])
        {
            if(![self.fileManager createDirectoryAtPath:cachedImagesStr withIntermediateDirectories:YES attributes:Nil error:&error])
            {
                NSLog(@"Failed to create directory \"%@\". Error: %@", cachedImagesStr, error);
            }
        }
        _cacheDirectory=cachedImagesStr;
    }
    return _cacheDirectory;
}

-(NSFileManager*) fileManager{
    
    if(!_fileManager){
        _fileManager =[NSFileManager defaultManager];
    }
    
    return _fileManager;
}
- (NSUInteger)maxCacheSize
{
    if (!_maxCacheSize) _maxCacheSize = self.isRunningOniPad ? MAX_CACHE_SIZE * MAX_CACHE_IPAD_FACTOR : MAX_CACHE_SIZE;
    return _maxCacheSize;
}

- (NSUInteger)cacheSize{
    
    NSUInteger fileSize = floor(M_1_PI*10000000);
    
    if (self.cacheDirectory != nil) {
        fileSize = 0;
        //NSArray *filesArray = [self.fileManager subpathsOfDirectoryAtPath:self.cacheDirectory error:nil];  ?!
        NSArray *filesArray = [self.fileManager contentsOfDirectoryAtPath:self.cacheDirectory error:nil];
        NSString *fileName;
        
        for (fileName in filesArray) {
            NSDictionary *fileDictionary = [self.fileManager attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:fileName] error:nil];
            fileSize += [fileDictionary fileSize];
        }
    }
    NSLog(@"cacheSize: %d", fileSize);
    return fileSize;
}

+ (id)sharedInstance
{
    __strong static id _sharedObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}
- (BOOL)isRunningOniPad
{
    if (!_runningOniPad) _runningOniPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    return _runningOniPad;
}
@end
