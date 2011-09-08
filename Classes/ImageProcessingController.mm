//
//  ImageProcessingController.mm
//  RetinaScan
//
//  Created by Mark Deutsch on 10-11-05.
//

#import "ImageProcessingController.h"
#import "Image.h"
#import "CataractTAppDelegate.h"

@implementation ImageProcessingController
@synthesize mUIImagePtr, mRuntimeVariables, mImgData, mWidth, mHeight;
@synthesize mColourRating, mEdgeRating, mFourierRating;
@synthesize mFlashXCoor, mFlashYCoor, mFlashRadius;

#pragma mark -Setup Functions-
-(void) initImageProcessingControllerWithImage:(UIImage *)theImage {
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  mRuntimeVariables = appDelegate.runtimeVars;
  
  mUIImagePtr = theImage;
  mWidth = (int)mUIImagePtr.size.width;
  mHeight = (int)mUIImagePtr.size.height;
  mImgData = NULL;    
  
  if (appDelegate.runtimeVars.FlashFlareSize == 0)
    mFlashRadius = mWidth / 10;
  else
    mFlashRadius = appDelegate.runtimeVars.FlashFlareSize;
  
  [self initRatings:1];
}

-(void) dealloc {
  [super dealloc];
}

-(void) loadImageDataIntoMemory {
  size_t bytesPerPixel = 4;
  size_t bytesPerRow = bytesPerPixel * mWidth;
  size_t bitsPerComponent = 8;
  
  mImgData = (UInt32*)malloc(mWidth * mHeight * bytesPerPixel);
  if (!mImgData) {
    printf("loadImageDataIntoMemory: malloc failed\n");
    return;
  }
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef bmpCxt = CGBitmapContextCreate(mImgData, mWidth, mHeight, bitsPerComponent, 
                                              bytesPerRow, colorSpace,
                                              kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big
                                              );
  // Create bitmap image info from pixel data in current context.
  CGContextDrawImage(bmpCxt, CGRectMake(0, 0, mWidth, mHeight), [mUIImagePtr CGImage]);
  // Release the colorspace/context.
  CGColorSpaceRelease(colorSpace);
  CGContextRelease(bmpCxt);
  return;
}

-(void) freeImageDataFromMemory {
  if (mImgData)
    free(mImgData);
  mImgData = NULL;
  return;
}

-(void) initRatings:(int)val {
  mColourRating = val;
  mEdgeRating = val;
  mFourierRating = val;
}

#pragma mark -Diagnosis Functions-
-(UInt32) diagnoseAsSurfaceImage {
  mUIImagePtr = [self removeFlashFlareTLow:mRuntimeVariables.TLow THigh:mRuntimeVariables.THigh];

	[self rateColour];
	if(1 || mColourRating>1){	
		[self rateFourier];
		[self rateEdges];
	}
  
  NSLog(@"Rating Start\n");
	NSLog(@"%d,%d,%d,%d", mColourRating, mEdgeRating, mFourierRating, mColourRating*mEdgeRating*mFourierRating);
	NSLog(@"Rating End");

  return mColourRating * mEdgeRating * mFourierRating;
}

-(UInt32) diagnoseAsRedReflexImage {
  return TRUE;
}

