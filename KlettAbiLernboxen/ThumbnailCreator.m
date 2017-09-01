//
//  ThumbnailCreator.m
//  KlettAbiLernboxen
//
//  Created by Wang on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailCreator.h"
#import "PDFManager.h"
#import "CGExtensions.h"
#import "UIColor+Extensions.h"
#import "TranslateIdiom.h"


#define THUMBNAIL_MAX_SIZE CGSizeMake(60, 40)
#define THUMBNAIL_INNER_RECT CGRectMake(5, 5, 50, 30)
#define PAGE_NUMBER_FONT [UIFont fontWithName:@"Helvetica" size:16.0]


#define THUMBNAIL_MAX_SIZE2 CGSizeMake(36, 28)
#define THUMBNAIL_INNER_RECT2 CGRectMake(2, 2, 31, 24)
#define PAGE_NUMBER_FONT2 [UIFont fontWithName:@"Helvetica-Light" size:10.0]
#define THUMBNAIL_BACKGROUND_COLOR2 [UIColor colorWithRed:234/255.0 green:237/255.0 blue:239/255.0 alpha:1.0]
#define THUMBNAIL_ARC_RADIUS2 3.0f
#define TEXT_COLOR2 [UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha: 1.0]


@implementation ThumbnailCreator

- (id) initWithBackgroundColor:(UIColor *)bgColor foregroundColor:(UIColor *)fgColor {

    if (self = [super init]) {
        
        _backgroundColor = bgColor;
        _foregroundColor = fgColor;
        _backgroundImage = [self createBackgroundImage];
        
    }
    
    return self;
}


- (NSArray*) createThumbnailsBeginningWithPageNumber:(uint)number {
    
//    NSLog(@"create Thumsnails");
    
    uint numberOfPages = CGPDFDocumentGetNumberOfPages([PDFManager manager].exercisesDocumentRef);
    
//    NSLog(@"number of pages: %d", numberOfPages);
    
//    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* documentsDirectory = [pathArray lastObject];

    
    NSMutableArray* images = [NSMutableArray array];
    
    for (int p = 1; p <= numberOfPages; ++p) {
        NSLog(@"creating page: %d", p);
        CGPDFPageRef pageRef = CGPDFDocumentGetPage([PDFManager manager].exercisesDocumentRef, p);
        UIImage* image = [self renderPDFPage:pageRef withPageNumber:number + p - 1];
        [images addObject:image];
        
//        NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbnail_%d.png", p]];
        
//        [self saveImage:image toPNGFile:filePath];
    }
    
    return images;
}


