#import "AVCamViewController.h"

#if COMPILE_FOR_DEVICE == TRUE

@interface AVCamViewController ()
@property (nonatomic,retain) CALayer *focusBox;
@property (nonatomic,retain) CALayer *exposeBox;
@end

@interface AVCamViewController (InternalMethods)
+ (CGRect)cleanApertureFromPorts:(NSArray *)ports;
+ (CGSize)sizeForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize;
+ (void)addAdjustingAnimationToLayer:(CALayer *)layer removeAnimation:(BOOL)remove;
- (CGPoint)translatePoint:(CGPoint)point fromGravity:(NSString *)gravity1 toGravity:(NSString *)gravity2;
- (void)drawFocusBoxAtPointOfInterest:(CGPoint)point;
- (void)drawExposeBoxAtPointOfInterest:(CGPoint)point;
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
@end


@interface AVCamViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end

@interface AVCamViewController (AVCamPreviewViewDelegate) <AVCamPreviewViewDelegate>
@end

@implementation AVCamViewController

@synthesize editImageViewController;

@synthesize captureManager = _captureManager;
@synthesize stillButton = _stillButton;
@synthesize backButton = _backButton;
@synthesize videoPreviewView = _videoPreviewView;
@synthesize captureVideoPreviewLayer = _captureVideoPreviewLayer;
@synthesize adjustingInfoView = _adjustingInfoView;
@synthesize focusBox = _focusBox;
@synthesize exposeBox = _exposeBox;

- (void) dealloc
{
    [self setCaptureManager:nil];
    [super dealloc];
}

- (void)viewDidLoad {
    NSError *error;
    
	UIApplication *application = [UIApplication sharedApplication];
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
    AVCamCaptureManager *captureManager = [[AVCamCaptureManager alloc] init];
    if ([captureManager setupSessionWithPreset:AVCaptureSessionPresetHigh error:&error]) {
        [self setCaptureManager:captureManager];
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[captureManager session]];
        UIView *view = [self videoPreviewView];
        CALayer *viewLayer = [view layer];
        [viewLayer setMasksToBounds:YES];
		
        CGRect bounds = [view bounds];
        
        [captureVideoPreviewLayer setFrame:bounds];
        
        if ([captureVideoPreviewLayer isOrientationSupported]) {
            [captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [[captureManager session] startRunning];
        
        [self setCaptureVideoPreviewLayer:captureVideoPreviewLayer];
        
        if ([[captureManager session] isRunning]) {
            
            [captureManager setOrientation:AVCaptureVideoOrientationPortrait];
            [captureManager setDelegate:self];
            
            [viewLayer insertSublayer:captureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
            
            [captureVideoPreviewLayer release];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                message:@"Failed to start session."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            [[self stillButton] setEnabled:NO];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Input Device Init Failed"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];        
    }
    
    [captureManager release];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setVideoPreviewView:nil];
    [self setCaptureVideoPreviewLayer:nil];
    [self setAdjustingInfoView:nil];
    [self setStillButton:nil];
    [self setFocusBox:nil];
    [self setExposeBox:nil];
}

#pragma mark Toolbar Actions

- (IBAction)still:(id)sender
{
    [[self captureManager] captureStillImage];
    
    UIView *flashView = [[UIView alloc] initWithFrame:[[self videoPreviewView] frame]];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [flashView setAlpha:0.f];
    [[[self view] window] addSubview:flashView];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:1.f];
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                         [flashView release];
                     }
     ];
}

-(IBAction)goBack:(id) sender
{	
	[self dismissModalViewControllerAnimated:YES];
}

@end

@implementation AVCamViewController (InternalMethods)

+ (CGRect)cleanApertureFromPorts:(NSArray *)ports
{
    CGRect cleanAperture;
    for (AVCaptureInputPort *port in ports) {
        if ([port mediaType] == AVMediaTypeVideo) {
            cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
            break;
        }
    }
    return cleanAperture;
}