-(UInt8) rateColour {
	[self loadImageDataIntoMemory];
	if (!mImgData)
		return 0;

	NSLog(@"Average Colour Start\n");
	// Copy the data pointer
	UInt8 *bmpPtr = ((UInt8*)mImgData) - 1;
	UInt32 r_avg = 0;
	UInt32 g_avg = 0;
	UInt32 b_avg = 0;
	UInt32 resolution = 0;
 	UInt32 radius = mWidth/2;
  
	UInt8 numPartitions = 5;
	UInt32 partitionSize = (radius%numPartitions==0) ? radius/numPartitions : radius/numPartitions+1;

	UInt32 **avgP = (UInt32**)calloc(4, sizeof(UInt32*));
  for (int i = 0; i < 4; i++)
    avgP[i] = (UInt32*)calloc(numPartitions, sizeof(UInt32));
  
	for(int y=0; y < mHeight; y++) {
		for(int x=0; x < mWidth; x++) {
			UInt8   r,g,b,a;
			r=*(++bmpPtr);
			g=*(++bmpPtr);
			b=*(++bmpPtr);
			a=*(++bmpPtr);
			float dist = sqrt(abs(x-radius)*abs(x-radius) + abs(y-radius)*abs(y-radius));
			if ( dist <= radius) {
				int el = (int)(dist)/partitionSize;
				avgP[0][el] += r;
				avgP[1][el] += g;
				avgP[2][el] += b;
				/*
				avgP[0][el] += *(++bmpPtr);
				avgP[1][el] += *(++bmpPtr);
				avgP[2][el] += *(++bmpPtr);				
				bmpPtr++; // Skipping the alpha bytes
				 */
				resolution++; //increase total number of bits
				avgP[3][el]++;	//resolution of each partition
			}
		}
		printf("\n");
	}	

	for (int i = 0; i < numPartitions; i++) {
		r_avg += avgP[0][i];
		g_avg += avgP[1][i];
		b_avg += avgP[2][i];

    avgP[0][i] /= avgP[3][i]; // What's the point of this?
   	avgP[1][i] /= avgP[3][i]; // What's the point of this?
   	avgP[2][i] /= avgP[3][i]; // What's the point of this?
    printf("Part: %d\tRes: %d\tR: %d\tG: %d\tB: %d\n",i,avgP[3][i],avgP[0][i],avgP[1][i],avgP[2][i]);
  }
  
	r_avg /= resolution;
	g_avg /= resolution;
	b_avg /= resolution;
	UInt32 avg = (r_avg+g_avg+b_avg) / 3;
  printf("Res: %d\nR: %d\nG: %d\nB: %d\nA: %d\n",resolution,r_avg,g_avg,b_avg,avg);
	NSLog(@"%d,%d,%d,%d",r_avg,g_avg,b_avg,avg);

  for (int i = 0; i < 4; i++)
    free(avgP[i]);
  free(avgP);
  
	if (avg>AVC_10)	  	mColourRating=R10;
	else if(avg>AVC_9)	mColourRating=R9;
	else if(avg>AVC_8)	mColourRating=R8;
	else if(avg>AVC_7)	mColourRating=R7;
	else if(avg>AVC_6)	mColourRating=R6;
	else if(avg>AVC_5)	mColourRating=R5;
	else if(avg>AVC_4)	mColourRating=R4;
	else if(avg>AVC_3)	mColourRating=R3;
	else if(avg>AVC_2)	mColourRating=R2;
	else                mColourRating=R1;

  [self freeImageDataFromMemory];
  //NSLog(@"cRating: %d\n", mColourRating);
  NSLog(@"Average Colour End\n");
	return mColourRating;
}

