//
//  ImageProcessingController.h
//  RetinaScan
//
//  Created by Mark Deutsch on 10-11-05.
//

#import <Foundation/Foundation.h>
#import "Image.h"
#import "CataractTAppDelegate.h"
#import "DefinedRatings.h"

#define DFT_HOR 0
#define DFT_VER 1
#define DFT_DIR 2

#define DFT_RED 0
#define DFT_GRN 1
#define DFT_BLU 2
#define DFT_RGB 3

#define DEBUGGING 1

@interface ImageProcessingController : NSObject {
  UIImage *mUIImagePtr;
  RuntimeVariables *mRuntimeVariables;
  UInt32 *mImgData;
  size_t mWidth;
  size_t mHeight;
  
  UInt8 mColourRating;
  UInt8 mEdgeRating;
  UInt8 mFourierRating;
  
  UInt32 mFlashXCoor;
  UInt32 mFlashYCoor;
  UInt32 mFlashRadius;
}

@property (assign, nonatomic) UIImage* mUIImagePtr;
@property (assign, nonatomic) RuntimeVariables* mRuntimeVariables;
@property (assign, nonatomic) size_t   mWidth;
@property (assign, nonatomic) size_t   mHeight;
@property (assign, nonatomic) UInt32*  mImgData;

@property (assign, nonatomic) UInt8 mColourRating;
@property (assign, nonatomic) UInt8 mEdgeRating;
@property (assign, nonatomic) UInt8 mFourierRating;

@property (assign, nonatomic) UInt32 mFlashXCoor;
@property (assign, nonatomic) UInt32 mFlashYCoor;
@property (assign, nonatomic) UInt32 mFlashRadius;

#pragma mark -Setup Functions-
-(void) initImageProcessingControllerWithImage:(UIImage *)theImage;
-(void) dealloc;
-(void) loadImageDataIntoMemory; // Loads image into mImgData
-(void) freeImageDataFromMemory; // Frees mImgData
-(void) initRatings:(int)val;

#pragma mark -Diagnosis Functions-
-(UInt32) diagnoseAsSurfaceImage;
-(UInt32) diagnoseAsRedReflexImage;
-(UInt8) rateColour;
-(UInt8) rateEdges;
-(UInt8) rateFourier;

#pragma mark -Image Processing Functions-
-(UIImage*) removeFlashFlareTLow:(float)tLow THigh:(float)tHigh;
-(UIImage*) fillFlashFlareAt:(UInt8*)img;
-(void) fillRegionAtLine:(int)y StartPoint:(int)x1 EndPoint:(int)x2;
-(UInt8*) circularHoughTransformOf:(UInt8*)img;
-(void) drawCircleIn:(UInt8*)img radius:(UInt8)r atX:(UInt8)xCenter atY:(UInt8)yCenter;
-(void) setPixelIn:(UInt8*)img atX:(UInt8)xPos atY:(UInt8)yPos;
-(void) DFT1DSize:(UInt8)n fReal:(double*)fRe fImag:(double*)fIm FReal:(double*)FRe FImag:(double*)FIm;
-(UInt32) redComponentOf:(UInt32)colour;
-(UInt32) greenComponentOf:(UInt32)colour;
-(UInt32) blueComponentOf:(UInt32)colour;
-(UInt32) interleaveRed:(UInt32)red green:(UInt32)green blue:(UInt32)blue;

@end
