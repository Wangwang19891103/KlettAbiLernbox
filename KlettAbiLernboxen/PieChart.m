//
//  PieChart.m
//  KlettAbiLernboxen
//
//  Created by Wang on 25.11.12.
//
//

#import "PieChart.h"


#define CHART_STARING_ANGLE 290


static inline float radians(double degrees) { return degrees * M_PI / 180; }


@implementation PieChart


static UIImage* bluePattern = nil;
static UIImage* redPattern = nil;
static UIColor* grayColor = nil;


- (id) initWithGray:(uint)gray Green:(uint)green Red:(uint)red {

    if (self = [super init]) {
        
        _gray = gray;
        _green = green;
        _red = red;
        
        self.backgroundColor = [UIColor clearColor];
        
        if (!bluePattern) {
            
            bluePattern = resource(@"Images.Misc.PatternLinedBlue");
            redPattern = resource(@"Images.Misc.PatternLinedRed");
            grayColor = [UIColor colorWithHue:0 saturation:0 brightness:0.3 alpha:1];
        }
    }
    
    return self;
}


- (void) drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);

    float chartWidth = MIN(rect.size.width, rect.size.height);
    CGRect chartRect = CGRectMake(0, 0, chartWidth, chartWidth);
    float radius = chartWidth * 0.5;
    
    uint totalAmount = _gray + _green + _red;
    float grayDegrees = ((float)_gray / totalAmount) * 360;
    float greenDegrees = ((float)_green / totalAmount) * 360;
    float redDegrees = ((float)_red / totalAmount) * 360;
    
    CGMutablePathRef greenPath = nil, grayPath = nil, redPath = nil;
    float startAngle, endAngle;
    CGPoint point;


    greenPath = CGPathCreateMutable();
    startAngle = CHART_STARING_ANGLE;
    endAngle = CHART_STARING_ANGLE + greenDegrees;
    point = CGPointMake(chartRect.size.width * 0.5, chartRect.size.height * 0.5);
    CGPathMoveToPoint(greenPath, NULL, point.x, point.y);
    CGPathAddArc(greenPath, NULL, point.x, point.y, radius, radians(startAngle), radians(endAngle), FALSE);
    CGPathCloseSubpath(greenPath);

    redPath = CGPathCreateMutable();
    startAngle = CHART_STARING_ANGLE + greenDegrees;
    endAngle = CHART_STARING_ANGLE + greenDegrees + redDegrees;
    point = CGPointMake(chartRect.size.width * 0.5, chartRect.size.height * 0.5);
    CGPathMoveToPoint(redPath, NULL, point.x, point.y);
    CGPathAddArc(redPath, NULL, point.x, point.y, radius, radians(startAngle), radians(endAngle), FALSE);
    CGPathCloseSubpath(redPath);

    grayPath = CGPathCreateMutable();
    startAngle = CHART_STARING_ANGLE + greenDegrees + redDegrees;
    endAngle = CHART_STARING_ANGLE + greenDegrees + redDegrees + grayDegrees;
    point = CGPointMake(chartRect.size.width * 0.5, chartRect.size.height * 0.5);
    CGPathMoveToPoint(grayPath, NULL, point.x, point.y);
    CGPathAddArc(grayPath, NULL, point.x, point.y, radius, radians(startAngle), radians(endAngle), FALSE);
    CGPathCloseSubpath(grayPath);
    
    
    /* filling paths */

    CGContextAddPath(context, grayPath);
    CGContextSetFillColorWithColor(context, grayColor.CGColor);
    CGContextFillPath(context);

    CGContextSaveGState(context);
    CGContextAddPath(context, greenPath);
    CGContextClip(context);
    [bluePattern drawAsPatternInRect:rect];
    CGContextRestoreGState(context);

    CGContextSaveGState(context);
    CGContextAddPath(context, redPath);
    CGContextClip(context);
    [redPattern drawAsPatternInRect:rect];
    CGContextRestoreGState(context);
    
}


- (void) variableValueChangedForName:(NSString *)name {
    
    if ([name isEqualToString:@"Statistics random"]) {
        
        _gray = arc4random() % 100;
        _red = arc4random() % 100;
        _green = arc4random() % 100;
        
        [self setNeedsDisplay];
    }
}




@end
