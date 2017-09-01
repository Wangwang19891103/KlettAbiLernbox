//
//  CustomLabel.m
//  KlettAbiLernboxen
//
//  Created by Wang on 02.12.12.
//
//

#import "CustomLabel.h"
#import <QuartzCore/QuartzCore.h>


#define DropShadow_Color [UIColor whiteColor]
#define InnerShadow_Color [UIColor blackColor]
#define Stroke_Color [UIColor blackColor]

#define DropShadow_Offset CGSizeMake(0,1)
#define InnerShadow_Offset CGSizeMake(0,-1)

#define Stroke_Width 1.0f

#define DropShadow_Opacity 0.84f
#define InnerShadow_Opacity 0.75f
#define Stroke_Opacity 0.3f

#define DropShadow_Blur 0.5f
#define InnerShadow_Blur 0.5f

#define Insets UIEdgeInsetsMake(1,1,1,1)


@implementation CustomLabel

@synthesize title;
@synthesize font;
@synthesize textColor;


// color
static UIColor* dropShadowColor = nil;
static UIColor* innerShadowColor = nil;
static UIColor* strokeColor = nil;

// offset
static CGSize dropShadowOffset;
static CGSize innerShadowOffset;

// width
static float strokeWidth;

// opacity
static float dropShadowOpacity;
static float innerShadowOpacity;
static float strokeOpacity;

// blur
static float dropShadowBlur;
static float innerShadowBlur;

// insets
static UIEdgeInsets insets;


static float dummyOpacity;


- (id) init {
    
    if (self = [super init]) {
        
        [self initialize];
        
        self.opaque = FALSE;
        self.backgroundColor = [UIColor clearColor];
        
        PBaddObserver(self);
    }
    
    return self;
}


- (void) initialize {
    
    if (!dropShadowColor) {
        
        dropShadowColor = DropShadow_Color;
        innerShadowColor = InnerShadow_Color;
        strokeColor = Stroke_Color;
//
//        dropShadowOffset = DropShadow_Offset;
//        innerShadowOffset = InnerShadow_Offset;
//        
//        strokeWidth = Stroke_Width;
//        
//        dropShadowOpacity = DropShadow_Opacity;
//        innerShadowOpacity = InnerShadow_Opacity;
//        strokeOpacity = Stroke_Opacity;
//        
//        dropShadowBlur = DropShadow_Blur;
//        innerShadowBlur = InnerShadow_Blur;

        dropShadowOffset.height = PBintVarValue(@"Title DropShadow offsetY") * 0.1;
        dropShadowOpacity = PBintVarValue(@"Title DropShadow opacity") * 0.01;
        innerShadowOffset.height = PBintVarValue(@"Title InnerShadow offsetY") * 0.1;
        innerShadowOpacity = PBintVarValue(@"Title InnerShadow opacity") * 0.01;
        strokeWidth = PBintVarValue(@"Title Stroke width") * 0.1;
        strokeOpacity = PBintVarValue(@"Title Stroke opacity") * 0.01;
        dropShadowBlur = PBintVarValue(@"Title DropShadow blur") * 0.01;
        innerShadowBlur = PBintVarValue(@"Title InnerShadow blur") * 0.01;
        
        dummyOpacity = PBintVarValue(@"Title Dummy opacity") * 0.01;
        
        insets = Insets;
    }
}


- (void) variableValueChangedForName:(NSString *)name {
    
    if ([name isEqualToString:@"Title DropShadow offsetY"]
        || [name isEqualToString:@"Title DropShadow opacity"]
        || [name isEqualToString:@"Title InnerShadow offsetY"]
        || [name isEqualToString:@"Title InnerShadow opacity"]
        || [name isEqualToString:@"Title Stroke width"]
        || [name isEqualToString:@"Title Stroke opacity"]
        || [name isEqualToString:@"Title DropShadow blur"]
        || [name isEqualToString:@"Title InnerShadow blur"]
        || [name isEqualToString:@"Title Dummy opacity"]
        ) {
        
        dropShadowOffset.height = PBintVarValue(@"Title DropShadow offsetY") * 0.1;
        dropShadowOpacity = PBintVarValue(@"Title DropShadow opacity") * 0.01;
        innerShadowOffset.height = PBintVarValue(@"Title InnerShadow offsetY") * 0.1;
        innerShadowOpacity = PBintVarValue(@"Title InnerShadow opacity") * 0.01;
        strokeWidth = PBintVarValue(@"Title Stroke width") * 0.1;
        strokeOpacity = PBintVarValue(@"Title Stroke opacity") * 0.01;
        dropShadowBlur = PBintVarValue(@"Title DropShadow blur") * 0.01;
        innerShadowBlur = PBintVarValue(@"Title InnerShadow blur") * 0.01;
        
        dummyOpacity = PBintVarValue(@"Title Dummy opacity") * 0.01;

        [self setNeedsDisplay];
    }
}

- (void) update {
    
    CGSize textSize = [title sizeWithFont:font];
    CGRect newBounds;
    newBounds.size = CGSizeMake(textSize.width + insets.left + insets.right, textSize.height + insets.top + insets.bottom);
//    self.bounds = newBounds;
    [self setFrameSize:newBounds.size];
    
    [self setNeedsDisplay];
}