-(UInt8) rateEdges {
	ImageWrapper *greyScale=Image::createImage(mUIImagePtr, 
                                             (int)mUIImagePtr.size.width, (int)mUIImagePtr.size.height);
	ImageWrapper *edges=greyScale.image->gaussianBlur().image->cannyEdgeExtract(mRuntimeVariables.TLow, mRuntimeVariables.THigh);
	UInt8 *img = edges.image->getRawData();
	
	mWidth = edges.image->getWidth();
	mHeight = edges.image->getHeight();
	
	NSLog(@"Edge Data Start\n");
	UInt8 numPartitions=5;

/* Trying this out ************************/	
	//omit 5% of image edges for human cropping error
	UInt32 edgeYOffset = 0.025 * (float)mHeight;
	UInt32 edgeXOffset = 0.025 * (float)mWidth;
/******************************************/
	
  UInt32 edgeMapWidth = edges.image->getWidth() - 2*edgeXOffset;
  UInt32 edgeMapHeight = edges.image->getHeight() - 2*edgeYOffset;
	
	UInt32 radius = edgeMapWidth / 2;
	UInt32 partitionSize = (radius%numPartitions==0) ? radius/numPartitions : radius/numPartitions+1;
	
	UInt32 *edgeCount = (UInt32*)calloc(numPartitions, sizeof(UInt32));
	UInt32 sum = 0;
	
	
	for(int y=edgeYOffset; y < edgeMapHeight-edgeYOffset; y++) {
		for(int x=edgeXOffset; x < edgeMapWidth-edgeXOffset; x++) {
//			printf("%s",img[y*mWidth + x]==255 ? " ":"1");
			float dist = sqrt(abs(x-radius)*abs(x-radius) + abs(y-radius)*abs(y-radius));
			if ( dist <= radius && img[y*mWidth + x] == 0) {
				edgeCount[(int)(dist)/partitionSize]++;
				sum++;
			}
		}
		//printf("\n");
	}	
  
	float sum2 = 0;
	printf("sum: %d\n", sum);
  for (int i=0; i < numPartitions; i++) {
    printf("%.2f ",(float)edgeCount[i]/(float)sum*100);
		NSLog(@"%.2f ",(float)edgeCount[i]/(float)sum*100);
		sum2 += (i<2) ? ((float)edgeCount[i]) : (0);
  }
  printf("\n");
  printf("sum2: %f / %d = %.2f\n",sum2, sum, sum2/(float)(sum));

  free(edgeCount);
	sum2 = sum2 / (float)(sum)*100;
  NSLog(@"%.2f ",sum2);
  
	if (sum2<EDG_10)      mEdgeRating=R10;
	else if (sum2<EDG_9)	mEdgeRating=R9;
	else if (sum2<EDG_8)	mEdgeRating=R8;
	else if (sum2<EDG_7)	mEdgeRating=R7;
	else if (sum2<EDG_6)	mEdgeRating=R6;
	else if (sum2<EDG_5)	mEdgeRating=R5;
	else if (sum2<EDG_4)	mEdgeRating=R4;
	else if (sum2<EDG_3)	mEdgeRating=R3;
	else if (sum2<EDG_2)	mEdgeRating=R2;
	else                  mEdgeRating=R1;

	//NSLog(@"eRating: %d\n",mEdgeRating);
	NSLog(@"Edge Data End\n");
  return mEdgeRating;
}

