//
//  EditImageViewController.h
//  CataractT
//
//  Created by Branislav Grujic on 1/16/11.
//  Copyright 2011 Bane's Tools. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CataractTAppDelegate.h"
#import "CataractTViewController.h"
#import "UIImageResize.h"

@interface EditImageViewController : UIViewController {
  UIImageView* imageView;
  UIView* cropView;
  UIToolbar* editImageViewToolbar;
}

// ImageView
@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIView* editImageViewToolbar;
@property (nonatomic, retain) IBOutlet UIView* cropView;

// Buttons
@property (nonatomic, retain) IBOutlet UIBarButtonItem* cropImageButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* retakeImageButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* useImageButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* undoCropButton;

// Functions for buttons
-(IBAction) cropImage:(id) sender;
-(IBAction) retakeImage:(id) sender;
-(IBAction) useImage:(id) sender;
-(IBAction) undoCrop:(id) sender;

@end