- (void) drawRect:(CGRect)rect {
    
//    alert(@"draw");
    
    
    UIGraphicsBeginImageContextWithOptions(rect.size, FALSE, 2.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [textColor setFill];
    [[strokeColor colorWithAlphaComponent:strokeOpacity] setStroke];

    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    
    CGSize textSize = [title sizeWithFont:font];
    CGRect textRect = CGRectMake(insets.left,
                                 insets.top,
                                 textSize.width + insets.left + insets.right,
                                 textSize.height + insets.top + insets.bottom);

    // fill text with drop shadow
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, dropShadowOffset,dropShadowBlur, [dropShadowColor colorWithAlphaComponent:dropShadowOpacity].CGColor);
    [title drawInRect:textRect withFont:font];
    CGContextRestoreGState(context);
    
    // white text overlay for "outer" stroke
    CGContextSetLineWidth(context, 0);
    [[UIColor clearColor] setStroke];
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    [[textColor colorWithAlphaComponent:dummyOpacity] setFill];
    [title drawInRect:textRect withFont:font];
    
    
    UIImage* firstImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    // inner shadow
    UIImage* innerShadowImage = [self innerShadowImageForRect:rect];
//    [innerShadowImage drawAtPoint:CGPointZero];

    
    [firstImage saveInDocumentsWithName:@"firstImage.png"];
    [innerShadowImage saveInDocumentsWithName:@"innerShadowImage.png"];
    
    
    // resize
    UIGraphicsBeginImageContextWithOptions(rect.size, FALSE, 0.0f);
    context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);

    [firstImage drawInRect:rect];
    [innerShadowImage drawInRect:rect];
    
    UIImage* finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    // draw actual context
    [finalImage drawAtPoint:CGPointZero];
    
    [finalImage saveInDocumentsWithName:@"finalImage.png"];
    
}


- (UIImage*) innerShadowImageForRect:(CGRect) rect {

    CGSize textSize = [title sizeWithFont:font];
    CGRect textRect = CGRectMake(insets.left,
                                 insets.top,
                                 textSize.width + insets.left + insets.right,
                                 textSize.height + insets.top + insets.bottom);
    

    // white text on black background
    UIGraphicsBeginImageContextWithOptions(rect.size, FALSE, 2.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, rect);
    [[UIColor whiteColor] setFill];
    CGContextSetLineWidth(context, 0);
    [[UIColor clearColor] setStroke];
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    [title drawInRect:textRect withFont:font];
    UIImage* textImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // mask (transparent text on white background)
    CGImageRef textImageRef = textImage.CGImage;
    CGImageRef maskImageRef = CGImageMaskCreate(CGImageGetWidth(textImageRef),
                                             CGImageGetHeight(textImageRef),
                                             CGImageGetBitsPerComponent(textImageRef),
                                             CGImageGetBitsPerPixel(textImageRef),
                                             CGImageGetBytesPerRow(textImageRef),
                                             CGImageGetDataProvider(textImageRef),
                                             NULL,
                                             false);

    // black image (box)
    UIGraphicsBeginImageContextWithOptions(rect.size, FALSE, 2.0f);
    context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, rect);
    UIImage* blackImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // cutout (transparent text on black background)
    CGImageRef cutoutImageRef = CGImageCreateWithMask(blackImage.CGImage, maskImageRef);
    UIImage* cutoutImage = [UIImage imageWithCGImage:cutoutImageRef scale:2.0f orientation:UIImageOrientationUp];
    
    // cutout with shadow
    UIGraphicsBeginImageContextWithOptions(rect.size, FALSE, 2.0f);
    context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, rect);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, innerShadowOffset, innerShadowBlur, [innerShadowColor colorWithAlphaComponent:innerShadowOpacity].CGColor);
    [cutoutImage drawAtPoint:CGPointZero];
    CGContextRestoreGState(context);
    UIImage* cutoutImage2 = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef cutoutImage2Ref = cutoutImage2.CGImage;
    UIGraphicsEndImageContext();
    
    // black text on white background
    UIGraphicsBeginImageContextWithOptions(rect.size, FALSE, 2.0f);
    context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setFill];
    CGContextSetLineWidth(context, 0);
    [[UIColor clearColor] setStroke];
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    [title drawInRect:textRect withFont:font];
    UIImage* textImage2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // final shadow image
    CGImageRef maskImageRef2 = CGImageMaskCreate(CGImageGetWidth(cutoutImage2Ref),
                                                 CGImageGetHeight(cutoutImage2Ref),
                                                 CGImageGetBitsPerComponent(cutoutImage2Ref),
                                                 CGImageGetBitsPerPixel(cutoutImage2Ref),
                                                 CGImageGetBytesPerRow(cutoutImage2Ref),
                                                 CGImageGetDataProvider(cutoutImage2Ref),
                                                 NULL,
                                                 false);
    
    UIImage* maskImage2 = [UIImage imageWithCGImage:maskImageRef2 scale:2.0f orientation:UIImageOrientationUp];;
    
//    [textImage saveInDocumentsWithName:@"textImage.png"];
//    [cutoutImage2 saveInDocumentsWithName:@"cutoutImage2.png"];
//    [maskImage2 saveInDocumentsWithName:@"maskImage2.png"];
//    [textImage2 saveInDocumentsWithName:@"textImage2.png"];
    
    CGImageRef shadowImageRef = CGImageCreateWithMask(textImage2.CGImage, maskImageRef2);
    UIImage* shadowImage = [UIImage imageWithCGImage:shadowImageRef scale:2.0f orientation:UIImageOrientationUp];

//    [shadowImage saveInDocumentsWithName:@"shadowImage.png"];
    
    // release
    CGImageRelease(cutoutImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(shadowImageRef);
    CGImageRelease(maskImageRef2);

    return shadowImage;
}

@end