-(UInt8) rateFourier {
  [self loadImageDataIntoMemory];
  if (!mImgData)
    return 1;
  
  NSLog(@"DFT Data Start\n");
  double fRe[2][3][mWidth], fIm[2][3][mWidth], FRe[2][3][mWidth], FIm[2][3][mWidth];
  UInt32 i, j;
  UInt32 line = mWidth / 2;
  
  CataractTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  float zMax = appDelegate.runtimeVars.ZMax;
  
  // Deinterleave the horizontal line...
  for(i = line*mWidth, j = 0; i < mWidth*(line+1); i++, j++){
    fRe[DFT_HOR][DFT_RED][j] = [self redComponentOf:mImgData[i]];
    fRe[DFT_HOR][DFT_GRN][j] = [self greenComponentOf:mImgData[i]];
    fRe[DFT_HOR][DFT_BLU][j] = [self blueComponentOf:mImgData[i]];
    fIm[DFT_HOR][DFT_RED][j] = fIm[DFT_HOR][DFT_GRN][j] = fIm[DFT_HOR][DFT_BLU][j] = 0;
  }
  
  // and the vertical line...
  for(i = line, j = 0; i < mWidth*mHeight; i+=mWidth, j++){
    fRe[DFT_VER][DFT_RED][j] = [self redComponentOf:mImgData[i]];
    fRe[DFT_VER][DFT_GRN][j] = [self greenComponentOf:mImgData[i]];
    fRe[DFT_VER][DFT_BLU][j] = [self blueComponentOf:mImgData[i]]; 
    fIm[DFT_VER][DFT_RED][j] = fIm[DFT_VER][DFT_GRN][j] = fIm[DFT_VER][DFT_BLU][j] = 0;
  }
  [self freeImageDataFromMemory];
  
  // ...and run the Fourier Transforms.
  for (i = 0; i < DFT_DIR; i++) {
    for (j = 0; j < DFT_RGB; j++) {
      [self DFT1DSize:mWidth fReal:fRe[i][j] fImag:fIm[i][j] FReal:FRe[i][j] FImag:FIm[i][j]];
    }
  }
  
	float realZCount[DFT_DIR][DFT_RGB]={ {0,0,0,},{0,0,0} };
	float imagZCount[DFT_DIR][DFT_RGB]={ {0,0,0,},{0,0,0} }; 
  for (i=0; i < DFT_DIR; i++) {
    printf("Dir: %d\n",i);
    for (j=0; j < DFT_RGB; j++) {
			printf("Colour: %d\n",j);
      for (int k=0; k < mWidth; k++) {
//		  printf("%d, %.2f\n", k, FRe[i][j][k]);
		  float tmpValue = (FRe[i][j][k]<0) ? FRe[i][j][k]*-1 : FRe[i][j][k];
				if (tmpValue < zMax) realZCount[i][j]++;
				if (abs(FIm[i][j][k]) < zMax) imagZCount[i][j]++;        
      }
    }
  }
  
	float avg[2]={0,0};
  for (i=0; i < DFT_DIR; i++) {
		i == DFT_HOR ? printf("Horizontal\n") : printf("Vertical\n");
    for (j=0; j < DFT_RGB; j++) {
      realZCount[i][j] /= mWidth;
      imagZCount[i][j] /= mWidth;
      avg[i] += (realZCount[i][j]*100);
			printf("\t%f\n",realZCount[i][j]);
			NSLog(@"%.2f",realZCount[i][j]*100);      
    }
  }
  
	for (int i=0; i<DFT_DIR; i++)
		avg[i] /= DFT_RGB;
  
  printf("%f\t%f\n",avg[DFT_HOR],avg[DFT_VER]);
/*
  float val = 1;
	int disector=mWidth/2;
	if (abs(disector-mFlashXCoor)<mFlashRadius && abs(disector-mFlashYCoor)<mFlashRadius) {
		printf("Flash is in the path of both the Y axis and the X axis\nCan't "
			   "really use this Image\nJust use DFT_HOR because of the gradient");
		val = avg[DFT_HOR];		
	}	else if ( abs(disector-mFlashXCoor)<mFlashRadius) {
		val = avg[DFT_HOR];
		printf("Flash is in path of Y axis - use DFT_HOR\n");
	} else if (abs(disector-mFlashYCoor)<mFlashRadius) {
		val = avg[DFT_VER];
		printf("Flash is in path of X axis - use DFT_VER\n");
	} else {
		val = (avg[DFT_HOR]<avg[DFT_VER]) ? avg[DFT_HOR] : avg[DFT_VER];
		printf("Flash is not in any DFT path - use lowest value\n");
	}
*/
  float val = (avg[DFT_HOR]<avg[DFT_VER]) ? avg[DFT_HOR] : avg[DFT_VER];
 
	NSLog(@"%.2f",val);	
  if (val < FFT_10)		  mFourierRating = R10;
  else if (val < FFT_9)	mFourierRating = R9;
  else if (val < FFT_8)	mFourierRating = R8;
  else if (val < FFT_7)	mFourierRating = R7;
  else if (val < FFT_6)	mFourierRating = R6;
  else if (val < FFT_5)	mFourierRating = R5;
  else if (val < FFT_4)	mFourierRating = R4;
  else if (val < FFT_3)	mFourierRating = R3;
  else if (val < FFT_2)	mFourierRating = R2;
  else                  mFourierRating = R1;
	
  NSLog(@"FRating: %d\n", mFourierRating);	
	NSLog(@"DFT Data End\n");
	return mFourierRating;  
}
  
#pragma mark -Image Processing Functions-
-(UIImage*) removeFlashFlareTLow:(float)tLow THigh:(float)tHigh {
  ImageWrapper *greyScale=Image::createImage(mUIImagePtr, 
                                             (int)mUIImagePtr.size.width, (int)mUIImagePtr.size.height);
  ImageWrapper *edges=greyScale.image->gaussianBlur().image->cannyEdgeExtract(tLow, tHigh);
  UInt8 *ptr = edges.image->getRawData();
  
  // Set dimensions to that of edge information for Hough transform.
  mWidth = edges.image->getWidth();
  mHeight = edges.image->getHeight();
	
  UInt8 *hough = [self circularHoughTransformOf:ptr];  
  // Restore the correct dimensions.
  mWidth = mUIImagePtr.size.width;
  mHeight = mUIImagePtr.size.height;
  UIImage* retImg = [self fillFlashFlareAt:hough];
  return retImg;
}

