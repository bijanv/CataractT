//
//  CameraImages.m
//  CataractT
//
//  Created by Branislav Grujic on 1/29/11.
//  Copyright 2011 Bane's Tools. All rights reserved.
//

#import "CameraImages.h"

@implementation CameraImages

@synthesize redReflexImage, surfaceImage;

-(void) initImages;
{
  redReflexImage = [[RedReflexImage alloc] init];
  surfaceImage   = [[SurfaceImage alloc] init];  
}

@end

@implementation RedReflexImage

// Setters
-(void) setCurrentRedReflexImage:(UIImage*)image
{
  cRedReflexImage = image;
}
-(void) setPreviousRedReflexImage:(UIImage*)image;
{
  pRedReflexImage = image;
}

// Accessors
-(UIImage*) getCurrentRedReflexImage
{
  return cRedReflexImage;
}

-(UIImage*) getPreviousRedReflexImage
{
  return pRedReflexImage;
}

@end

@implementation SurfaceImage

// Setters
-(void) setCurrentSurfaceImage:(UIImage*)image
{
  cSurfaceImage = image;
}
-(void) setPreviousSurfaceImage:(UIImage*)image;
{
  pSurfaceImage = image;
}

// Accessors
-(UIImage*) getCurrentSurfaceImage
{
  return cSurfaceImage;
}

-(UIImage*) getPreviousSurfaceImage
{
  return pSurfaceImage;
}

@end