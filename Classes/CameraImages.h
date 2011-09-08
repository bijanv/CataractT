//
//  CameraImages.h
//  CataractT
//
//  Created by Branislav Grujic on 1/29/11.
//  Copyright 2011 Bane's Tools. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SurfaceImage : NSObject
{
  UIImage* cSurfaceImage;
  UIImage* pSurfaceImage;
}

// Setter
-(void) setCurrentSurfaceImage:(UIImage*)image;
-(void) setPreviousSurfaceImage:(UIImage*)image;

// Accessor
-(UIImage*) getCurrentSurfaceImage;
-(UIImage*) getPreviousSurfaceImage;

@end


// RedReflexImage
@interface RedReflexImage : NSObject
{
  UIImage* cRedReflexImage;
  UIImage* pRedReflexImage;
}

// Setter
-(void) setCurrentRedReflexImage:(UIImage*)image;
-(void) setPreviousRedReflexImage:(UIImage*)image;

// Accessor
-(UIImage*) getCurrentRedReflexImage;
-(UIImage*) getPreviousRedReflexImage;

@end


// Camera Images
@interface CameraImages: NSObject
{
  RedReflexImage* redReflexImage;
  SurfaceImage* surfaceImage;
}

-(void) initImages;

@property( nonatomic, retain ) RedReflexImage* redReflexImage;
@property( nonatomic, retain ) SurfaceImage* surfaceImage;

@end