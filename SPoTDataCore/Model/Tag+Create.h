//
//  Tag+Create.h
//  SPoTDataCore
//
//  Created by Marcin Ekonomiuk on 10.11.2013.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *)tagWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;

@end
