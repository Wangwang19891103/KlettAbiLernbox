//
//  NoteViewAnimationLayer.m
//  KlettAbiLernboxen
//
//  Created by Wang on 11.10.12.
//
//

#import "NoteViewAnimationLayer.h"
#import "BeveledCircle.h"


#define ELLIPSE_COLOR [UIColor blueColor]
#define ELLIPSE_INNER_ALPHA 1.0f
#define ELLIPSE_OUTER_ALPHA 0.0f
#define ELLIPSE_MAX_TOTAL_ALPHA 0.75f
/* min_total_alpha = 0.0 */
#define ELLIPSE_NUMBER_OF_RINGS 15
/* outer-inner-outer, ex.: 1 2 3 4 5 4 3 2 1 */

 
@implementation NoteViewAnimationLayer

/* class constants */
static BOOL __initialized;
static uint __minRadius;
static uint __maxRadius;
static uint __radiusDiff;
static UIColor* __ellipseColor;
static float __ellipseAlphaDiff;


#pragma mark - Initialization

- (id) initWithFrame:(CGRect)theFrame {
    
    if (self = [super initWithFrame:theFrame]) {

        [self initialize];
        
        self.numberOfFrames = __radiusDiff;
    }
    
    return self;
}


- (void) initialize {
    
    /* initialize class constants */
    
    if (!__initialized) {
        __initialized = TRUE;
        __ellipseColor = ELLIPSE_COLOR;
        __minRadius = self.bounds.size.width / 2 * 0.1;
        __maxRadius = self.bounds.size.width / 2;
        __radiusDiff = __maxRadius - __minRadius;
        __ellipseAlphaDiff = ELLIPSE_INNER_ALPHA - ELLIPSE_OUTER_ALPHA;
    }
}


#pragma mark - AnimationLayer Methods

- (void) animateWithDuration:(float)duration {
    
    [self initialize];

    [super animateWithDuration:duration];
}


- (void) drawInContext:(CGContextRef)context forFrame:(uint)frame {
    
    /* if last frame dont render anything */
    if (frame == self.numberOfFrames) return;
    
    
    float theProgress =  (float)frame / self.numberOfFrames;
    float width = self.bounds.size.width;
    /* height = width because of circle */
    uint currentRadius = __minRadius + (__radiusDiff * theProgress);
    

    
    
//    float ellipseRectMargin = (width - (currentRadius * 2)) * 0.5;
//    
//    CGRect ellipseRect = CGRectMake(ellipseRectMargin, ellipseRectMargin, currentRadius * 2, currentRadius * 2);
//    UIColor* color = [__ellipseColor colorWithAlphaComponent:1.0 - theProgress];
//    
//    
//    
//    CGContextSetStrokeColorWithColor(context, color.CGColor);
//    CGContextSetLineWidth(context, 1.0f);
//    CGContextAddEllipseInRect(context, ellipseRect);
    
    CGColorRef innerColor = [__ellipseColor colorWithAlphaComponent:alphaForProgress(theProgress) * ELLIPSE_INNER_ALPHA].CGColor;
    CGColorRef outerColor = [__ellipseColor colorWithAlphaComponent:alphaForProgress(theProgress) * ELLIPSE_OUTER_ALPHA].CGColor;
    
    NSLog(@"outerColor: %@", [__ellipseColor colorWithAlphaComponent:alphaForProgress(theProgress) * ELLIPSE_OUTER_ALPHA]);
    
    drawBeveledCircle(context, CGPointMake(width * 0.5, width * 0.5), currentRadius, ELLIPSE_NUMBER_OF_RINGS, innerColor, outerColor);
    
    NSLog(@"rendering frame: %d, currentRadius=%d", frame, currentRadius);
}


#pragma mark - Functions

float alphaForProgress(float theProgress) {
    
    return ELLIPSE_MAX_TOTAL_ALPHA * (1.0f - theProgress);
}


@end
