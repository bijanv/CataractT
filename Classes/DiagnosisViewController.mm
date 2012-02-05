//
//  DiagnosisViewController.m
//  CataractT
//
//  Created by Mark Deutsch on 11-01-29.
//

#import "DiagnosisViewController.h"
#import "CataractTAppDelegate.h"
#import "ImageProcessingController.h"

@implementation DiagnosisViewController
@synthesize surfaceImage, colourRating, edgeRating, fourierRating, sendingMail;
@synthesize surfaceImageView, colourRatingBar, edgeRatingBar, fourierRatingBar;
@synthesize titleLabel, diagnosisLabel, returnButton, mailButton;

- (IBAction)goBack:(id)sender {
  [self dismissModalViewControllerAnimated:YES];  
}

-(IBAction) showEmailModalView:(id)sender {
  sendingMail = YES;
  MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
  picker.mailComposeDelegate = self;
  
  NSString *subjectDiagnosis;
  if (colourRating <= 1)
    subjectDiagnosis = [NSString stringWithString:@"Healthy Eye"];
	else if (edgeRating * fourierRating * colourRating > 120)
		subjectDiagnosis = [NSString stringWithString:@"Mature Senile Cataract"];
	else if(edgeRating < 5 || colourRating>2)
 		subjectDiagnosis = [NSString stringWithString:@"Unhealthy Eye"];
	else
		subjectDiagnosis = [NSString stringWithString:@"Inconclusive"];
  
  NSString *subject = [NSString stringWithFormat:@"CataractT Diagnosis: %@", subjectDiagnosis];
  [picker setSubject:subject];
  
  NSArray *toRecipients = [NSArray arrayWithObjects:@"cataracttest@gmail.com", nil];
  [picker setToRecipients:toRecipients];

  // Fill out the email body text
  NSData* pic = UIImageJPEGRepresentation(surfaceImage, 0.7);
  [picker addAttachmentData:pic mimeType:@"image/jpg" fileName:@"surfaceImage"];
  NSString *emailBody = [NSString stringWithFormat:@"Patient Name: \nDiagnosis: %@\n\
                         \nRating: %d\nColour Rating: %d\nEdge Rating: %d\nFourier Rating: %d", 
                         subjectDiagnosis, colourRating*edgeRating*fourierRating,
                         colourRating, edgeRating, fourierRating];
  [picker setMessageBody:emailBody isHTML:NO];
  
  picker.navigationBar.barStyle = UIBarStyleDefault; // choose your style, unfortunately, Translucent colors behave quirky.
  
  [self presentModalViewController:picker animated:YES];
  [picker release];
} 

- (UIImage*)imageForRating:(UInt8)rating {
  switch (rating) {
    case 0:
      return [UIImage imageNamed:@"0.png"];
    case 1:
      return [UIImage imageNamed:@"1.png"];
    case 2:
      return [UIImage imageNamed:@"2.png"];
    case 3:
      return [UIImage imageNamed:@"3.png"];
    case 4:
      return [UIImage imageNamed:@"4.png"];
    case 5:
      return [UIImage imageNamed:@"5.png"];
    case 6:
      return [UIImage imageNamed:@"6.png"];
    case 7:
      return [UIImage imageNamed:@"7.png"];
    case 8:
      return [UIImage imageNamed:@"8.png"];
    case 9:
      return [UIImage imageNamed:@"9.png"];
    case 10:
      return [UIImage imageNamed:@"10.png"];       
  }
  return nil;
}