- (UIImage*) renderPDFPage:(CGPDFPageRef)pageRef withPageNumber:(uint)number {

    // 1. rendering pdf in full size
    CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox));
    UIGraphicsBeginImageContextWithOptions(pageRect.size, FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    CGContextSetRGBFillColor(context, 0.7, 0.7, 0.7, 0.0);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGAffineTransform transform = CGPDFPageGetDrawingTransform(pageRef, kCGPDFCropBox, CGRectMake(0, 0, pageRect.size.width, pageRect.size.height), 0, true);
    CGContextConcatCTM(context, transform);
    
//    // removing question mark
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathMoveToPoint(path, NULL, QUESTION_MARK_FILL_RECT.origin.x, QUESTION_MARK_FILL_RECT.origin.y + QUESTION_MARK_FILL_RECT.size.height);
//    CGPathAddLineToPoint(path, NULL, QUESTION_MARK_FILL_RECT.origin.x + QUESTION_MARK_FILL_RECT.size.width, QUESTION_MARK_FILL_RECT.origin.y + QUESTION_MARK_FILL_RECT.size.height);
//    CGPathAddLineToPoint(path, NULL, QUESTION_MARK_FILL_RECT.origin.x + QUESTION_MARK_FILL_RECT.size.width, QUESTION_MARK_FILL_RECT.origin.y);
//    CGPathAddLineToPoint(path, NULL, QUESTION_MARK_FILL_RECT.origin.x, QUESTION_MARK_FILL_RECT.origin.y);
////    CGContextClosePath(context);
//    
//    CGContextAddPath(context, path);
////    CGContextClip(context);

    CGContextDrawPDFPage(context, pageRef);

    
    
    // Correction rects
    
    UIColor* correctionColor = [UIColor whiteColor];
    CGRect correctionRect = [[[PDFManager manager].correctionRects objectAtIndex:0] CGRectValue];
    
    if (!CGRectEqualToRect(correctionRect, CGRectZero)) {
        
        CGContextSetFillColorWithColor(context, correctionColor.CGColor);
        CGContextFillRect(context, correctionRect);
    }
    
    
    // Bottom rect
    
    correctionRect = [[[PDFManager manager].bottomCorrections objectAtIndex:0] CGRectValue];
    
    if (!CGRectEqualToRect(correctionRect, CGRectZero)) {
        
        CGContextSetFillColorWithColor(context, correctionColor.CGColor);
        CGContextFillRect(context, correctionRect);
    }
    
    
    UIImage* image =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();


    
    //convert to grayscale
    
    image = [self convertImageToGrayScale:image];
    
    
    
    
    UIGraphicsBeginImageContextWithOptions(THUMBNAIL_MAX_SIZE, FALSE, 0.0f);
    context = UIGraphicsGetCurrentContext();
    
    // 2. draw background image
    CGContextDrawImage(context, CGRectMake(0, 0, THUMBNAIL_MAX_SIZE.width, THUMBNAIL_MAX_SIZE.height), _backgroundImage.CGImage);
    
    // 3. rendering image in scaled format
//    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGSize scaledSize = CGSizeScaleToSize(image.size, THUMBNAIL_INNER_RECT.size, NO);
//    CGContextFillRect(context, CGRectMake(0, 0, THUMBNAIL_MAX_SIZE.width, THUMBNAIL_MAX_SIZE.height));
    CGContextTranslateCTM(context, 0.0, THUMBNAIL_MAX_SIZE.height);
    CGContextScaleCTM(context, 1.0, -1.0);
//    CGContextDrawImage(context, CGRectMake(0, THUMBNAIL_MAX_SIZE.height - scaledSize.height, scaledSize.width, scaledSize.height), image.CGImage);
    CGContextDrawImage(context, CGRectMake(THUMBNAIL_INNER_RECT.origin.x, THUMBNAIL_INNER_RECT.origin.y, scaledSize.width, scaledSize.height), image.CGImage);
    
    // 3.5 draw blend image
    
    CGContextDrawImage(context, CGRectMake(0, 0, THUMBNAIL_MAX_SIZE.width, THUMBNAIL_MAX_SIZE.height), _blendImage.CGImage);
    
    
    // 4. draw page number
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, - THUMBNAIL_MAX_SIZE.height);
    NSString* text = [NSString stringWithFormat:@"%d", number];
    CGSize textSize = [text sizeWithFont:PAGE_NUMBER_FONT];
//    NSLog(@"text size: %@", NSStringFromCGSize(textSize));
    uint marginBottom = 1;
    CGPoint textPoint = CGPointMake((THUMBNAIL_MAX_SIZE.width - textSize.width) / 2, 
                                    THUMBNAIL_MAX_SIZE.height - textSize.height - marginBottom);
    
    // glow
    
    CGContextSetTextDrawingMode(context, kCGTextStroke);
//    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.8);
    CGContextSetLineWidth(context, 2);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    //        [self.titleLabel.text drawInRect:CGRectMake(centerPoint.x, centerPoint.y + 1, textSize.width, textSize.height) withFont:self.titleLabel.font];
    [text drawAtPoint:CGPointMake(textPoint.x, textPoint.y) withFont:PAGE_NUMBER_FONT];
    
    // text
    
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.85);
    CGContextSetTextDrawingMode(context, kCGTextFill);
//    CGContextSetLineWidth(context, 1);
    CGContextSetLineJoin(context, kCGLineJoinRound);
//    CGRect textRect = CGRectMake((THUMBNAIL_INNER_RECT.size.width - textSize.width) / 2, (THUMBNAIL_INNER_RECT.size.height - textSize.height) / 2, textSize.width, textSize.height);
   
    [text drawAtPoint:textPoint withFont:PAGE_NUMBER_FONT];
    
    
    UIImage* image2 =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image2;
}


