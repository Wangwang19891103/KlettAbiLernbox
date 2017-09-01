//
//  PDFView.m
//  KlettAbiLernboxen
//
//  Created by Wang on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PDFView.h"
#import <QuartzCore/QuartzCore.h>
#import "Scanner.h"
#import "PropertyBoard.h"
#import "PDFManager.h"


//#define CORRECTION_RECT_COLOR [[UIColor redColor] colorWithAlphaComponent:0.5]
#define CORRECTION_RECT_COLOR [UIColor whiteColor]
#define SEPERATOR_RECT_COLOR [UIColor blackColor]


@implementation PDFView

@synthesize pageRef;
@synthesize keywords;
@synthesize selections;
@synthesize documentType;
@synthesize pageNumber;


- (id) initWithPage:(CGPDFPageRef) thePageRef {
    
    if (self = [super init]) {
        
        self.pageRef = thePageRef;

//        // -- DELETE
//        
//        NSString* path1 = [[NSBundle mainBundle] pathForResource:@"Geschichte_Karte_9_Antwort_14p.pdf" ofType:nil];
//        CFStringRef path2 = CFStringCreateWithCString (NULL, [path1 UTF8String], kCFStringEncodingUTF8);
//        CFURLRef url = CFURLCreateWithFileSystemPath (NULL, path2, kCFURLPOSIXPathStyle, 0);
//        CGPDFDocumentRef docRef2 = CGPDFDocumentCreateWithURL(url);
//        self.pageRef = CGPDFDocumentGetPage(docRef2, 1);
//        
//        // -- DELETE
        
        CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(self.pageRef, kCGPDFCropBox));
        self.frame = CGRectMake(0, 0, pageRect.size.width, pageRect.size.height);
        CATiledLayer* tiledLayer = (CATiledLayer*) self.layer;
        tiledLayer.delegate = self;
        tiledLayer.tileSize = CGSizeMake(1024.0, 1024.0);
        tiledLayer.levelsOfDetail = 4;
        tiledLayer.levelsOfDetailBias = 4;
        tiledLayer.frame = self.frame;
        
        _backgroundImage = [resource(@"Images.DocumentView.Background") resizableImageWithCapInsets:UIEdgeInsetsZero];
        _patternColor = CGColorRetain([UIColor colorWithPatternImage:_backgroundImage].CGColor);

        [[PropertyBoard instance] addChangeObserver:self];
    }
    
    return self;
}




+ (Class) layerClass {
    
    return [CATiledLayer class];
}


//- (void) setKeywords:(NSArray *)theKeywords {
//    
//    NSLog(@"setKeywords");
//    
//    keywords = theKeywords;
//    
//    timer_start(@"total_time_parse_selections");
//    
//    for (NSString* keyword in theKeywords) {
//        
//        NSLog(@"keyword: %@", keyword);
//        
//        Scanner* scanner = [[Scanner alloc] init];
//        scanner.keyword = keyword;
//        [scanner scanPage:self.pageRef];
//        for (Selection* selection in scanner.selections) {
//            [self.selections addObject:selection];
//            NSLog(@"selection: %@", selection);
//        }
//        
//    }
//    
//    counter_incF(@"total_time_parse_selections", timer_passed(@"total_time_parse_selections"));
//}


- (void) didMoveToSuperview {
    
//    NSLog(@"PDFView didMoveToSuperview");
}


- (void) setPageRef:(CGPDFPageRef)thePageRef {
    
    pageRef = thePageRef;
    CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(thePageRef, kCGPDFCropBox));
    self.bounds = CGRectMake(0, 0, pageRect.size.width, pageRect.size.height);
    CATiledLayer* tiledLayer = (CATiledLayer*) self.layer;
    tiledLayer.bounds = self.bounds;
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {

//    NSLog(@"PDFView drawLayer");
    
    
    
//    CGPDFDocumentRef newDocument = [self newCorrectedPDFDocumentForPage:self.pageRef pageRect:CGRectIntegral(CGPDFPageGetBoxRect(self.pageRef, kCGPDFCropBox))];
//    
//    CGPDFPageRef newPage = CGPDFDocumentGetPage(newDocument, 1);
    
    // parse selections for keywords at the first time the pdf is being displayed

//    if (!self.selections && self.keywords) {
//        timer_start(@"total_time_parse_selections");
//        
//        self.selections = [NSMutableArray array];
//        
//        for (NSString* keyword in self.keywords) {
//            
//            NSLog(@"keyword: %@", keyword);
//            
//            Scanner* scanner = [[Scanner alloc] init];
//            scanner.keyword = keyword;
//            [scanner scanPage:self.pageRef];
////            [scanner scanPage:newPage];
//            for (Selection* selection in scanner.selections) {
//                [self.selections addObject:selection];
//                NSLog(@"selection: %@", selection);
//            }
//            
//        }
//        
//        counter_incF(@"total_time_parse_selections", timer_passed(@"total_time_parse_selections"));
//        counter_printall;
//        counter_removeAll;
//    }


    CGContextSaveGState(context);

    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
//    NSLog(@"_backgroundImage: %@", _backgroundImage);
    CGContextSetFillColorWithColor(context, _patternColor);
    
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));

