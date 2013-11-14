//
//  PhotosByTagCDTVC.h
//  SPoTDataCore
//
//  Created by Marcin Ekonomiuk on 11.11.2013.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "PhotosTitleCDTVC.h"
#import "Tag.h"

@interface PhotosByTagCDTVC : PhotosTitleCDTVC
    @property (nonatomic, strong) Tag *tag;
@end
