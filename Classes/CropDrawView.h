//
//  CropDrawView.h
//  RetinaScan
//
//  Created by Bijan Vaez on 10-10-29.
//  Copyright 2010 University of Toronto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CataractTAppDelegate.h"
#import "CataractTViewController.h"
#import "UIImageResize.h"

@interface CropDrawView : UIView {
  CGPoint fromPoint;
  CGPoint toPoint;
}

-(IBAction) cropButtonAction:(id) sender;
-(BOOL) cropImage:(CGPoint)startP: (CGPoint)endP;


@property CGPoint fromPoint;
@property CGPoint toPoint;

@end
