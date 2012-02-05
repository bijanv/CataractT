
#import "AVCamCaptureManager.h"

#if COMPILE_FOR_DEVICE == TRUE

@interface AVCamCaptureManager ()
 
@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,retain) id deviceConnectedObserver;
@property (nonatomic,retain) id deviceDisconnectedObserver;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundRecordingID;

@end

@interface AVCamCaptureManager (Internal)

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) backFacingCamera;

@end

@implementation AVCamCaptureManager

@synthesize session = _session;
@synthesize orientation = _orientation;
@dynamic sessionPreset;
@synthesize videoInput = _videoInput;
@dynamic torchMode;
@dynamic focusMode;
@dynamic exposureMode;
@dynamic whiteBalanceMode;
@synthesize stillImageOutput = _stillImageOutput;
@synthesize deviceConnectedObserver = _deviceConnectedObserver;
@synthesize deviceDisconnectedObserver = _deviceDisconnectedObserver;
@synthesize backgroundRecordingID = _backgroundRecordingID;
@synthesize delegate = _delegate;

- (id) init
{
    self = [super init];
    if (self != nil) {
        void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
            AVCaptureSession *session = [self session];
            AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
            
            [session beginConfiguration];

            [session removeInput:[self videoInput]];
            if ([session canAddInput:newVideoInput]) {
                [session addInput:newVideoInput];
            }
            [session commitConfiguration];
            
            [self setVideoInput:newVideoInput];
            [newVideoInput release];
                                 
            if (![session isRunning])
                [session startRunning];
        };
        void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
            AVCaptureSession *session = [self session];
            
            [session beginConfiguration];
            
            if (![[[self videoInput] device] isConnected])
                [session removeInput:[self videoInput]];
                
            [session commitConfiguration];
                                    
            if (![session isRunning])
                [session startRunning];
        };
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
        [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];            
    }
    return self;
}


- (void) dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:[self deviceConnectedObserver]];
    [notificationCenter removeObserver:[self deviceDisconnectedObserver]];
    [self setDeviceConnectedObserver:nil];
    [self setDeviceDisconnectedObserver:nil];

    [[self session] stopRunning];
    [self setSession:nil];
    [self setVideoInput:nil];
    [self setStillImageOutput:nil];
    [super dealloc];
}

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error
{
    BOOL success = NO;
    
    // Init the device inputs
    AVCaptureDeviceInput *videoInput = [[[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:error] autorelease];
    [self setVideoInput:videoInput];
        
    // Setup the default file outputs
    AVCaptureStillImageOutput *stillImageOutput = [[[AVCaptureStillImageOutput alloc] init] autorelease];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [outputSettings release];
    [self setStillImageOutput:stillImageOutput];
        
    // Add inputs and output to the capture session, set the preset, and start it running
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
    if ([session canAddOutput:stillImageOutput]) {
        [session addOutput:stillImageOutput];
    }
    
    [self setSessionPreset:sessionPreset];
    
    [self setSession:session];
    
    [session release];
    
    success = YES;
        
    return success;
}

- (void) captureStillImage
{
    AVCaptureConnection *videoConnection = [AVCamCaptureManager connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:[self orientation]];
    }
	
	[self setTorchMode:AVCaptureTorchModeOn];
	[NSThread sleepForTimeInterval:0.05];
	//sleep(1);
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                             if (imageDataSampleBuffer != NULL) {
                                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                 UIImage *image = [[UIImage alloc] initWithData:imageData];
																															 /*
																															 // Store the image
																															 CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
																															 
																															 // jpegRepresentation of the image
																															 //NSData* jpegData = UIImageJPEGRepresentation([self fixImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"]], 0.7f);
																															 
																															 // Create UIImage using compressed image
																															 appDelegate.surfaceImage = [[UIImage alloc] initWithData:imageData];
																															 
																															 // Dismis camera
																															 id delegate = [self delegate];
																															 if ([delegate respondsToSelector:@selector(releaseCameraView)]) {
																																 [delegate releaseCameraView];
																															 }*/
																															
                                                                 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                                                 [library writeImageToSavedPhotosAlbum:[image CGImage]
                                                                                           orientation:(ALAssetOrientation)[image imageOrientation]
                                                                                       completionBlock:^(NSURL *assetURL, NSError *error){
                                                                                           if (error) {
                                                                                               id delegate = [self delegate];
                                                                                               if ([delegate respondsToSelector:@selector(captureStillImageFailedWithError:)]) {
                                                                                                   [delegate captureStillImageFailedWithError:error];
                                                                                               }                                                                                               
                                                                                           }
                                                                                       }];
                                                                 [library release];
                                                                 [image release];
                                                             } else if (error) {
                                                                 id delegate = [self delegate];
                                                                 if ([delegate respondsToSelector:@selector(captureStillImageFailedWithError:)]) {
                                                                     [delegate captureStillImageFailedWithError:error];
                                                                 }
                                                             }
                                                         }];
	[self setTorchMode:AVCaptureTorchModeOff];
}

- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}


- (BOOL) hasTorch
{
    return [[[self videoInput] device] hasTorch];
}

- (AVCaptureTorchMode) torchMode
{
    return [[[self videoInput] device] torchMode];
}

- (void) setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isTorchModeSupported:torchMode] && [device torchMode] != torchMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setTorchMode:torchMode];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

- (BOOL) hasFocus
{
    AVCaptureDevice *device = [[self videoInput] device];
    
    return  [device isFocusModeSupported:AVCaptureFocusModeLocked] ||
            [device isFocusModeSupported:AVCaptureFocusModeAutoFocus] ||
            [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
}

- (AVCaptureFocusMode) focusMode
{
    return [[[self videoInput] device] focusMode];
}

- (void) setFocusMode:(AVCaptureFocusMode)focusMode
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusModeSupported:focusMode] && [device focusMode] != focusMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusMode:focusMode];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }    
    }
}

- (BOOL) hasExposure
{
    AVCaptureDevice *device = [[self videoInput] device];
    
    return  [device isExposureModeSupported:AVCaptureExposureModeLocked] ||
            [device isExposureModeSupported:AVCaptureExposureModeAutoExpose] ||
            [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
}

- (AVCaptureExposureMode) exposureMode
{
    return [[[self videoInput] device] exposureMode];
}

- (void) setExposureMode:(AVCaptureExposureMode)exposureMode
{
    if (exposureMode == 1) {
        exposureMode = 2;
    }
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isExposureModeSupported:exposureMode] && [device exposureMode] != exposureMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setExposureMode:exposureMode];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }
}

- (void) focusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }        
    }
}

- (void) exposureAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setExposurePointOfInterest:point];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [device unlockForConfiguration];
        } else {
            id delegate = [self delegate];
            if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
                [delegate acquiringDeviceLockFailedWithError:error];
            }
        }
    }    
}

- (NSString *) sessionPreset
{
    return [[self session] sessionPreset];
}

- (void) setSessionPreset:(NSString *)sessionPreset
{
    AVCaptureSession *session = [self session];
    if (![sessionPreset isEqualToString:[self sessionPreset]] && [session canSetSessionPreset:sessionPreset]) {
        [session beginConfiguration];
        [session setSessionPreset:sessionPreset];
        [session commitConfiguration];
    }
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return [[connection retain] autorelease];
			}
		}
	}
	return nil;
}

@end

@implementation AVCamCaptureManager (Internal)

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

@end

#endif