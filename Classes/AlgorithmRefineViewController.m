//
//  AlgorithmRefineViewController.m
//  RetinaScan
//
//  Created by Bijan Vaez on 10-11-20.
//  Copyright 2010 University of Toronto. All rights reserved.
//

#import "AlgorithmRefineViewController.h"
#import "CataractTAppDelegate.h"

@implementation AlgorithmRefineViewController

@synthesize switch1, switch2, switch3, switch4, switch5, switch6, switch7, switch8, DebugLog;
@synthesize THigh, TLow, uint8_1, ZMax, FlashFlareSize, returnButton;

-(IBAction)goBack:(id) sender
{	
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  
  appDelegate.runtimeVars.THigh = THigh.text.intValue;
  appDelegate.runtimeVars.TLow = TLow.text.intValue;
  appDelegate.runtimeVars.uint8_1 = uint8_1.text.intValue;
  appDelegate.runtimeVars.ZMax = [ZMax.text intValue];
  appDelegate.runtimeVars.FlashFlareSize = FlashFlareSize.text.intValue;
  
  appDelegate.runtimeVars.switch1 = switch1.on;
  appDelegate.runtimeVars.switch2 = switch2.on;
  appDelegate.runtimeVars.switch3 = switch3.on;
  appDelegate.runtimeVars.switch4 = switch4.on;
  appDelegate.runtimeVars.switch5 = switch5.on;
  appDelegate.runtimeVars.switch6 = switch6.on;
  appDelegate.runtimeVars.switch7 = switch7.on;
  appDelegate.runtimeVars.switch8 = switch8.on;
  appDelegate.runtimeVars.DebugLog = DebugLog.on;

	if (appDelegate.runtimeVars.switch1) {		
		CataractTAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		appDelegate.viewController.runDiagnosisButton.enabled = YES;
	}
	
  [self dismissModalViewControllerAnimated:YES];  
}

-(IBAction)backgroundTouch:(id)sender
{
	[self.view endEditing:YES];
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
  UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
  UIImage *stretchableButtonImageNormal = [buttonImageNormal 
                                           stretchableImageWithLeftCapWidth:12 topCapHeight:0];
  [returnButton setBackgroundImage:stretchableButtonImageNormal
                          forState:UIControlStateNormal];  
  UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
  UIImage *stretchableButtonImagePressed = [buttonImagePressed 
                                            stretchableImageWithLeftCapWidth:12 topCapHeight:0];
  [returnButton setBackgroundImage:stretchableButtonImagePressed
                          forState:UIControlStateHighlighted];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
