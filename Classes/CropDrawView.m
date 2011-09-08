//
//  CropDrawView.m
//  RetinaScan
//
//  Created by Bijan Vaez on 10-10-29.
//  Copyright 2010 University of Toronto. All rights reserved.
//

#import "CropDrawView.h"

@implementation CropDrawView

@synthesize fromPoint, toPoint;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // Initialization code
    }
    return self;
}

-(void) touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
	
	UITouch *touch = [touches anyObject];
	fromPoint      = [touch locationInView:touch.view];
  
	[self setNeedsDisplay];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	
	UITouch *touch = [touches anyObject];
	toPoint        = [touch locationInView:touch.view];
  
	[self setNeedsDisplay];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  // Get the touch points
	UITouch* touch = [touches anyObject];
	toPoint        = [touch locationInView:touch.view];

  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  
  // Disable userInteraction
  self.userInteractionEnabled = FALSE;
  
  // Calculations for keeping the square constrained
  CGFloat width  = fabsf(fromPoint.x - toPoint.x);
  
  if ( width >= 2 )
  { 
    // Before crop, save a copy of current
    CGImageRef currentImage = [[appDelegate.cameraImages.surfaceImage getCurrentSurfaceImage] CGImage];
    UIImage* imageCopy = [[UIImage alloc] initWithCGImage:currentImage];
    
    BOOL cropFinished = [self cropImage:fromPoint:CGPointMake(fromPoint.x + width, fromPoint.y + width)];
    
    if ( cropFinished )
    {
      // Set previous to the current before crop
      [appDelegate.cameraImages.surfaceImage setPreviousSurfaceImage:imageCopy];
      
      // Enable undo button
      appDelegate.viewController.editImageViewController.undoCropButton.enabled = TRUE;
    }
  }

  //Renable the toolbar
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:1.0];
  [appDelegate.viewController.editImageViewController.editImageViewToolbar setAlpha:1.0];
  [UIView commitAnimations];
    
  // Clear the coordinates so that the rectangle is not drawn
  fromPoint = CGPointMake(0,0);
  toPoint   = CGPointMake(0,0);
  
	[self setNeedsDisplay];
}

-(BOOL) cropImage:(CGPoint)startP: (CGPoint)endP
{      
  // AppDelegate
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

  CGRect cropViewFrame  = appDelegate.viewController.editImageViewController.cropView.frame;
  UIImage* image         = [appDelegate.cameraImages.surfaceImage getCurrentSurfaceImage];
  UIImageView* imageView = appDelegate.viewController.editImageViewController.imageView; 
 
  // Sizes of image and imageView
  CGSize imageViewSize = CGSizeMake( cropViewFrame.size.width, cropViewFrame.size.height );
  CGSize imageSize     = CGSizeMake( [image size].width, [image size].height );
  
  // Convert ratio from image to imageView
  CGSize scaledSize  = CGSizeMake( imageSize.width / imageViewSize.width, imageSize.height / imageViewSize.height );
  //CGSize scaledSize  = CGSizeMake( imageSize.width / cropViewFrame.size.width, imageSize.height / cropViewFrame.size.height );

  // Final cropped size converted to image coordinates
  CGSize croppedSize = CGSizeMake( (endP.x - startP.x) * scaledSize.width, (endP.y - startP.y) * scaledSize.height);
  
  // Clipped rectangle converted to image coordinates
  CGRect clippedRect = CGRectMake(startP.x * scaledSize.width, startP.y * scaledSize.height, croppedSize.width, croppedSize.width);

  // Crop the image
  UIImage* croppedImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, clippedRect)];
  
  // Resize Image to 320x320
  croppedImage = [croppedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(320, 320) interpolationQuality:kCGInterpolationHigh];
  
  // Update the current image to the cropped image
  [appDelegate.cameraImages.surfaceImage setCurrentSurfaceImage:croppedImage];
  
  // Update the image displayed and resize it properly
  // Resize the imageView to fit 320x320
  
  imageView.frame = CGRectMake(0, 70, 320, 320);
  
  appDelegate.viewController.editImageViewController.cropView.bounds = CGRectMake(0, 0, 320, 320);
  
  imageView.image = croppedImage;
  
  return TRUE;
}

-(IBAction)cropButtonAction:(id) sender
{
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  
  //Hide the toolbar
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3];
  [appDelegate.viewController.editImageViewController.editImageViewToolbar setAlpha:0.0];
  [UIView commitAnimations];
  
  // User clicks crop  
  // Enable userInteraction to events are caught
  if ( self.isUserInteractionEnabled )
  {
    self.userInteractionEnabled = FALSE; 
  }
  else
  {
    self.userInteractionEnabled = TRUE;
  }

}

-(void)drawRect:(CGRect) rect
{  
  if ( self.userInteractionEnabled == TRUE )
  {
    CGFloat dx = toPoint.x - fromPoint.x;
    CGFloat dy = toPoint.y - fromPoint.y;
    
    // Keeping the square consistant
    CGFloat width  = fabsf(fromPoint.x - toPoint.x);  
    
    if (toPoint.x > 320 && toPoint.y <= self.frame.size.height)
    {
      width = fabsf(fromPoint.x - 320);
    }
    else if ( toPoint.x < self.frame.size.width && toPoint.y > self.frame.size.height )
    {
      width = fabsf(fromPoint.y - self.frame.size.height);
    }  
        
    // Context and rectangle
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect currentRect;
    
    // LineWidth etc
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    // Make rectangle 
    if ( dx > 0.0 && dy > 0.0 )
    {
      currentRect = CGRectMake(fromPoint.x, fromPoint.y, width, width);
    }
    
    // Draw
    CGContextAddRect(context, currentRect);
    CGContextDrawPath(context, kCGPathFillStroke);     
  }
}

- (void)dealloc {
    [super dealloc];
}

@end
