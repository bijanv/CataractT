//
//  CataractTViewController.h
//  CataractT
//
//  Created by Branislav Grujic on 1/15/11.
//  Copyright 2011 Bane's Tools. All rights reserved.
//

#import "CompileFlags.h"
#import <UIKit/UIKit.h>
#import "EditImageViewController.h"
#import "DiagnosisViewController.h"


#if COMPILE_FOR_DEVICE == TRUE
  #import "AVCamViewController.h"
#endif


@class AlgorithmRefineViewController;
@class EditImageViewController;
@class AVCamViewController;

@interface CataractTViewController : UIViewController< UIImagePickerControllerDelegate, UINavigationControllerDelegate >
{
  // pickerController for camera
  UIImagePickerController* pickerController;
  EditImageViewController* editImageViewController;
  AlgorithmRefineViewController* algorithmRefineViewController;
  DiagnosisViewController* diagnosisViewController;
	
#if COMPILE_FOR_DEVICE == TRUE
	AVCamViewController *aVCamViewController;
#endif
  
  // Button
  UIButton* captureSurfaceImageButton;
  UIButton* captureRedReflexImageButton;
  UIButton* runDiagnosisButton;
  UIButton* settingsButton;
  UIButton* loadFromGalleryButton;

}

// Config Menu
@property (nonatomic, retain) AlgorithmRefineViewController* algorithmRefineViewController;

@property (nonatomic, retain) DiagnosisViewController* diagnosisViewController;

// Buttons for Main Menu
@property (nonatomic, retain) IBOutlet UIButton* captureSurfaceImageButton;
@property (nonatomic, retain) IBOutlet UIButton* captureRedReflexImageButton;
@property (nonatomic, retain) IBOutlet UIButton* runDiagnosisButton;
@property (nonatomic, retain) IBOutlet UIButton* settingsButton;
@property (nonatomic, retain) IBOutlet UIButton* loadFromGalleryButton;

// EditImageViewController
@property (nonatomic, retain) EditImageViewController* editImageViewController;

#if COMPILE_FOR_DEVICE == TRUE
@property (nonatomic, retain) AVCamViewController *aVCamViewController;
#endif

// Functions for the main menu buttons
-(IBAction) captureSurfaceImage:(id) sender;
-(IBAction) captureRedReflexImage:(id) sender;
-(IBAction) runDiagnosis:(id) sender;
-(void) bulkImageAnalysis;
-(void) redirectConsoleLogToDocumentFolder;
-(BOOL)doesContainSubstring:(NSString *) str: (NSString *)substr;
-(IBAction) settings:(id) sender;
-(IBAction) loadFromGallery:(id) sender;

// Image Orientation Fix
-(UIImage*) fixImage:(UIImage*) imageToFix;

@end