+ (CGSize)sizeForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
    
    return size;
}

+ (void)addAdjustingAnimationToLayer:(CALayer *)layer removeAnimation:(BOOL)remove
{
    if (remove) {
        [layer removeAnimationForKey:@"animateOpacity"];
    }
    if ([layer animationForKey:@"animateOpacity"] == nil) {
        [layer setHidden:NO];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacityAnimation setDuration:.3f];
        [opacityAnimation setRepeatCount:1.f];
        [opacityAnimation setAutoreverses:YES];
        [opacityAnimation setFromValue:[NSNumber numberWithFloat:1.f]];
        [opacityAnimation setToValue:[NSNumber numberWithFloat:.0f]];
        [layer addAnimation:opacityAnimation forKey:@"animateOpacity"];
    }
}

- (CGPoint)translatePoint:(CGPoint)point fromGravity:(NSString *)oldGravity toGravity:(NSString *)newGravity
{
    CGPoint newPoint;
    
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    CGSize apertureSize = [AVCamViewController cleanApertureFromPorts:[[[self captureManager] videoInput] ports]].size;
    
    CGSize oldSize = [AVCamViewController sizeForGravity:oldGravity frameSize:frameSize apertureSize:apertureSize];
    
    CGSize newSize = [AVCamViewController sizeForGravity:newGravity frameSize:frameSize apertureSize:apertureSize];
    
    if (oldSize.height < newSize.height) {
        newPoint.y = ((point.y * newSize.height) / oldSize.height) - ((newSize.height - oldSize.height) / 2.f);
    } else if (oldSize.height > newSize.height) {
        newPoint.y = ((point.y * newSize.height) / oldSize.height) + ((oldSize.height - newSize.height) / 2.f) * (newSize.height / oldSize.height);
    } else if (oldSize.height == newSize.height) {
        newPoint.y = point.y;
    }
    
    if (oldSize.width < newSize.width) {
        newPoint.x = (((point.x - ((newSize.width - oldSize.width) / 2.f)) * newSize.width) / oldSize.width);
    } else if (oldSize.width > newSize.width) {
        newPoint.x = ((point.x * newSize.width) / oldSize.width) + ((oldSize.width - newSize.width) / 2.f);
    } else if (oldSize.width == newSize.width) {
        newPoint.x = point.x;
    }
    
    return newPoint;
}

- (void)drawFocusBoxAtPointOfInterest:(CGPoint)point
{
    AVCamCaptureManager *captureManager = [self captureManager];
    if ([captureManager hasFocus]) {
        CGSize frameSize = [[self videoPreviewView] frame].size;
        
        CGSize apertureSize = [AVCamViewController cleanApertureFromPorts:[[[self captureManager] videoInput] ports]].size;
        
        CGSize oldBoxSize = [AVCamViewController sizeForGravity:[[self captureVideoPreviewLayer] videoGravity] frameSize:frameSize apertureSize:apertureSize];
        
        CGPoint focusPointOfInterest = [[[captureManager videoInput] device] focusPointOfInterest];
        CGSize newBoxSize;
        if (focusPointOfInterest.x == .5f && focusPointOfInterest.y == .5f) {
            newBoxSize.width = (116.f / frameSize.width) * oldBoxSize.width;
            newBoxSize.height = (158.f / frameSize.height) * oldBoxSize.height;
        } else {
            newBoxSize.width = (80.f / frameSize.width) * oldBoxSize.width;
            newBoxSize.height = (110.f / frameSize.height) * oldBoxSize.height;
        }
        
        CALayer *focusBox = [self focusBox];
        [focusBox setFrame:CGRectMake(0.f, 0.f, newBoxSize.width, newBoxSize.height)];
        [focusBox setPosition:point];
        [AVCamViewController addAdjustingAnimationToLayer:focusBox removeAnimation:YES];
    }
}