- (UIImage*) createBackgroundImage {

    UIGraphicsBeginImageContextWithOptions(THUMBNAIL_MAX_SIZE, FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, THUMBNAIL_MAX_SIZE.width, THUMBNAIL_MAX_SIZE.height);
    
    CGContextClearRect(context, rect);
    
    CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGMutablePathRef gridPath = CGPathCreateMutable();
    
    int arcRadius = THUMBNAIL_MAX_SIZE.height * 0.2;
    int margin = 1;
    int lineWidth = 1;
    
    CGContextSetLineWidth(context, lineWidth);
    
    CGRect innerRect = CGRectMake(rect.origin.x + margin, rect.origin.y + margin, rect.size.width - margin * 2, rect.size.height - margin * 2);
    
    CGPathMoveToPoint(gridPath, NULL, innerRect.origin.x + arcRadius, innerRect.origin.y);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width - arcRadius, innerRect.origin.y);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + arcRadius, arcRadius);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + innerRect.size.height - arcRadius);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + innerRect.size.height, innerRect.origin.x + innerRect.size.width - arcRadius, innerRect.origin.y + innerRect.size.height, arcRadius);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x + arcRadius, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x, innerRect.origin.y + innerRect.size.height, innerRect.origin.x, innerRect.origin.y + innerRect.size.height - arcRadius, arcRadius);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x, innerRect.origin.y + arcRadius);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x, innerRect.origin.y, innerRect.origin.x + arcRadius, innerRect.origin.y, arcRadius);
    CGContextClosePath(context);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, gridPath);


    
    CGContextClip(context);
    
//    CGContextSetRGBFillColor(context, 255.0/255, 255.0/255, 255.0/255, 1.0);
//    CGContextSetFillColorWithColor(context, _foregroundColor.CGColor);
//    
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    

    
//    CGContextRestoreGState(context);
//    CGContextAddPath(context, gridPath);
//    CGContextSetRGBStrokeColor(context, 200.0/255, 200.0/255, 200.0/255, 1.0);
//    CGContextDrawPath(context, kCGPathStroke);
        
    UIImage* image =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    
    
    
    // create blend image
    
    UIGraphicsBeginImageContextWithOptions(THUMBNAIL_MAX_SIZE, FALSE, 0.0f);
    context = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(context, gridPath);
    CGContextClip(context);
    CGContextSetFillColorWithColor(context, [_foregroundColor colorWithAlphaComponent:0.5].CGColor);
    CGContextFillRect(context, rect);
    
    _blendImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object  
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}


- (void) saveImage:(UIImage *)image toPNGFile:(NSString *)filePath {
    
    BOOL success = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:TRUE];
    
//    NSLog(@"write successful: %d", success);
}




























#pragma mark - New Rendering

- (NSArray*) createThumbnails2BeginningWithPageNumber:(uint)number scaleFactor:(float)scaleFactor {
    
    _backgroundImage = [self createBackgroundImage2WithScaleFactor:scaleFactor];
    
    uint numberOfPages = CGPDFDocumentGetNumberOfPages([PDFManager manager].exercisesDocumentRef);
    
    NSMutableArray* images = [NSMutableArray array];
    
    for (int p = 1; p <= numberOfPages; ++p) {
        NSLog(@"creating page: %d", p);
        CGPDFPageRef pageRef = CGPDFDocumentGetPage([PDFManager manager].exercisesDocumentRef, p);
        UIImage* image = [self renderPDFPage2:pageRef withPageNumber:number + p - 1 scaleFactor:scaleFactor];
        [images addObject:image];
        
    }
    
    return images;
}


- (UIImage*) renderPDFPage2:(CGPDFPageRef)pageRef withPageNumber:(uint)number scaleFactor:(float) scaleFactor {
    
    // 1. rendering pdf in full size

    CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox));
    UIGraphicsBeginImageContextWithOptions(pageRect.size, FALSE, scaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGAffineTransform transform = CGPDFPageGetDrawingTransform(pageRef, kCGPDFCropBox, CGRectMake(0, 0, pageRect.size.width, pageRect.size.height), 0, true);
    CGContextConcatCTM(context, transform);
    CGContextDrawPDFPage(context, pageRef);
    
    // Correction rects
    
    UIColor* correctionColor = [UIColor whiteColor];
    CGRect correctionRect = [[[PDFManager manager].correctionRects objectAtIndex:0] CGRectValue];
    
    if (!CGRectEqualToRect(correctionRect, CGRectZero)) {
        
        CGContextSetFillColorWithColor(context, correctionColor.CGColor);
        CGContextFillRect(context, correctionRect);
    }

    // Bottom rect
    
    correctionRect = [[[PDFManager manager].bottomCorrections objectAtIndex:0] CGRectValue];
    
    if (!CGRectEqualToRect(correctionRect, CGRectZero)) {
        
        CGContextSetFillColorWithColor(context, correctionColor.CGColor);
        CGContextFillRect(context, correctionRect);
    }
    
    UIImage* image =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //convert to grayscale
    
    image = [self convertImageToGrayScale:image];
    
    
    
    
    UIGraphicsBeginImageContextWithOptions(THUMBNAIL_MAX_SIZE2, FALSE, scaleFactor);
    context = UIGraphicsGetCurrentContext();
    
    // 2. draw background image
    [_backgroundImage drawInRect:CGRectMake(0, 0, THUMBNAIL_MAX_SIZE2.width, THUMBNAIL_MAX_SIZE2.height)];
    
    // 3. rendering image in scaled format
    CGSize scaledSize = CGSizeScaleToSize(image.size, THUMBNAIL_INNER_RECT2.size, NO);
  
    [image drawInRect:CGRectMake(THUMBNAIL_INNER_RECT2.origin.x, THUMBNAIL_INNER_RECT2.origin.y, scaledSize.width, scaledSize.height) blendMode:kCGBlendModeMultiply alpha:1.0];
    
    
    // 4. draw page number
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetFillColorWithColor(context, TEXT_COLOR2.CGColor);
    NSString* text = [NSString stringWithFormat:@"%d", number];
    CGSize textSize = [text sizeWithFont:PAGE_NUMBER_FONT2];
    uint marginBottom = 0;
    CGPoint textPoint = CGPointMake((THUMBNAIL_MAX_SIZE2.width - textSize.width) / 2,
                                    THUMBNAIL_MAX_SIZE2.height - textSize.height - marginBottom);
    
    // text
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    [text drawAtPoint:textPoint withFont:PAGE_NUMBER_FONT2];
    
    
    UIImage* image2 =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image2;
}


