//
//  DiagnosisViewController.h
//  CataractT
//
//  Created by Mark Deutsch on 11-01-29.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface DiagnosisViewController : UIViewController <MFMailComposeViewControllerDelegate> {
  UIImage *surfaceImage;
  UInt8 colourRating;
  UInt8 edgeRating;
  UInt8 fourierRating;
  BOOL sendingMail;
  
  IBOutlet UIImageView *surfaceImageView;
  IBOutlet UIImageView *colourRatingBar;
  IBOutlet UIImageView *edgeRatingBar;
  IBOutlet UIImageView *fourierRatingBar;
  IBOutlet UILabel *titleLabel;
  IBOutlet UILabel *diagnosisLabel;
  IBOutlet UIButton *returnButton;
  IBOutlet UIButton *mailButton;
}
@property (retain, nonatomic) UIImage *surfaceImage;
@property (assign, nonatomic) UInt8 colourRating;
@property (assign, nonatomic) UInt8 edgeRating;
@property (assign, nonatomic) UInt8 fourierRating;
@property (assign, nonatomic) BOOL sendingMail;

@property (retain, nonatomic) IBOutlet UIImageView *surfaceImageView;
@property (retain, nonatomic) IBOutlet UIImageView *colourRatingBar;
@property (retain, nonatomic) IBOutlet UIImageView *edgeRatingBar;
@property (retain, nonatomic) IBOutlet UIImageView *fourierRatingBar;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *diagnosisLabel;
@property (retain, nonatomic) IBOutlet UIButton *returnButton;
@property (retain, nonatomic) IBOutlet UIButton *mailButton;

-(IBAction)goBack:(id)sender;
-(IBAction)showEmailModalView:(id)sender;
-(UIImage*)imageForRating:(UInt8)rating;
@end
