//
//  RecentPhotosCDTVC.m
//  SPoTDataCore
//
//  Created by Marcin Ekonomiuk on 14.11.2013.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "RecentPhotosCDTVC.h"
#import "SharedUIManagmentDocument.h"

@interface RecentPhotosCDTVC()

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation RecentPhotosCDTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self openDataBase];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if(managedObjectContext){
        [self setupFetchedResultsController];
    }
    else{
        self.fetchedResultsController = nil;
    }
}

- (void)setupFetchedResultsController
{
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastSee" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"lastSee != nil"];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}
- (void)openDataBase
{
    if(!self.managedObjectContext) {
        [[SharedUIManagmentDocument sharedDocument] performWithDocument:^(UIManagedDocument *document) {
            self.managedObjectContext = document.managedObjectContext;
        }];
    }
}
@end