//    [backgroundImage drawInRect:CGContextGetClipBoundingBox(context) blendMode:kCGBlendModeNormal alpha:1.0];
    
    
    CGContextTranslateCTM(context, 0.0, layer.bounds.size.height);
    
    //    CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(_pageRef, kCGPDFCropBox));
    //    float ratio = layer.frame.size.width / pageRect.size.width;
    //    NSLog(@"page rect: %@", NSStringFromCGRect(pageRect));
    //    NSLog(@"ratio: %f", ratio);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGAffineTransform transform = CGPDFPageGetDrawingTransform(self.pageRef, kCGPDFCropBox, layer.bounds, 0, true);
//    CGAffineTransform transform = CGPDFPageGetDrawingTransform(newPage, kCGPDFCropBox, layer.bounds, 0, true);
//    CGAffineTransform transform2 = CGPDFPageGetDrawingTransform(self.pageRef, kCGPDFMediaBox, layer.bounds, 0, true);
    CGContextConcatCTM(context, transform);
    
//    NSLog(@"PDFView, transformation: %@", NSStringFromCGAffineTransform(transform));
    
//    CGContextFillRect(context, QUESTION_MARK_FILL_RECT);

    

//    CGContextSetFillColorWithColor(context, [[UIColor yellowColor] colorWithAlphaComponent:0.5].CGColor);
//
//    for (Selection* selection in self.selections) {
//
//        CGRect selectionRect = CGRectApplyAffineTransform(selection.frame, selection.transform);
//        CGContextFillRect(context, selectionRect);
//
//        LogM(@"PDF_selections", @"pdfview rect:\t%@", NSStringFromCGRect(layer.bounds));
//        
//        LogM(@"PDF_selections", @"pdf media box:\t%@\n", NSStringFromCGRect(CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox)));
//        LogM(@"PDF_selections", @"pdf crop box:\t%@\n", NSStringFromCGRect(CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox)));
//        LogM(@"PDF_selections", @"pdf transform:\t%@\n", NSStringFromCGAffineTransform(transform));
//        
//        LogM(@"PDF_selections", @"selection rect:\t%@\n", NSStringFromCGRect(selection.frame));
//        LogM(@"PDF_selections", @"selection transform:\t%@\n", NSStringFromCGAffineTransform(selection.transform));
//        LogM(@"PDF_selections", @"selection transformed rect:\t%@\n", NSStringFromCGRect(selectionRect));
//        
//        //        CGContextSaveGState(context);
//        //        CGContextConcatCTM(context, selection.transform);
//        //        CGContextFillRect(context, selection.frame);
//        //        CGContextRestoreGState(context);
//        
//        
//        LogM_write(@"PDF_selections");
//        
//        break; // only 1
//    }
    
    
    
//    CGAffineTransform translation = CGAffineTransformMakeTranslation(- pageRect.origin.x, - pageRect.origin.y);
//    NSLog(@"crop box rect: %@", NSStringFromCGRect(CGPDFPageGetBoxRect(_pageRef, kCGPDFCropBox)));
//    NSLog(@"layer bounds: %@", NSStringFromCGRect(layer.bounds));
//    CGAffineTransform scaling = CGAffineTransformMakeScale(ratio, ratio);
//    CGAffineTransform transform = CGAffineTransformConcat(translation, scaling);

//    NSLog(@"affine transform: %@", NSStringFromCGAffineTransform(transform));

    
//    CGContextConcatCTM(context, CGAffineTransformInvert(transform2));
//    CGContextConcatCTM(context, transform);

