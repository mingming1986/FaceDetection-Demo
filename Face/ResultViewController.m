//
//  ResultViewController.m
//  Face
//
//  Created by Mingming Wang on 9/11/15.
//  Copyright (c) 2015 Mingming Wang. All rights reserved.
//

#import "ResultViewController.h"
#import "GestureImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface ResultViewController ()

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addFace];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addFace
{
    self.imageView = [[GestureImageView alloc] initWithFrame:CGRectMake(30, 60, self.faceImage.size.width, self.faceImage.size.height)];
    
    [self.imageView setImage:self.faceImage];
    
    [self setRoundedView:self.imageView];
    
    [containerView addSubview:self.imageView];
}

-(void)setRoundedView:(GestureImageView *)roundedView;
{
    CGPoint saveCenter = roundedView.center;
    roundedView.layer.cornerRadius = roundedView.frame.size.width / 2.0;
    roundedView.center = saveCenter;
    roundedView.clipsToBounds = YES;
}

- (IBAction)onShare:(id)sender
{
    [controlView setAlpha:0];
    
    self.finalImage = [self captureScreenOfDevice];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Post an image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to camera roll", nil];
    
    [actionSheet showInView:self.view];
    
    [controlView setAlpha:1];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 3)
        return;
    
    switch (buttonIndex) {
        case 0:
            UIImageWriteToSavedPhotosAlbum(self.finalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
            break;
        default:
            break;
    }
}

-(void) image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *) captureScreenOfDevice
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return capturedScreen;
}

- (IBAction)onCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