- (UIImage*) createBackgroundImage2WithScaleFactor:(float) scaleFactor {
    
    UIGraphicsBeginImageContextWithOptions(THUMBNAIL_MAX_SIZE2, FALSE, scaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, THUMBNAIL_MAX_SIZE2.width, THUMBNAIL_MAX_SIZE2.height);
    
    CGContextClearRect(context, rect);
    
//    CGContextSetFillColorWithColor(context, THUMBNAIL_BACKGROUND_COLOR2.CGColor);
//    CGContextFillRect(context, rect);
    
    CGMutablePathRef gridPath = CGPathCreateMutable();
    
    int arcRadius = THUMBNAIL_ARC_RADIUS2;
    int margin = 0;
//    int lineWidth = 1;
    
//    CGContextSetLineWidth(context, lineWidth);
    
    CGRect innerRect = CGRectMake(rect.origin.x + margin, rect.origin.y + margin, rect.size.width - margin * 2, rect.size.height - margin * 2);
    
    CGPathMoveToPoint(gridPath, NULL, innerRect.origin.x + arcRadius, innerRect.origin.y);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width - arcRadius, innerRect.origin.y);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + arcRadius, arcRadius);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + innerRect.size.height - arcRadius);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + innerRect.size.height, innerRect.origin.x + innerRect.size.width - arcRadius, innerRect.origin.y + innerRect.size.height, arcRadius);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x + arcRadius, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x, innerRect.origin.y + innerRect.size.height, innerRect.origin.x, innerRect.origin.y + innerRect.size.height - arcRadius, arcRadius);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x, innerRect.origin.y + arcRadius);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x, innerRect.origin.y, innerRect.origin.x + arcRadius, innerRect.origin.y, arcRadius);
    CGContextClosePath(context);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, gridPath);
    
    
    
    CGContextClip(context);
    
    //    CGContextSetRGBFillColor(context, 255.0/255, 255.0/255, 255.0/255, 1.0);
    //    CGContextSetFillColorWithColor(context, _foregroundColor.CGColor);
    //
    
    CGContextSetFillColorWithColor(context, THUMBNAIL_BACKGROUND_COLOR2.CGColor);
    CGContextFillRect(context, rect);
    
    
    
    //    CGContextRestoreGState(context);
    //    CGContextAddPath(context, gridPath);
    //    CGContextSetRGBStrokeColor(context, 200.0/255, 200.0/255, 200.0/255, 1.0);
    //    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage* image =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    
    
    
//    // create blend image
//    
//    UIGraphicsBeginImageContextWithOptions(THUMBNAIL_MAX_SIZE2, FALSE, 0.0f);
//    context = UIGraphicsGetCurrentContext();
//    
//    CGContextAddPath(context, gridPath);
//    CGContextClip(context);
//    CGContextSetFillColorWithColor(context, [_foregroundColor colorWithAlphaComponent:0.5].CGColor);
//    CGContextFillRect(context, rect);
//    
//    _blendImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    return image;
}
@end
