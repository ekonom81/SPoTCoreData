//
//  UIApplication+NetworkActivity.m
//  SPoT
//
//  Created by Marcin Ekonomiuk on 23.07.2013.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "UIApplication+NetworkActivity.h"

static NSInteger activityCount = 0;
@implementation UIApplication(NetworkActivity)

- (void)showNetworkActivityIndicator {
    if (![[UIApplication sharedApplication] isStatusBarHidden])
        @synchronized ([UIApplication sharedApplication]) {
            if (activityCount++ == 0)
                self.networkActivityIndicatorVisible = YES;
        }
}

- (void)hideNetworkActivityIndicator {
    if (![[UIApplication sharedApplication] isStatusBarHidden])
        @synchronized ([UIApplication sharedApplication]) {
            if (--activityCount <= 0) {
                self.networkActivityIndicatorVisible = NO;
                activityCount = 0;
            }
        }
}

@end
