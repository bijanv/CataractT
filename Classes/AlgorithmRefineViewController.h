//
//  AlgorithmRefineViewController.h
//  RetinaScan
//
//  Created by Bijan Vaez on 10-11-20.
//  Copyright 2010 University of Toronto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CataractTAppDelegate.h"

@interface AlgorithmRefineViewController : UIViewController {
	IBOutlet UISwitch *switch1; // Bulk image analysis
	IBOutlet UISwitch *switch2;
	IBOutlet UISwitch *switch3;
	IBOutlet UISwitch *switch4;
	IBOutlet UISwitch *switch5;
	IBOutlet UISwitch *switch6;
	IBOutlet UISwitch *switch7;
	IBOutlet UISwitch *switch8;
	IBOutlet UISwitch *DebugLog;
	
	IBOutlet UITextField *THigh;
	IBOutlet UITextField *TLow;
	
	IBOutlet UITextField *uint8_1;
	IBOutlet UITextField *ZMax;
	IBOutlet UITextField *FlashFlareSize;
  
  IBOutlet UIButton *returnButton;
	
}

@property (nonatomic, retain) IBOutlet UISwitch *switch1;
@property (nonatomic, retain) IBOutlet UISwitch *switch2;
@property (nonatomic, retain) IBOutlet UISwitch *switch3;
@property (nonatomic, retain) IBOutlet UISwitch *switch4;
@property (nonatomic, retain) IBOutlet UISwitch *switch5;
@property (nonatomic, retain) IBOutlet UISwitch *switch6;
@property (nonatomic, retain) IBOutlet UISwitch *switch7;
@property (nonatomic, retain) IBOutlet UISwitch *switch8;
@property (nonatomic, retain) IBOutlet UISwitch *DebugLog;

@property (nonatomic, retain) IBOutlet UITextField *THigh;
@property (nonatomic, retain) IBOutlet UITextField *TLow;

@property (nonatomic, retain) IBOutlet UITextField *uint8_1;
@property (nonatomic, retain) IBOutlet UITextField *ZMax;
@property (nonatomic, retain) IBOutlet UITextField *FlashFlareSize;
@property (nonatomic, retain) IBOutlet UIButton *returnButton;

-(IBAction)goBack:(id)sender;
-(IBAction)backgroundTouch:(id)sender;


@end
