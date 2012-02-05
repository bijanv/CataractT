//
//  CataractTViewController.m
//  CataractT
//
//  Created by Branislav Grujic on 1/15/11.
//  Copyright 2011 Bane's Tools. All rights reserved.
//

#import "CataractTViewController.h"
#import "CataractTAppDelegate.h"
#import "ImageProcessingController.h"


@implementation CataractTViewController

// This will generate getter/setter for these buttons
@synthesize captureSurfaceImageButton, captureRedReflexImageButton, runDiagnosisButton;

// EditImageViewController
@synthesize editImageViewController;
@synthesize settingsButton;
@synthesize algorithmRefineViewController, diagnosisViewController;
@synthesize loadFromGalleryButton;

#if COMPILE_FOR_DEVICE == TRUE
@synthesize aVCamViewController;
#endif

-(IBAction) captureSurfaceImage:(id) sender
{
  // Custom Camera to captureSurfaceImage
	pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	NSArray* mediaTypes         = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	pickerController.mediaTypes = mediaTypes;
  
  [self presentModalViewController:pickerController animated:YES];  
}

-(IBAction) loadFromGallery:(id) sender
{
  // Source is photo album
	pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
  
  [self presentModalViewController:pickerController animated:YES];
}

-(IBAction) captureRedReflexImage:(id) sender
{
	
#if COMPILE_FOR_DEVICE == TRUE
	[self presentModalViewController:aVCamViewController animated:NO];
#endif
	/*
  // Custom Camera to captureRedReflexImage
	pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	NSArray* mediaTypes         = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	pickerController.mediaTypes = mediaTypes;
  
  [self presentModalViewController:pickerController animated:YES];*/
}
-(IBAction) runDiagnosis:(id) sender
{
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  if (appDelegate.runtimeVars.THigh == 0)
    appDelegate.runtimeVars.THigh = 0.88;  
  if (appDelegate.runtimeVars.TLow == 0)
    appDelegate.runtimeVars.TLow = 0.5;
  if (appDelegate.runtimeVars.ZMax == 0)
    appDelegate.runtimeVars.ZMax = 1;
  
  if (appDelegate.runtimeVars.switch1 == YES) { // Bulk Image Analysis
	  if (appDelegate.runtimeVars.DebugLog == YES) {
		  [self redirectConsoleLogToDocumentFolder];
	  }
    [self bulkImageAnalysis];
    return;
  }
  
  [self presentModalViewController:diagnosisViewController animated:YES];
  return;   
}

-(void) bulkImageAnalysis {
	NSLog(@"Entering Work Loop\n");
	NSMutableArray *bundleFiles = [[NSMutableArray alloc] init];
	NSString *imagesPath=[[[NSBundle mainBundle] resourcePath] retain];
	NSFileManager *fmanager=[NSFileManager defaultManager];
	NSArray *directoryContents=[fmanager directoryContentsAtPath:imagesPath];
	UIImage *image = nil;
  
  for(NSString *fileName in directoryContents) {
		if( /*([self doesContainSubstring: fileName: @"DilatedPupil"]	|| 
        [self doesContainSubstring: fileName: @"MatureCataract"]) &&*/
        [self doesContainSubstring: fileName: @"_crop"] &&
		![self doesContainSubstring: fileName: @"RedReflex"] &&
 	    ![self doesContainSubstring: fileName: @"lamellar-1"])
		{
			if([[fileName pathExtension] caseInsensitiveCompare:@"png"]==NSOrderedSame ||
			   [[fileName pathExtension] caseInsensitiveCompare:@"jpg"]==NSOrderedSame)
			{
				[bundleFiles addObject:fileName];
				image = [UIImage imageWithContentsOfFile:[imagesPath stringByAppendingPathComponent:fileName]];
				NSLog(@"%s\n",[fileName UTF8String]);

        ImageProcessingController *ipc = [[ImageProcessingController alloc] init];
        [ipc initImageProcessingControllerWithImage:image];
        UInt32 packedRating = [ipc diagnoseAsSurfaceImage];
        NSString *healthySurfaceImage = [NSString stringWithFormat:@"Rating: %d", packedRating];		
        NSLog(@"Healthy: %@", healthySurfaceImage);
        [ipc dealloc];        
			}
		}
	}
	[bundleFiles release];
	[imagesPath release];
	image = NULL;
	NSLog(@"Exited Cleanly\n");
}

