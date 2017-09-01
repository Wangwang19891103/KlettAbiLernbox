//
//  ThumbnailCreator.h
//  KlettAbiLernboxen
//
//  Created by Wang on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThumbnailCreator : NSObject {
    
    UIImage* __strong _backgroundImage;
    UIImage* __strong _blendImage;
    
    UIColor* __strong _backgroundColor;
    UIColor* __strong _foregroundColor;
}

- (id) initWithBackgroundColor:(UIColor*) bgColor foregroundColor:(UIColor*) fgColor;

- (NSArray*) createThumbnailsBeginningWithPageNumber:(uint) number;

- (UIImage*) renderPDFPage:(CGPDFPageRef) pageRef withPageNumber:(uint) number;

- (UIImage*) createBackgroundImage;

- (UIImage *)convertImageToGrayScale:(UIImage *)image;

- (void) saveImage:(UIImage*) image toPNGFile:(NSString*) filePath;


/*****************************/

- (NSArray*) createThumbnails2BeginningWithPageNumber:(uint) number scaleFactor:(float) scaleFactor;

//- (UIImage*) renderPDFPage2:(CGPDFPageRef) pageRef withPageNumber:(uint) number;

@end
