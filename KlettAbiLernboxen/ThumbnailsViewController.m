//
//  ThumbnailsView.m
//  KlettAbiLernboxen
//
//  Created by Wang on 08.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailsViewController.h"
#import "ModuleManager.h"
#import "PDFManager.h"
#import "UIColor+Extensions.h"


#define THUMBNAIL_SIZE CGSizeMake(60, 40)



@implementation ThumbnailsViewController

@synthesize scrollView, overlayView, contentView, delegate;


- (id) init {
    
    if (self = [super initWithNibName:@"ThumbnailsViewController" bundle:[NSBundle mainBundle]]) {
        
    }
    
    return self;
}


- (void) viewDidLoad {
    
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width * 5, self.scrollView.frame.size.height)];
//    [self.scrollView addSubview:view];
////    self.scrollView.delegate = self;
//    self.scrollView.contentSize = view.bounds.size;
//    view.backgroundColor = [UIColor greenColor];
    
    self.contentView.userInteractionEnabled = TRUE;
    
    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    NSLog(@"bgColor thumbsleiste: %@", barColor);
    self.view.backgroundColor = [barColor colorByDarkingByPercent:0.6];
}


- (void) layout {
    
    
    
    [self.overlayView setNeedsDisplay];
}


- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    NSLog(@"ThumbnailsViewController didLayoutSubviews");
}


- (void) handleTap:(UIGestureRecognizer *)recognizer {

    CGPoint location = [recognizer locationInView:self.contentView];

    if (location.x < 0 || location.x > self.contentView.frame.size.width) {
        return;
    }
    
    uint page = floor(location.x / THUMBNAIL_SIZE.width);
    
    NSLog(@"page: %d", page);
    
    [self.scrollView setContentOffset:CGPointMake(page * THUMBNAIL_SIZE.width, 0) animated:TRUE];
    
    [self.delegate thumbnailWasSelectedForPage:page];
    
}


- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.delegate thumbnailWillBeginDragging];
}


- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    if (!decelerate) {
        [self reportPage];
    }
    
    [self.delegate thumbnailDidEndDragging];
}


- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSLog(@"(thumbnail scrollview) did end decelerating");
    
    [self reportPage];
}


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static uint pageNumber = -1;

    float div = self.scrollView.contentOffset.x / THUMBNAIL_SIZE.width;
    uint fullPage = floor(div);
    float rest = div - fullPage;
    uint page = (rest > 0.5) ? fullPage + 1 : fullPage;

    if (page != pageNumber) {
        [delegate thumbnailDidHitPageNumber:page];
        pageNumber = page;
    }
}


- (void) reportPage {
    
    NSLog(@"report page");
    
//    uint page = floor(self.scrollView.contentOffset.x / THUMBNAIL_SIZE.width);
    float div = self.scrollView.contentOffset.x / THUMBNAIL_SIZE.width;
    uint fullPage = floor(div);
    float rest = div - fullPage;
    uint page = (rest > 0.5) ? fullPage + 1 : fullPage;
    
    
    [self.delegate thumbnailWasSelectedForPage:page];
}

- (void) scrollToPage:(uint)page animated:(BOOL)animated {
    
    [self.scrollView setContentOffset:CGPointMake(page * THUMBNAIL_SIZE.width, 0) animated:animated];
}


- (void) dealloc {
    
    NSLog(@"ThumbnailsViewController dealloc");
}


@end



@implementation OverlayView

@synthesize scrollView;


- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    return self.scrollView;
}


- (void) drawRect:(CGRect)rect1 {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect2 = [self convertRect:self.scrollView.frame toView:self];
    
    NSLog(@"rect2: %@", NSStringFromCGRect(rect2));
    
    CGMutablePathRef dummyPath = CGPathCreateMutable();
    CGPathMoveToPoint(dummyPath, NULL, 0, 0);
    CGPathAddLineToPoint(dummyPath, NULL, rect1.size.width, 0);
    CGPathAddLineToPoint(dummyPath, NULL, rect1.size.width, rect1.size.height);
    CGPathAddLineToPoint(dummyPath, NULL, 0, rect1.size.height);
    CGPathCloseSubpath(dummyPath);
    
    CGContextAddPath(context, dummyPath);
//    CGContextEOClip(context);
    
    
    CGMutablePathRef gridPath = CGPathCreateMutable();
    
    int arcRadius = scrollView.frame.size.height * 0.2;
    int margin = 1;
    int lineWidth = 1;
    
    CGContextSetLineWidth(context, lineWidth);
    
    CGRect innerRect = CGRectMake(rect2.origin.x + margin, rect2.origin.y + margin, rect2.size.width - margin * 2, rect2.size.height - margin * 2);
    
    CGPathMoveToPoint(gridPath, NULL, innerRect.origin.x + arcRadius, innerRect.origin.y);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width - arcRadius, innerRect.origin.y);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + arcRadius, arcRadius);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + innerRect.size.height - arcRadius);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + innerRect.size.height, innerRect.origin.x + innerRect.size.width - arcRadius, innerRect.origin.y + innerRect.size.height, arcRadius);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x + arcRadius, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x, innerRect.origin.y + innerRect.size.height, innerRect.origin.x, innerRect.origin.y + innerRect.size.height - arcRadius, arcRadius);
    CGPathAddLineToPoint(gridPath, NULL, innerRect.origin.x, innerRect.origin.y + arcRadius);
    CGPathAddArcToPoint(gridPath, NULL, innerRect.origin.x, innerRect.origin.y, innerRect.origin.x + arcRadius, innerRect.origin.y, arcRadius);
    CGPathCloseSubpath(gridPath);
    
//    CGContextSaveGState(context);
    CGContextAddPath(context, gridPath);
    
    
    
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.2);
    CGContextEOFillPath(context);
    
    
}

@end


@implementation ThumbnailsContentView


- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    NSLog(@"contentview hittest");
    
    return [super hitTest:point withEvent:event];
}


@end


@implementation ThumbnailScrollView




//- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//
//    [super touchesBegan:touches withEvent:event];
//    
//    NSLog(@"scrollview: touches began");
//}

@end