//    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), _backgroundImage.CGImage);
    
    CGContextDrawPDFPage(context, self.pageRef);
//    CGContextDrawPDFPage(context, newPage);
    
    
    
    // Selections
    
//    if (self.keywords)
//    {
//        CGContextSetFillColorWithColor(context, [[UIColor yellowColor] CGColor]);
//        CGContextSetBlendMode(context, kCGBlendModeMultiply);
//        for (Selection *s in self.selections)
//        {
//            CGContextSaveGState(context);
//            CGContextConcatCTM(context, s.transform);
//            CGContextFillRect(context, s.frame);
//            CGContextRestoreGState(context);
//        }
//    }
    
    
//    CGContextSetRGBFillColor(context, 1.0, 0, 0, 0.3);
    
    
    // Correction rects
    
    UIColor* correctionColor = nil;
    
//    UIColor* correctionColor = CORRECTION_RECT_COLOR;
    CGRect correctionRect = [[[PDFManager manager].correctionRects objectAtIndex:documentType] CGRectValue];
    
//    if (CGRectEqualToRect(correctionRect, CGRectZero)) {
//    
//        int correctionX = [PBvarValue(@"x") intValue];
//        int correctionY = [PBvarValue(@"y") intValue];
//        int correctionWidth = [PBvarValue(@"width") intValue];
//        int correctionHeight = [PBvarValue(@"height") intValue];
//        float correctionAlpha = [PBvarValue(@"alpha") intValue] * 0.01f;
//        
//        correctionRect = CGRectMake(correctionX, correctionY, correctionWidth, correctionHeight);
//        correctionColor = [[UIColor redColor] colorWithAlphaComponent:correctionAlpha];
//
//    }

    if (!CGRectEqualToRect(correctionRect, CGRectZero)) {
    
//        CGContextSetFillColorWithColor(context, correctionColor.CGColor);  // turn off afterwards
        CGContextFillRect(context, correctionRect);
    }
    
    
    // Bottom rect
    
//    correctionColor = CORRECTION_RECT_COLOR;
    
    correctionRect = [[PDFManager manager] bottomCorrectionRectForPageNumber:pageNumber documentType:documentType];
    
    if (CGRectEqualToRect(correctionRect, CGRectZero)) {
    
        correctionRect = [[[PDFManager manager].bottomCorrections objectAtIndex:documentType] CGRectValue];
    }
    
//    if (CGRectEqualToRect(correctionRect, CGRectZero)) {
//        
//        int correctionX = [PBvarValue(@"x") intValue];
//        int correctionY = [PBvarValue(@"y") intValue];
//        int correctionWidth = [PBvarValue(@"width") intValue];
//        int correctionHeight = [PBvarValue(@"height") intValue];
//
//        
//        correctionRect = CGRectMake(correctionX, correctionY, correctionWidth, correctionHeight);
//        correctionColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
//    }
    
    if (!CGRectEqualToRect(correctionRect, CGRectZero)) {
        
//        CGContextSetFillColorWithColor(context, correctionColor.CGColor);
        CGContextFillRect(context, correctionRect);
    }

    
    
    if (documentType == 2) {
    
        correctionRect = [[PDFManager manager] seperatorRectForPageNumber:pageNumber];
        
        if (CGRectEqualToRect(correctionRect, CGRectZero)) {

            correctionRect = [PDFManager manager].seperatorRect;
        }
        
        correctionColor = [UIColor blackColor];
        
        CGContextSetFillColorWithColor(context, correctionColor.CGColor);
        CGContextFillRect(context, correctionRect);
    }
    
    
    
    CGContextRestoreGState(context);
}


- (void) variableValueChangedForName:(NSString *)name {
    
    if ([name isEqualToString:@"x"]
        || [name isEqualToString:@"y"]
        || [name isEqualToString:@"width"]
        || [name isEqualToString:@"height"]
        || [name isEqualToString:@"alpha"]) {
        
//        NSLog(@"PDFView: variableValueChangedForName: %@", name);
        
        [self setNeedsDisplay];
    }
}


- (void) dealloc {

//    [super dealloc];
    
    CGColorRelease(_patternColor);
    
////    [_backgroundImage release];
//
//    
//    [super dealloc];
}


@end
