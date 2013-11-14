//
//  PhotosTitleCDTVC.m
//  SPoTDataCore
//
//  Created by Marcin Ekonomiuk on 14.11.2013.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "PhotosTitleCDTVC.h"
#import "Photo.h"
#import "FlickrFetcher.h"
#import "UIApplication+NetworkActivity.h"
#import "ImageViewController.h"


@implementation PhotosTitleCDTVC
-(void)setupFetchedResultsController
{
        // abstract
}
#pragma mark - UITableViewDataSource

// Loads up the cell for a given row by getting the associated Photo from our NSFetchedResultsController.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"desc Photo"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    [self addThumbnailImage:photo toCell:cell];
    return cell;
}

-(void) addThumbnailImage:(Photo *)photo toCell:(UITableViewCell *)cell
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *imageData;
        if(!photo.thumbnail){
            [[UIApplication sharedApplication] showNetworkActivityIndicator];
            NSURL *url = [NSURL URLWithString:photo.thumbnailUrl];
            imageData =[[NSData alloc]initWithContentsOfURL:url];
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            
            [photo.managedObjectContext performBlock:^{
                photo.thumbnail=imageData;
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image=[UIImage imageWithData:photo.thumbnail];
            [cell setNeedsLayout];
        });
    });
}

-(void) lastSeePhoto:(Photo*)photo
{
    [photo.managedObjectContext performBlock:^{
        photo.lastSee=[NSDate date];
    }];
    
}

#pragma mark - Segue

// Gets the NSIndexPath of the UITableViewCell which is sender.
// Then uses that NSIndexPath to find the Photographer in question using NSFetchedResultsController.
// Prepares a destination view controller through the "setPhotographer:" segue by sending that to it.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"setImageURL:"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    // FlickrPhotoFormat formatPhoto=FlickrPhotoFormatLarge;
                    //if(self.isRunningOniPad)
                    //   formatPhoto=FlickrPhotoFormatOriginal;
                    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                   
                    NSURL *url = [NSURL URLWithString:photo.imageUrl];
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:photo.title];
                    [self lastSeePhoto:photo];
                }
            }
        }
    }
}

@end
