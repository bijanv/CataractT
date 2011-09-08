
#import "CompileFlags.h"
#if COMPILE_FOR_DEVICE == TRUE

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AVCamCaptureManager.h"
#import "CataractTAppDelegate.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol AVCamCaptureManagerDelegate
@optional
- (void) captureStillImageFailedWithError:(NSError *)error;
- (void) acquiringDeviceLockFailedWithError:(NSError *)error;
- (void) cannotWriteToAssetLibrary;
- (void) assetLibraryError:(NSError *)error forURL:(NSURL *)assetURL;
- (void) someOtherError:(NSError *)error;
- (void) releaseCameraView;
@end

@interface AVCamCaptureManager : NSObject {
@private 
    // Capture Session
    AVCaptureSession *_session;
    AVCaptureVideoOrientation _orientation;
    
    // Devic Inputs
    AVCaptureDeviceInput *_videoInput;
    
    // Capture Outputs
    AVCaptureStillImageOutput *_stillImageOutput;
    
    // Identifiers for connect/disconnect notifications
    id _deviceConnectedObserver;
    id _deviceDisconnectedObserver;
    
    // Identifier for background completion of recording
    UIBackgroundTaskIdentifier _backgroundRecordingID; 
    
    // Capture Manager delegate
    id <AVCamCaptureManagerDelegate> _delegate;
}

@property (nonatomic,readonly,retain) AVCaptureSession *session;
@property (nonatomic,assign) AVCaptureVideoOrientation orientation;
@property (nonatomic,assign) NSString *sessionPreset;
@property (nonatomic,readonly,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,assign) AVCaptureTorchMode torchMode;
@property (nonatomic,assign) AVCaptureFocusMode focusMode;
@property (nonatomic,assign) AVCaptureExposureMode exposureMode;
@property (nonatomic,assign) AVCaptureWhiteBalanceMode whiteBalanceMode;
@property (nonatomic,assign) id <AVCamCaptureManagerDelegate> delegate;

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error;
- (void) captureStillImage;
- (NSUInteger) cameraCount;
- (BOOL) hasTorch;
- (BOOL) hasFocus;
- (BOOL) hasExposure;
- (void) focusAtPoint:(CGPoint)point;
- (void) exposureAtPoint:(CGPoint)point;
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

@end
#endif