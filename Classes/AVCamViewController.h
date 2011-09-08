//
//  AVCamViewController.h
//  CataractT
//
//  Created by Bijan Vaez on 11-01-19.
//  Copyright 2011 University of Toronto. All rights reserved.
//

#import "CompileFlags.h"

#if COMPILE_FOR_DEVICE == TRUE
#import "EditImageViewController.h"
#import "CataractTAppDelegate.h"
#import "CataractTViewController.h"
#import "AVCamCaptureManager.h"
#import "AVCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>

#import <UIKit/UIKit.h>

@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;
@class EditImageViewController;

@interface AVCamViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
	
	@private
	EditImageViewController* editImageViewController;
	
	AVCamCaptureManager *_captureManager;
  AVCamPreviewView *_videoPreviewView;
  AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;
  UIView *_adjustingInfoView;
  UIBarButtonItem *_stillButton;
	UIBarButtonItem *_backButton;
    
  CALayer *_focusBox;
  CALayer *_exposeBox;

}
@property (nonatomic, retain) EditImageViewController* editImageViewController;

// For single flash camera
@property (nonatomic,retain) AVCamCaptureManager *captureManager;
@property (nonatomic,retain) IBOutlet AVCamPreviewView *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,retain) IBOutlet UIView *adjustingInfoView;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *stillButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *backButton;

#pragma mark Toolbar Actions
- (IBAction)still:(id)sender;
- (IBAction)goBack:(id)sender;

@end
#endif