- (void)viewDidAppear:(BOOL)animated {
  if (sendingMail) {
    sendingMail = NO;
    return;
  }
  mailButton.enabled = NO;
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

  ImageProcessingController *ipc = [[ImageProcessingController alloc] init];
  [ipc initImageProcessingControllerWithImage:[appDelegate.cameraImages.surfaceImage getCurrentSurfaceImage]];
  [ipc diagnoseAsSurfaceImage];
  surfaceImage = ipc.mUIImagePtr;
  colourRating = ipc.mColourRating;
  edgeRating = ipc.mEdgeRating;
  fourierRating = ipc.mFourierRating;
  mailButton.enabled = YES;
  
  // Display results
  NSString *diagnosis = [NSString stringWithFormat:@"%d / C%d E%d F%d\n", 
               ipc.mColourRating * ipc.mEdgeRating * ipc.mFourierRating,
               ipc.mColourRating, ipc.mEdgeRating, ipc.mFourierRating];
  
  NSString *msg = nil;
	if (ipc.mColourRating<=1) { 
    // Healthy
		diagnosis = [diagnosis stringByAppendingFormat:@"Healthy Eye"];
		msg = @"Clear black pupil.\nThe eye is healthy.";
	} else if (ipc.mEdgeRating * ipc.mFourierRating * ipc.mColourRating > 100) {
		//Mature Senile Cataract
		diagnosis = [diagnosis stringByAppendingFormat:@"Mature Senile Cataract"];
		float perc = ((float)(ipc.mEdgeRating * ipc.mFourierRating * ipc.mColourRating)/150)*100;
		perc = perc > 100 ? 100 : perc;
		msg = [NSString stringWithFormat:@"Cloudy and lightly-coloured pupil.\n"
			   "The eye is definitely unhealthy and further consultation should be sought."
           "\n%d%% chance of a Mature Senile Cataract.", int(perc)];		
	} else if(ipc.mEdgeRating < 5 || ipc.mColourRating>2){
		if (ipc.mEdgeRating < 5 && ipc.mColourRating>2) {
			//both colour and centre is abnormal
			diagnosis = [diagnosis stringByAppendingFormat:@"Unhealthy Eye"];
			float perc = ((5 - (float)ipc.mEdgeRating + (float)ipc.mColourRating + 6)/15)*100;
			perc = perc > 100 ? 100 : perc;
			msg = [NSString stringWithFormat:@"Abnormal activity at centre of "
				   "the pupil\nUnusual colouring of the pupil."
				   "\n\n%d%% chance that the eye is unhealthy.", int(perc)];
		} else if(ipc.mEdgeRating < 5){
			//Something is wrong at the centre of the eye
			diagnosis = [diagnosis stringByAppendingFormat:@"Unhealthy Eye"];
			float perc = ((10 - (float)ipc.mEdgeRating)/10)*100;
			perc = perc > 100 ? 100 : perc;
			msg = [NSString stringWithFormat:@"Abnormal activity at centre of "
				   "the pupil."
			   "\n\n%d%% chance that the eye is unhealthy.", int(perc)];
		} else if (ipc.mColourRating>2) {
			//the eye is unhealthy due to colour
			diagnosis = [diagnosis stringByAppendingFormat:@"Unhealthy Eye"];
			float perc = (((float)ipc.mEdgeRating)/10)*100;
			perc = perc > 100 ? 100 : perc;
			msg = [NSString stringWithFormat:@"Abnormal colouring in the pupil."
				   "\n\n%d%% chance that the eye is unhealthy.", int(perc)];		
		} else {
			//WTF!
			diagnosis = [diagnosis stringByAppendingFormat:@"ERROR!"];
			msg = @"Something went wrong!";
		}

	}
	else {
		diagnosis = [diagnosis stringByAppendingFormat:@"Inconclusive"];
		msg = @"Diagnosis is uncertain, a second opinion should be sought";
	}
  
  titleLabel.text = diagnosis;
  diagnosisLabel.text = msg;
  surfaceImageView.image = ipc.mUIImagePtr;
  
  colourRatingBar.image = [self imageForRating:ipc.mColourRating];
  edgeRatingBar.image = [self imageForRating:ipc.mEdgeRating];
  fourierRatingBar.image = [self imageForRating:ipc.mFourierRating];
  
  [ipc dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
  if (sendingMail)
    return;
  
  titleLabel.text = @"Diagnosis";
  diagnosisLabel.text = @"Diagnosing...";
  surfaceImageView.image = nil;
  
  colourRatingBar.image = [self imageForRating:0];
  edgeRatingBar.image = [self imageForRating:0];
  fourierRatingBar.image = [self imageForRating:0];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
  UIImage *stretchableButtonImageNormal = [buttonImageNormal 
                                           stretchableImageWithLeftCapWidth:12 topCapHeight:0];
  [returnButton setBackgroundImage:stretchableButtonImageNormal
                          forState:UIControlStateNormal];  
  [mailButton setBackgroundImage:stretchableButtonImageNormal
                        forState:UIControlStateNormal];  
  UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
  UIImage *stretchableButtonImagePressed = [buttonImagePressed 
                                            stretchableImageWithLeftCapWidth:12 topCapHeight:0];
  [returnButton setBackgroundImage:stretchableButtonImagePressed
                          forState:UIControlStateHighlighted];
  [mailButton setBackgroundImage:stretchableButtonImagePressed
                        forState:UIControlStateHighlighted];  
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
  [super dealloc];
  [surfaceImage release];
  [surfaceImageView release];
  [colourRatingBar release];
  [edgeRatingBar release];
  [fourierRatingBar release];
  [titleLabel release];
  [diagnosisLabel release];
  [returnButton release];
  [mailButton release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
  // Notifies users about errors associated with the interface
  switch (result) {
    case MFMailComposeResultCancelled:
    case MFMailComposeResultSaved:
    case MFMailComposeResultSent:
    case MFMailComposeResultFailed:
      break;
    default:
    {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed - Unknown Error :-("
                                                     delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
      [alert show];
      [alert release];
    }
      break;
  }
  [self dismissModalViewControllerAnimated:YES];
}

@end
