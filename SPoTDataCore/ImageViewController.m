//
//  ImageViewController.m
//  SPoT
//
//  Created by Marcin Ekonomiuk on 28.04.2013.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "ImageViewController.h"
#import "UIApplication+NetworkActivity.h"

#import "CacheManager.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak,nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation ImageViewController

-(void)setImageURL:(NSURL *)imageURL
{
    _imageURL=imageURL;
    [self resetImage];
}

-(void)resetImage
{
    if(self.scrollView)
    {
        self.scrollView.contentSize=CGSizeZero;
        self.imageView.image=nil;
        [self.spinner startAnimating];
        
        NSURL *imageURL=self.imageURL;
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            [[UIApplication sharedApplication] showNetworkActivityIndicator];
            NSData *imageData;
            CacheManager *cm= [CacheManager sharedInstance];
            imageData=[cm getFromCache:self.imageURL];
            if(imageData == Nil){
                imageData =[[NSData alloc]initWithContentsOfURL:self.imageURL];
                [cm cacheData:imageData url:self.imageURL];
            }
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            UIImage *image = [[UIImage alloc]initWithData:imageData];
            
            if(self.imageURL==imageURL){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(image){
                        self.scrollView.zoomScale=1.0;
                        self.scrollView.contentSize=image.size;
                        self.imageView.image=image;
                        self.imageView.frame=CGRectMake(0,0,image.size.width,image.size.height);
                    }
                    [self makeImageFitInScrollView];
                    [self.spinner stopAnimating];
                });
            }
        });
    }
}

-(UIImageView *)imageView
{
    if(!_imageView) _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    return _imageView;
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale=0.2;
    self.scrollView.maximumZoomScale=5.0;
    self.scrollView.delegate=self;
    [self resetImage];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self makeImageFitInScrollView];
}

-(void)makeImageFitInScrollView{
    if(self.imageView.image){
        // make image fill whole screen
        self.scrollView.zoomScale = 1.0;
        self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
        float xScale = self.scrollView.bounds.size.width/self.imageView.image.size.width;
        float yScale = self.scrollView.bounds.size.height/self.imageView.image.size.height;
        CGRect zoomToRect;
        float xOffset = 0;
        float yOffset = 0;
        if(yScale > xScale){
            xOffset = (self.imageView.bounds.size.width * yScale - self.scrollView.bounds.size.width )/2;
            zoomToRect = CGRectMake(0, 0, 0, self.imageView.image.size.height);
        }else{
            yOffset = (self.imageView.bounds.size.height * xScale - self.scrollView.bounds.size.height )/2;
            zoomToRect = CGRectMake(0, 0, self.imageView.image.size.width, 0);
        }
        [self.scrollView zoomToRect:zoomToRect animated:false];
        self.scrollView.contentOffset = CGPointMake(xOffset , yOffset );
    }
}

@end