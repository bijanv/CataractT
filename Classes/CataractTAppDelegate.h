//
//  CataractTAppDelegate.h
//  CataractT
//
//  Created by Branislav Grujic on 1/15/11.
//  Copyright 2011 Bane's Tools. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompileFlags.h"
#import "CameraImages.h"

#if COMPILE_FOR_DEVICE == TRUE
  #import "AVCamViewController.h"
  #import "AVCamCaptureManager.h"
  #import <AVFoundation/AVFoundation.h>
#endif

#import "CataractTViewController.h"

@interface RuntimeVariables : NSObject
{
	BOOL switch1;
	BOOL switch2;
	BOOL switch3;
	BOOL switch4;
	BOOL switch5;
	BOOL switch6;
	BOOL switch7;
	BOOL switch8;
	BOOL DebugLog;
	
	float THigh;
	float TLow;
	
	UInt8 uint8_1;
	float ZMax;
	UInt32 FlashFlareSize;	
}

@property (nonatomic, assign) BOOL switch1;
@property (nonatomic, assign) BOOL switch2;
@property (nonatomic, assign) BOOL switch3;
@property (nonatomic, assign) BOOL switch4;
@property (nonatomic, assign) BOOL switch5;
@property (nonatomic, assign) BOOL switch6;
@property (nonatomic, assign) BOOL switch7;
@property (nonatomic, assign) BOOL switch8;
@property (nonatomic, assign) BOOL DebugLog;

@property (nonatomic, assign) float THigh;
@property (nonatomic, assign) float TLow;

@property (nonatomic, assign) UInt8 uint8_1;
@property (nonatomic, assign) float ZMax;
@property (nonatomic, assign) UInt32 FlashFlareSize;
@end

@class CataractTViewController;
@class CameraImages;

@interface CataractTAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  CataractTViewController *viewController;
  
  CameraImages* cameraImages;
  RuntimeVariables* runtimeVars;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CataractTViewController *viewController;

@property (nonatomic, retain) CameraImages* cameraImages;
@property (nonatomic, retain) RuntimeVariables* runtimeVars;

@end

