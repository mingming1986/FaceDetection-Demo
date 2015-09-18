//
//  CameraViewController.m
//  Face
//
//  Created by Mingming Wang on 9/11/15.
//  Copyright (c) 2015 Mingming Wang. All rights reserved.
//

#import "CameraViewController.h"
#import "MBProgressHUD.h"
#import "GestureImageView.h"
#import "ResultViewController.h"

@interface CameraViewController ()

@property (assign, nonatomic) int x_diff;
@property (assign, nonatomic) int y_diff;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    UIImage *resizedImage = [self resizeImage:originalImage scaledToWidth:screenRect.size.width];
    
    [imageView setImage:resizedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Detecting face..."];
    
    [hud show:YES];
    
    [self performSelectorInBackground:@selector(markFaces:) withObject:imageView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*)resizeImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

-(void)markFaces:(UIImageView *)facePicture
{
    CIImage* image = [CIImage imageWithCGImage:facePicture.image.CGImage];
    
    NSDictionary * OPTIONS= [NSDictionary dictionaryWithObject: CIDetectorAccuracyHigh            forKey: CIDetectorAccuracy];
    CIDetector  *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:OPTIONS];
    
    NSDictionary* imageOptions = nil;
    NSArray *features = nil;
    
    int features_count = 0;
    int best_option = -1;
    
    for (int i = 1; i <= 8; i ++)
    {
        imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:i] forKey:CIDetectorImageOrientation];
        
        features = [detector featuresInImage:image options:imageOptions];
        
        if (features.count > features_count) {
            features_count = (int)features.count;
            
            best_option = i;
        }
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (best_option == -1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Can't detect the face from image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    else {
        NSLog(@"%d", best_option);
        
        imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:best_option] forKey:CIDetectorImageOrientation];
        
        features = [detector featuresInImage:image options:imageOptions];
    }
    
    CGFloat aspectRatioX = imageView.bounds.size.width/imageView.image.size.width;
    CGFloat aspectRatioY = imageView.bounds.size.height/(imageView.image.size.height);
    
    CGRect imageRect;
    
    if ( aspectRatioX < aspectRatioY )
        imageRect = CGRectMake(0, (imageView.bounds.size.height - aspectRatioX*imageView.image.size.height)*0.5f, imageView.bounds.size.width, aspectRatioX*imageView.image.size.height);
    else
        imageRect = CGRectMake((imageView.bounds.size.width - aspectRatioY*imageView.image.size.width)*0.5f, 0, aspectRatioY*imageView.image.size.width, imageView.bounds.size.height);
    
    self.x_diff = imageRect.origin.x;
    self.y_diff = imageRect.origin.y;
    
    for(CIFaceFeature* faceFeature in features)
    {
        GestureImageView* faceView = [[GestureImageView alloc] initWithFrame:faceFeature.bounds];
        
        CGRect rect = faceView.frame;
        
        rect.origin.x += self.x_diff;
        rect.origin.y += self.y_diff;
        
        CGFloat sHeight = self.view.frame.size.height;
        
        CGFloat nY = sHeight - rect.origin.y - rect.size.height;
        rect.origin.y = nY;
        
        [faceView setFrame:rect];
        
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        
        [containerView addSubview:faceView];
    }
}

- (void)clear
{
    NSArray *arr=containerView.subviews;
    
    for (UIView *chid in arr)
    {
        [chid removeFromSuperview];
    }
}

- (IBAction)onSelect:(id)sender
{
    UIImage *croppedImage = nil;
    
    if (containerView.subviews.count > 0)
    {
        UIView *view = [containerView.subviews objectAtIndex:0];
        
        croppedImage = [self imageByCropping: view image:imageView.image rect:view.frame];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ResultViewController *resultVC = [storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
    [resultVC setFaceImage:croppedImage];
    
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (UIImage *)imageByCropping: (UIView *) view image: (UIImage *)image rect: (CGRect) rect
{
    rect.origin.x -= self.x_diff;
    rect.origin.y -= self.y_diff;

    
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return newImage;
}

- (UIImage*)rotateUIImage:(UIImage*)sourceImage
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:UIImageOrientationDown] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)onGallery:(id)sender
{
    [self clear];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)onCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Can't use camera." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

@end