-(BOOL)doesContainSubstring:(NSString *) str: (NSString *)substr
{
	NSRange textRange;
	textRange = [[str lowercaseString] rangeOfString:[substr lowercaseString]];
	
	if(textRange.location != NSNotFound)
		return true; //Does contain the substring
  
	return false;
}

-(IBAction) settings:(id) sender
{
  [self presentModalViewController:algorithmRefineViewController animated:YES]; 
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// Store the image
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  
  // jpegRepresentation of the image
  NSData* jpegData = UIImageJPEGRepresentation([self fixImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"]], 0.7f);

  // Create UIImage using compressed image
  [appDelegate.cameraImages.surfaceImage setCurrentSurfaceImage:[[UIImage alloc] initWithData:jpegData]];
  
  // Dismis camera
  [self dismissModalViewControllerAnimated:NO];
  
  // Initialize the editImageViewController
  editImageViewController = [[EditImageViewController alloc] init];
    
  // Load the view from xib
  [self presentModalViewController:editImageViewController animated:YES]; 
}


-(UIImage*) fixImage:(UIImage*) imageToFix
{ 
  // Get CGImage
  CGImageRef imgRef = imageToFix.CGImage;  
  
  // Get the width and height from the CGImage
  CGFloat width = CGImageGetWidth(imgRef);  
  CGFloat height = CGImageGetHeight(imgRef);  
  
  // Identity matrix
  CGAffineTransform transform = CGAffineTransformIdentity;  
  // Bounding rectangle
  CGRect bounds = CGRectMake(0, 0, width, height); 
  
  // Scale ration from bounding triangle to image width
  CGFloat scaleRatio = bounds.size.width / width;  
  CGSize imageSize   = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));  
  
  CGFloat boundHeight;  
  UIImageOrientation orient = imageToFix.imageOrientation;  
  
  
  // Setups the rotation matrix that is used to rotate the image
  switch(orient) {  
      
    case UIImageOrientationUp: //EXIF = 1  
      transform = CGAffineTransformIdentity;  
      break;  
      
    case UIImageOrientationUpMirrored: //EXIF = 2  
      transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);  
      transform = CGAffineTransformScale(transform, -1.0, 1.0);  
      break;  
      
    case UIImageOrientationDown: //EXIF = 3  
      transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);  
      transform = CGAffineTransformRotate(transform, M_PI);  
      break;  
      
    case UIImageOrientationDownMirrored: //EXIF = 4  
      transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);  
      transform = CGAffineTransformScale(transform, 1.0, -1.0);  
      break;  
      
    case UIImageOrientationLeftMirrored: //EXIF = 5  
      boundHeight        = bounds.size.height;  
      bounds.size.height = bounds.size.width;  
      bounds.size.width  = boundHeight;  
      transform          = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);  
      transform          = CGAffineTransformScale(transform, -1.0, 1.0);  
      transform          = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
      break;  
      
    case UIImageOrientationLeft: //EXIF = 6  
      boundHeight        = bounds.size.height;  
      bounds.size.height = bounds.size.width;  
      bounds.size.width  = boundHeight;  
      transform          = CGAffineTransformMakeTranslation(0.0, imageSize.width);  
      transform          = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
      break;  
      
    case UIImageOrientationRightMirrored: //EXIF = 7  
      boundHeight        = bounds.size.height;  
      bounds.size.height = bounds.size.width;  
      bounds.size.width  = boundHeight;  
      transform          = CGAffineTransformMakeScale(-1.0, 1.0);  
      transform          = CGAffineTransformRotate(transform, M_PI / 2.0);  
      break;  
      
    case UIImageOrientationRight: //EXIF = 8  
      boundHeight        = bounds.size.height;  
      bounds.size.height = bounds.size.width;  
      bounds.size.width  = boundHeight;  
      transform          = CGAffineTransformMakeTranslation(imageSize.height, 0.0);  
      transform          = CGAffineTransformRotate(transform, M_PI / 2.0);  
      break;  
      
    default:  
      [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
  }  
  
  // Create context with size of the bounding rectangle
  UIGraphicsBeginImageContext(bounds.size);  
  
  // Get current context
  CGContextRef context = UIGraphicsGetCurrentContext();  
  
  // Read image orientation
  if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) 
  {  
    CGContextScaleCTM(context, -scaleRatio, scaleRatio);  
    CGContextTranslateCTM(context, -height, 0);  
  }  
  else
  {  
    CGContextScaleCTM(context, scaleRatio, -scaleRatio);  
    CGContextTranslateCTM(context, 0, -height);  
  }  
  
  // Apply the transformation matrix
  CGContextConcatCTM(context, transform);  
  
  // Draw the image into the context
  CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);  
  //Get copy of the image from the context
  UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();  
  // Release the context
  UIGraphicsEndImageContext();  
  
  // Return Image
  return imageCopy;
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{

  UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
  UIImage *stretchableButtonImageNormal = [buttonImageNormal 
                                           stretchableImageWithLeftCapWidth:12 topCapHeight:0];
  [captureSurfaceImageButton setBackgroundImage:stretchableButtonImageNormal
                        forState:UIControlStateNormal];
  [captureRedReflexImageButton setBackgroundImage:stretchableButtonImageNormal
                          forState:UIControlStateNormal];
  [loadFromGalleryButton setBackgroundImage:stretchableButtonImageNormal
                                         forState:UIControlStateNormal];
  [runDiagnosisButton setBackgroundImage:stretchableButtonImageNormal
                                         forState:UIControlStateNormal];
  [settingsButton setBackgroundImage:stretchableButtonImageNormal
                            forState:UIControlStateNormal];

  
  UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
  UIImage *stretchableButtonImagePressed = [buttonImagePressed 
                                            stretchableImageWithLeftCapWidth:12 topCapHeight:0];
  [captureSurfaceImageButton setBackgroundImage:stretchableButtonImagePressed
                        forState:UIControlStateHighlighted];
  [captureRedReflexImageButton setBackgroundImage:stretchableButtonImagePressed
                          forState:UIControlStateHighlighted];
  [loadFromGalleryButton setBackgroundImage:stretchableButtonImagePressed
                                       forState:UIControlStateHighlighted];
  [runDiagnosisButton setBackgroundImage:stretchableButtonImagePressed
                                         forState:UIControlStateHighlighted];
  [settingsButton setBackgroundImage:stretchableButtonImagePressed
                            forState:UIControlStateHighlighted];

  
  [super viewDidLoad];
  
  // If the button is disabled then have the text to be red
  [runDiagnosisButton setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
  
  // Disable the buttons
  runDiagnosisButton.enabled = NO;
  
  // Allocate the pickerController
  pickerController = [[UIImagePickerController alloc] init];
  pickerController.allowsEditing = NO;
  pickerController.delegate = self;
  
  if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
  {
    captureRedReflexImageButton.enabled = YES;
    captureSurfaceImageButton.enabled   = YES;
  }
  else
  {
    captureRedReflexImageButton.enabled = NO;
    captureSurfaceImageButton.enabled   = NO;
  }
  
  // Initialize the settings window
  algorithmRefineViewController = [[AlgorithmRefineViewController alloc] init];
  diagnosisViewController = [[DiagnosisViewController alloc] init];
	
	// Initialize the camera window
#if COMPILE_FOR_DEVICE == TRUE
	aVCamViewController = [[AVCamViewController alloc] init];
#endif
  
  // Allocate the runtime variables
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  appDelegate.runtimeVars = [[RuntimeVariables alloc] init];
}


- (void) redirectConsoleLogToDocumentFolder
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	
	NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
	[timeFormat setDateFormat:@"HH-mm-ss"];
	
	NSDate *now = [[NSDate alloc] init];
	
	NSString *theDate = [dateFormat stringFromDate:now];
	NSString *theTime = [timeFormat stringFromDate:now];
	
	
	NSString *newFileName = [theDate stringByAppendingString:@"_"];
	newFileName           = [newFileName stringByAppendingString:theTime];
	
	newFileName    = [newFileName stringByAppendingString:@"_console.log"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *logPath            = [documentsDirectory stringByAppendingPathComponent:newFileName];
	
	NSLog(@"%@\n",logPath);
	freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
	NSLog(@"First Line\n",logPath);
	
	[dateFormat release];
	[timeFormat release];
	[now release];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc
{
  [pickerController release];
  [editImageViewController release];
  [super dealloc];
}

@end
