//
//  EditImageViewController.m
//  CataractT
//
//  Created by Branislav Grujic on 1/16/11.
//  Copyright 2011 Bane's Tools. All rights reserved.
//

#import "EditImageViewController.h"

@implementation EditImageViewController
@synthesize imageView, editImageViewToolbar, cropView;
@synthesize cropImageButton, retakeImageButton, useImageButton, undoCropButton;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  
  // Transparent toolbar
  [editImageViewToolbar setBarStyle:2];
  
  // You need to change the cropview size to be the same as the imageview...
  // Resize the views according to calculation -> only the cropdraw view really
  CGFloat width = [appDelegate.cameraImages.surfaceImage getCurrentSurfaceImage].size.width;
  CGFloat height = [appDelegate.cameraImages.surfaceImage getCurrentSurfaceImage].size.height;
  
  CGFloat imageRatio          = width / height;
  CGFloat iphoneImageRatio    = 1936.0 / 2592.0;
  CGFloat iphoneImageRatioINV = 2592.0 / 1936.0;
  CGFloat iphoneImageRatioFrontCam    = 480.0 / 640.0;
  CGFloat iphoneImageRatioFrontCamINV = 640.0 / 480.0;
  
  // Preset values
  CGFloat widthPreset = 320.0;
  CGFloat heightPreset = 320.0 / imageRatio;
  
  if (imageRatio == iphoneImageRatio || imageRatio == iphoneImageRatioINV || imageRatio == iphoneImageRatioFrontCam || imageRatio == iphoneImageRatioFrontCamINV)
  {
    // This is an iPhone resolution picture you dont need to resize crop view  
  }
  else
  {
    CGRect rect = CGRectMake(0, ( 460.0 - heightPreset ) / 2.0, 320, heightPreset);
    
    self.view.frame = rect;
    self.cropView.frame = rect;
  }
  
  // Displayed Image is resized so it fits, but image in memory is not
  UIImage* surfaceImage = [appDelegate.cameraImages.surfaceImage getCurrentSurfaceImage];
  surfaceImage = [surfaceImage resizedImage:CGSizeMake(widthPreset, heightPreset) interpolationQuality:kCGInterpolationHigh];
  
  self.imageView.image = surfaceImage;
}

-(IBAction) undoCrop:(id) sender
{
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  
  // Check to make sure both are not null
  UIImage* prevSurfaceImage = [appDelegate.cameraImages.surfaceImage getPreviousSurfaceImage];
  UIImage* currSurfaceImage = [appDelegate.cameraImages.surfaceImage getCurrentSurfaceImage];
  
  if ( prevSurfaceImage != NULL && currSurfaceImage != NULL)
  {
    // Set the current one to be the previous one
    [appDelegate.cameraImages.surfaceImage setCurrentSurfaceImage:prevSurfaceImage];
           
    // Setup the frame again properly
    CGFloat width = [appDelegate.cameraImages.surfaceImage getPreviousSurfaceImage].size.width;
    CGFloat height = [appDelegate.cameraImages.surfaceImage getPreviousSurfaceImage].size.height;
    
    CGFloat imageRatio          = width / height;
    
    CGFloat iphoneImageRatio    = 1936.0 / 2592.0;
    CGFloat iphoneImageRatioINV = 2592.0 / 1936.0;
    CGFloat iphoneImageRatioFrontCam    = 480.0 / 640.0;
    CGFloat iphoneImageRatioFrontCamINV = 640.0 / 480.0;
    
    // Preset values
    CGFloat widthPreset = 320.0;
    CGFloat heightPreset = 320.0 / imageRatio;
    
    if (imageRatio == iphoneImageRatio || imageRatio == iphoneImageRatioINV || imageRatio == iphoneImageRatioFrontCam || imageRatio == iphoneImageRatioFrontCamINV)
    {
      // Restore to original coordinates
      self.cropView.frame  = CGRectMake( 0, 16, 320, 428 );
      self.cropView.bounds = CGRectMake( 0, 0, 320, 428 );
    }
    else
    {
      self.cropView.frame  = CGRectMake( 0, ( 460.0 - heightPreset ) / 2.0, 320, heightPreset );
      self.cropView.bounds = CGRectMake( 0, 0, 320, heightPreset );
    }
    
    UIImage* surfaceImage = [appDelegate.cameraImages.surfaceImage getCurrentSurfaceImage];
    surfaceImage = [surfaceImage resizedImage:CGSizeMake(widthPreset, heightPreset) interpolationQuality:kCGInterpolationHigh];
    
    // Disable the button
    self.undoCropButton.enabled = FALSE;
    
    self.imageView.image = surfaceImage;    
  }
}

-(IBAction) retakeImage:(id) sender
{
  // Dismiss the view
  [self dismissModalViewControllerAnimated:YES];
}
-(IBAction) cropImage:(id) sender
{
}
-(IBAction) useImage:(id) sender
{
  // Enable the runDiagnosis button and then dismiss the view
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  appDelegate.viewController.runDiagnosisButton.enabled = YES;
  
  // Reset cropView sizes
  CGRect rect = CGRectMake(0, 16, 320, 428);
  self.cropView.frame  = rect;
  self.cropView.bounds = rect;
  
  [self dismissModalViewControllerAnimated:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
  [imageView release];
}


- (void)dealloc {
    [super dealloc];
}


@end
