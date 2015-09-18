//
//  ResultViewController.h
//  Face
//
//  Created by Mingming Wang on 9/11/15.
//  Copyright (c) 2015 Mingming Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GestureImageView;

@interface ResultViewController : UIViewController <UIActionSheetDelegate>
{
    IBOutlet UIView *containerView;
    IBOutlet UIView *controlView;
    
    IBOutlet UIImageView *bodyImageView;
}

@property (nonatomic, strong) UIImage *faceImage;
@property (nonatomic, strong) UIImage *finalImage;

@property (nonatomic, strong) GestureImageView *imageView;

- (IBAction)onShare:(id)sender;
- (IBAction)onCancel:(id)sender;

@end