- (void)drawExposeBoxAtPointOfInterest:(CGPoint)point
{
    AVCamCaptureManager *captureManager = [self captureManager];
    if ([captureManager hasExposure]) {
        CGSize frameSize = [[self videoPreviewView] frame].size;
        
        CGSize apertureSize = [AVCamViewController cleanApertureFromPorts:[[[self captureManager] videoInput] ports]].size;
        
        CGSize oldBoxSize = [AVCamViewController sizeForGravity:[[self captureVideoPreviewLayer] videoGravity] frameSize:frameSize apertureSize:apertureSize];
        
        CGPoint exposurePointOfInterest = [[[captureManager videoInput] device] exposurePointOfInterest];
        CGSize newBoxSize;
        if (exposurePointOfInterest.x == .5f && exposurePointOfInterest.y == .5f) {
            newBoxSize.width = (290.f / frameSize.width) * oldBoxSize.width;
            newBoxSize.height = (395.f / frameSize.height) * oldBoxSize.height;
        } else {
            newBoxSize.width = (114.f / frameSize.width) * oldBoxSize.width;
            newBoxSize.height = (154.f / frameSize.height) * oldBoxSize.height;
        }
        
        CALayer *exposeBox = [self exposeBox];
        [exposeBox setFrame:CGRectMake(0.f, 0.f, newBoxSize.width, newBoxSize.height)];
        [exposeBox setPosition:point];
        [AVCamViewController addAdjustingAnimationToLayer:exposeBox removeAnimation:YES];
    }
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates 
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [self captureVideoPreviewLayer];
    
    if ([[self captureVideoPreviewLayer] isMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }    
    
    if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}



@end

@implementation AVCamViewController (AVCamCaptureManagerDelegate)

- (void) captureStillImageFailedWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Still Image Capture Failure"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void) cannotWriteToAssetLibrary
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incompatible with Asset Library"
                                                        message:@"The captured file cannot be written to the asset library. It is likely an audio-only file."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];        
}

- (void) acquiringDeviceLockFailedWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device Configuration Lock Failure"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];    
}

- (void) assetLibraryError:(NSError *)error forURL:(NSURL *)assetURL
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Asset Library Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];    
}

- (void) someOtherError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];    
}

-(void)releaseCameraView
{	
	[self dismissModalViewControllerAnimated:YES];
	
	// Initialize the editImageViewController
	editImageViewController = [[EditImageViewController alloc] init];
	
	// Load the view from xib
	[self presentModalViewController:editImageViewController animated:YES];
}

@end

@implementation AVCamViewController (AVCamPreviewViewDelegate)

- (void)tapToFocus:(CGPoint)point
{
    AVCamCaptureManager *captureManager = [self captureManager];
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:point];
        [captureManager focusAtPoint:convertedFocusPoint];
        [self drawFocusBoxAtPointOfInterest:point];
    }
}

- (void)tapToExpose:(CGPoint)point
{
    AVCamCaptureManager *captureManager = [self captureManager];
    if ([[[captureManager videoInput] device] isExposurePointOfInterestSupported]) {
        CGPoint convertedExposurePoint = [self convertToPointOfInterestFromViewCoordinates:point];
        [[self captureManager] exposureAtPoint:convertedExposurePoint];
        [self drawExposeBoxAtPointOfInterest:point];
    }
}

- (void)resetFocusAndExpose
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    [[self captureManager] focusAtPoint:pointOfInterest];
    [[self captureManager] exposureAtPoint:pointOfInterest];
    
    CGRect bounds = [[self videoPreviewView] bounds];
    CGPoint screenCenter = CGPointMake(bounds.size.width / 2.f, bounds.size.height / 2.f);
    
    [self drawFocusBoxAtPointOfInterest:screenCenter];
    [self drawExposeBoxAtPointOfInterest:screenCenter];
    
    [[self captureManager] setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
}

@end
#endif