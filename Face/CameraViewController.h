//
//  CameraViewController.h
//  Face
//
//  Created by Mingming Wang on 9/11/15.
//  Copyright (c) 2015 Mingming Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    IBOutlet UIView *containerView;
    IBOutlet UIImageView *imageView;
}

- (IBAction)onSelect:(id)sender;
- (IBAction)onCamera:(id)sender;
- (IBAction)onGallery:(id)sender;

@end