-(UIImage*) fillFlashFlareAt:(UInt8*)img {
  UInt32 i = 0;
  int leftSideOfCircle = -1;
  
  [self loadImageDataIntoMemory];
  if (!mImgData) return NULL;
  
  for (int y = 4; y < mHeight - 4; y++, leftSideOfCircle = -1) {
    for (int x = 4; x < mWidth - 4; x++, i++) {
      if (img[i] == 255) {
        if (leftSideOfCircle == -1)
          leftSideOfCircle = x;
        else
          [self fillRegionAtLine:y StartPoint:leftSideOfCircle EndPoint:x];
      }
    }
  }
  free(img);
  
  // create a UIImage
	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	CGContextRef context=CGBitmapContextCreate(mImgData, mWidth, mHeight, 8, 
                                             mWidth*sizeof(UInt32), colorSpace, 
                                             kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGImageRef image=CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	UIImage *resultUIImage=[UIImage imageWithCGImage:image];
	CGImageRelease(image);
  [self freeImageDataFromMemory];
	return resultUIImage;
  
}

-(void) fillRegionAtLine:(int)y StartPoint:(int)x1 EndPoint:(int)x2 {
  // Bit of "anti-aliasing"
  x1 -= 2;
  x2 += 2;
  
  // Generate replacement colour endpoints
  UInt32 leftSide = mImgData[y*mWidth + x1 - 1] < mImgData[y*mWidth + x1] ?
                    mImgData[y*mWidth + x1 - 1] : mImgData[y*mWidth + x1];
  UInt32 lRed = [self redComponentOf:leftSide];
  UInt32 lGrn = [self greenComponentOf:leftSide];
  UInt32 lBlu = [self blueComponentOf:leftSide];
  
  UInt32 rightSide = mImgData[y*mWidth + x2 + 1] < mImgData[y*mWidth + x2] ?
                     mImgData[y*mWidth + x2 + 1] : mImgData[y*mWidth + x2];
  UInt32 rRed = [self redComponentOf:rightSide];
  UInt32 rGrn = [self greenComponentOf:rightSide];
  UInt32 rBlu = [self blueComponentOf:rightSide];
  
  // Calculate the slope - or incrementor - for each colour component.
  float redSlope = ((int)rRed - (int)lRed) / (x2 - x1 + 2);
  float grnSlope = ((int)rGrn - (int)lGrn) / (x2 - x1 + 2);
  float bluSlope = ((int)rBlu - (int)lBlu) / (x2 - x1 + 2);    
  
  UInt32 repRed = lRed;
  UInt32 repGrn = lGrn;
  UInt32 repBlu = lBlu;
  
  for (int i = x1; i <= x2; i++) {
    mImgData[y*mWidth + i] = [self interleaveRed:repRed green:repGrn blue:repBlu];
    repRed += redSlope;
    repGrn += grnSlope;
    repBlu += bluSlope;
  }
  return;
}

-(UInt8*) circularHoughTransformOf:(UInt8*)img {
  UInt8 *acc = (UInt8*)calloc(1, mWidth * mHeight * sizeof(UInt8));
  int x0, y0;
  double t;
  for(int x=0; x < mWidth; x++) {
    for(int y=0; y < mHeight; y++) {
      if (img[y*mWidth+x]== 0) {
        for (int theta=0; theta < 360; theta += 2) {
          t = (theta * M_PI) / 180;
          x0 = (int)round(x - mFlashRadius * cos(t));
          y0 = (int)round(y - mFlashRadius * sin(t));
          if(x0 < mWidth && x0 > 0 && y0 < mHeight && y0 > 0) {
            acc[x0 + (y0 * mWidth)] += 1; // Use this for a confidence rating
#ifdef DEBUGGING
            if (acc[x0 + (y0 * mWidth)] == 0) {
              printf("*******ACCUMULATOR LOOPED AROUND*******\n");
              printf("***SAVE THE PICTURE YOU'RE TESTING!!***\n");
              acc[x0 + (y0 * mWidth)] = 255;
              continue;
            }
#endif
          }
        }
      }
    }
  }
  [self loadImageDataIntoMemory];
  UInt8 maxAccumVal = 0;
  for(int x=0; x < mWidth; x++) {
    for(int y=0; y < mHeight; y++) {
      if (acc[x + (y * mWidth)] > maxAccumVal &&
          (([self redComponentOf:mImgData[mWidth*y + x]] +
            [self greenComponentOf:mImgData[mWidth*y + x]] +
            [self blueComponentOf:mImgData[mWidth*y + x]])/3 > 240)) {
        maxAccumVal = acc[x + (y * mWidth)];
        mFlashXCoor = x;
        mFlashYCoor = y;        
      }
    }
  }
  
	printf("FlashX = %d\nFlashY = %d\nFlashRadius = %d\n",mFlashXCoor, mFlashYCoor, mFlashRadius);
  free(acc);
  
  UInt8 *output = (UInt8*)calloc(1, mWidth*mHeight*sizeof(UInt8));
  if (([self redComponentOf:mImgData[mWidth*mFlashYCoor + mFlashXCoor]] +
       [self greenComponentOf:mImgData[mWidth*mFlashYCoor + mFlashXCoor]] +
       [self blueComponentOf:mImgData[mWidth*mFlashYCoor + mFlashXCoor]])/3 > 200)
    [self drawCircleIn:output radius:mFlashRadius atX:mFlashXCoor atY:mFlashYCoor];
  else
    [self drawCircleIn:output radius:1 atX:mFlashXCoor atY:mFlashYCoor];
  [self freeImageDataFromMemory];
  
  return output;
}

-(void) drawCircleIn:(UInt8*)img radius:(UInt8)r atX:(UInt8)xCenter atY:(UInt8)yCenter {  
  int x, y, r2;
  int radius = r;
  r2 = r * r;
  [self setPixelIn:img atX:xCenter atY:yCenter+radius];
  [self setPixelIn:img atX:xCenter atY:yCenter-radius];
  [self setPixelIn:img atX:xCenter+radius atY:yCenter];
  [self setPixelIn:img atX:xCenter-radius atY:yCenter];
  
  y = radius;
  x = 1;
  y = (int) (sqrt(r2 - 1) + 0.5);
  while (x < y) {
    [self setPixelIn:img atX:xCenter+x atY:yCenter+y];
    [self setPixelIn:img atX:xCenter+x atY:yCenter-y];
    [self setPixelIn:img atX:xCenter-x atY:yCenter+y];
    [self setPixelIn:img atX:xCenter-x atY:yCenter-y];
    [self setPixelIn:img atX:xCenter+y atY:yCenter+x];
    [self setPixelIn:img atX:xCenter+y atY:yCenter-x];
    [self setPixelIn:img atX:xCenter-y atY:yCenter+x];
    [self setPixelIn:img atX:xCenter-y atY:yCenter-x];
    
    x += 1;
    y = (int) (sqrt(r2 - x*x) + 0.5);
  }
  if (x == y) {
    [self setPixelIn:img atX:xCenter+x atY:yCenter+y];
    [self setPixelIn:img atX:xCenter+x atY:yCenter-y];
    [self setPixelIn:img atX:xCenter-x atY:yCenter+y];
    [self setPixelIn:img atX:xCenter-x atY:yCenter-y];    
  }
}

-(void) setPixelIn:(UInt8*)img atX:(UInt8)xPos atY:(UInt8)yPos {
  img[(yPos * mWidth) + xPos] = 0xff;
}

-(void) DFT1DSize:(UInt8)n fReal:(double*)fRe fImag:(double*)fIm FReal:(double*)FRe FImag:(double*)FIm {
  for(int w = 0; w < n; w++){
    FRe[w] = 0;
    FIm[w] = 0;
    for(int x = 0; x < n; x++) {
      double a = -2 * M_PI * w * x / n;
      double ca = cos(a);
      double sa = sin(a);
      FRe[w] += fRe[x] * ca - fIm[x] * sa;
      FIm[w] += fRe[x] * sa + fIm[x] * ca;
    }
    FRe[w] /= n;
    FIm[w] /= n;
  }
}

-(UInt32) redComponentOf: (UInt32)colour {
	return 0x000000ff & colour;
}

-(UInt32) greenComponentOf: (UInt32)colour {
	return ( 0x0000ff00 & colour ) >> 8;  
}

-(UInt32) blueComponentOf: (UInt32)colour {
  return ( 0x00ff0000 & colour ) >> 16;
}

-(UInt32) interleaveRed: (UInt32)red green: (UInt32)green blue: (UInt32)blue {
  return (0xff << 24) | ( blue << 16 ) | ( green << 8 ) | red ; // ignore alpha
}
@end
