//
//  StatisticsViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 16.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatisticsViewController.h"
#import "GlobalCounter.h"
#import "StopTimer.h"
#import "PDFManager.h"
#import "UserDataManager.h"
#import "ModuleManager.h"
#import "UIColor+Extensions.h"
#import "TranslateIdiom.h"


#define IMAGE_WIDTH_RATIO 1.0
#define CHART_STARING_ANGLE 250
#define CHART_MAX_DISTANCE 2.4
#define CHART_MINIMUM_ANGLE_TO_DRAW 1.0

#define ANIMATION_FRAMES_PER_SECOND 30.0
#define ANIMATION_DURATION_DEGREES 1.0
#define ANIMATION_DURATION_DISTANCE 0.5


static float ANIMATION_FRAMES_DEGREES = ANIMATION_DURATION_DEGREES * ANIMATION_FRAMES_PER_SECOND;
static float PROGRESS_DEGREES_PER_TICK = 360.0 / (ANIMATION_DURATION_DEGREES * ANIMATION_FRAMES_PER_SECOND);
static float PROGRESS_DISTANCE_PER_TICK = CHART_MAX_DISTANCE / (ANIMATION_DURATION_DISTANCE * ANIMATION_FRAMES_PER_SECOND);



static inline float radians(double degrees) { return degrees * M_PI / 180; }


static inline CGPoint offsetPoint(float x, float y, float distance, float angle) {

    if (distance == 0) return CGPointMake(x, y);
    
    float newX = x + cosf(angle) * distance;
    float newY = y + sinf(angle) * distance;

    return CGPointMake(newX, newY);
}


@implementation StatisticsViewController

- (id) init {
    
    if (self = [super init]) {
        
        NSLog(@"StatisticsViewController INIT");
        
        _images = [NSMutableArray array];
    }
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    

    
}


- (void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"stats viewdidsppear");
    
    [super viewWillAppear:animated];

    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_images removeAllObjects];
    
    [self.navigationItem setTitle:[PDFManager manager].moduleName];
    
    
    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    NSLog(@"barColor: %@", barColor);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];;
    self.tabBarController.tabBar.tintColor = [barColor colorByDarkingByPercent:0.6];
    
    
//    [self resetImages];
}


- (void) viewDidAppear:(BOOL)animated {
    
    NSLog(@"stats viewdidsppear");
    
    [super viewDidAppear:animated];


    
    
    float imageWidth = self.view.frame.size.width * IMAGE_WIDTH_RATIO;
    float imageHeight = imageWidth / 2;
    
    NSString* moduleName = [PDFManager manager].moduleName;
    uint totalPages = [[[PDFManager manager] pages] count];
    uint understoodPages = [UserDataManager numberOfUnderstoodPageForModule:moduleName];
    uint notUnderstoodPage = [UserDataManager numberOfNotUnderstoodPageForModule:moduleName];
    float green = (float)understoodPages / totalPages;
    float red = (float)notUnderstoodPage / totalPages;
    
    NSLog(@"total: %d, understood: %d, not understood: %d", totalPages, understoodPages, notUnderstoodPage);
    
    StatisticsImage* image = [[StatisticsImage alloc] initWithTitle:moduleName red:red green:green size:CGSizeMake(imageWidth, imageHeight)];
    image.progressDegrees = 0;
    image.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    [self.view addSubview:image];
    
    [_images addObject:image];
    
    float totalDuration = ANIMATION_DURATION_DEGREES + ANIMATION_DURATION_DISTANCE;
    uint totalFrames = totalDuration * ANIMATION_FRAMES_PER_SECOND;
    
    Ticker* ticker = [[Ticker alloc] initWithTicks:totalFrames intervalLength:1/ANIMATION_FRAMES_PER_SECOND];
    ticker.delegate = self;
    [ticker start];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return TRUE;
}


- (BOOL) shouldAutorotate {
    
    return true;
}


- (NSUInteger) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}



- (void) resetImages {
    
    for (StatisticsImage* image in _images) {
        
        image.progressDegrees = 0;
        image.progressDistance = 0;
        
        [image setNeedsDisplay];
    }
}


- (void) tickerDidTickWithTickNumber:(uint)tickNumber {
    
//    NSLog(@"ticker did tick with number: %d", tickNumber);
    
    for (StatisticsImage* image in _images) {
        
        if (tickNumber <= ANIMATION_FRAMES_DEGREES) {
            image.progressDegrees = tickNumber * PROGRESS_DEGREES_PER_TICK;
        }
        else {
            image.progressDistance = tickNumber - ANIMATION_FRAMES_DEGREES;
        }
        
        [image setNeedsDisplay];
    }
}


- (void) dealloc {
    
    NSLog(@"StatisticsViewController DEALLOC");
}


@end



@implementation StatisticsImage

@synthesize progressDegrees, progressDistance;



- (id) initWithTitle:(NSString *)title red:(float)red green:(float)green size:(CGSize)size {

    if (self = [super init]) {
        
        _title = [title copy];
        _greenDegrees = 360.0 * green;
        _redDegrees = 360.0 * red;
        _whiteDegrees = 360.0 * (1 - green - red);
        
//        NSLog(@"whole: %f", _greenDegrees + _whiteDegrees + _redDegrees);
        
        _size = size;
        self.progressDegrees = 0;
        self.progressDistance = 0;
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}



- (void) drawRect:(CGRect)rect {
    
//    NSString* timerName = [NSString stringWithFormat:@"frame_%d", self.progressDegrees + self.progressDistance];
//    timer_start(timerName);
    
//    NSLog(@"drawRect");
    
    CGContextRef context = UIGraphicsGetCurrentContext();

//    CGLayerRef layer = CGLayerCreateWithContext(context2, rect.size, nil);
//    CGContextRef context = CGLayerGetContext(layer);

    CGContextClearRect(context, rect);
    
    
    
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextFillRect(context, rect);
    
    CGRect chartRect = CGRectMake(0, 0, rect.size.width / 2, rect.size.height);
    float radius = chartRect.size.width / 2 - 20;
    float distanceFromCenter = self.progressDistance * ti_float(PROGRESS_DISTANCE_PER_TICK);
    
    float currentGreenDegrees = 0, currentWhiteDegrees = 0, currentRedDegrees = 0;
    
    uint degreesLeft = self.progressDegrees;
    
    // distribute green degrees
    if (degreesLeft > 0 && degreesLeft <= _greenDegrees) {
        currentGreenDegrees = degreesLeft;
        degreesLeft = 0;
    }
    else if (degreesLeft > 0) {
        currentGreenDegrees = _greenDegrees;
        degreesLeft -= _greenDegrees;
    }
    
//    NSLog(@"green: %f, left: %d", currentGreenDegrees, degreesLeft);
    
    // distribute white degrees
    if (degreesLeft > 0 && degreesLeft <= _whiteDegrees) {
        currentWhiteDegrees = degreesLeft;
        degreesLeft = 0;
    }
    else if (degreesLeft > 0) {
        currentWhiteDegrees = _whiteDegrees;
        degreesLeft -= _whiteDegrees;
    }

//    NSLog(@"white: %f, left: %d", currentWhiteDegrees, degreesLeft);
    
    // distribute red degrees
    if (self.progressDegrees == 360) {
        currentRedDegrees = 360.0 - currentGreenDegrees - currentWhiteDegrees;
    }
    else if (degreesLeft > 0 && degreesLeft <= _redDegrees) {
        currentRedDegrees = degreesLeft;
        degreesLeft = 0;
    }
    else if (degreesLeft > 0) {
        currentRedDegrees = _redDegrees;
        degreesLeft -= _redDegrees;
    }
    
//    NSLog(@"red: %f, left: %d", currentRedDegrees, degreesLeft);

    
//    NSLog(@"green: %f, white: %f, red: %f", currentGreenDegrees, currentWhiteDegrees, currentRedDegrees);

//    NSLog(@"total degrees: %f", currentGreenDegrees + currentWhiteDegrees + currentRedDegrees);
    
    CGMutablePathRef greenPath = nil, whitePath = nil, redPath = nil;
    
    // green
    if (currentGreenDegrees >= CHART_MINIMUM_ANGLE_TO_DRAW) {
        greenPath = CGPathCreateMutable();
        float startAngle = CHART_STARING_ANGLE;
        float endAngle = CHART_STARING_ANGLE + currentGreenDegrees;
        CGPoint point = offsetPoint(chartRect.size.width/2, chartRect.size.height/2, distanceFromCenter, radians((startAngle + endAngle) / 2));
        CGPathMoveToPoint(greenPath, NULL, point.x, point.y);
        CGPathAddArc(greenPath, NULL, point.x, point.y, radius, radians(startAngle), radians(endAngle), FALSE);
        CGPathCloseSubpath(greenPath);
    }
    
    // white
    if (currentWhiteDegrees >= CHART_MINIMUM_ANGLE_TO_DRAW) {
        whitePath = CGPathCreateMutable();
        float startAngle = CHART_STARING_ANGLE + currentGreenDegrees;
        float endAngle = CHART_STARING_ANGLE + currentGreenDegrees + currentWhiteDegrees;
        CGPoint point = offsetPoint(chartRect.size.width/2, chartRect.size.height/2, distanceFromCenter, radians((startAngle + endAngle) / 2));
        CGPathMoveToPoint(whitePath, NULL, point.x, point.y);
        CGPathAddArc(whitePath, NULL, point.x, point.y, radius, radians(startAngle), radians(endAngle), FALSE);
        CGPathCloseSubpath(whitePath);
    }

    // red
    if (currentRedDegrees >= CHART_MINIMUM_ANGLE_TO_DRAW) {
        redPath = CGPathCreateMutable();
        float startAngle = CHART_STARING_ANGLE + currentGreenDegrees + currentWhiteDegrees;
        float endAngle = CHART_STARING_ANGLE + currentGreenDegrees + currentWhiteDegrees + currentRedDegrees;
        CGPoint point = offsetPoint(chartRect.size.width/2, chartRect.size.height/2, distanceFromCenter, radians((startAngle + endAngle) / 2));
        CGPathMoveToPoint(redPath, NULL, point.x, point.y);
        CGPathAddArc(redPath, NULL, point.x, point.y, radius, radians(startAngle), radians(endAngle), FALSE);
        CGPathCloseSubpath(redPath);
    }
    
    CGContextSaveGState(context);
    
    CGContextSetShadowWithColor(context, ti_size(CGSizeMake(2, 2)), ti_int(2), [UIColor blackColor].CGColor);
    
    // fill shadows
    CGContextSetRGBFillColor(context, 0, 1, 0, 1);
    if (greenPath) CGContextAddPath(context, greenPath);
    if (redPath) CGContextAddPath(context, redPath);
    if (whitePath) CGContextAddPath(context, whitePath);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    
    
    // fill paths
    if (greenPath) {
        CGContextSetRGBFillColor(context, 0, 1, 0, 1);
        CGContextAddPath(context, greenPath);
        CGContextFillPath(context);
    }

    if (redPath) {
        CGContextSetRGBFillColor(context, 1, 0, 0, 1);
        CGContextAddPath(context, redPath);
        CGContextFillPath(context);
    }
    
    if (whitePath) {
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
        CGContextAddPath(context, whitePath);
        CGContextFillPath(context);
    }    
    
    
    // stroke paths
    CGContextSetRGBStrokeColor(context, 0.3, 0.3, 0.3, 1);
    CGContextSetLineWidth(context, 0.5);
    
    if (greenPath) CGContextAddPath(context, greenPath);
    if (redPath) CGContextAddPath(context, redPath);
    if (whitePath) CGContextAddPath(context, whitePath);
    CGContextStrokePath(context);
    
    
    // release paths
    if (greenPath)CGPathRelease(greenPath);
    if (redPath)CGPathRelease(redPath);
    if (whitePath)CGPathRelease(whitePath);
    
//    counter_incF(timerName, timer_passed(timerName));
    
//    CGContextDrawLayerInRect(context2, rect, layer);
//    CGLayerRelease(layer);
    
    
    // ***************** draw texts
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetRGBStrokeColor(context, 0.3, 0.3, 0.3, 1.0);
    
    uint offsetLeft = rect.size.width / 2 + ti_int(20);
    uint offsetLeft2 = rect.size.width / 2 + ti_int(110);
    uint offsetLeft3 = rect.size.width / 2 + ti_int(40);
    uint posY = ti_int(20);
    uint marginRight = ti_int(20);
    uint titleWidth = (rect.size.width - offsetLeft - marginRight);
    
    CGSize boxSize = ti_size(CGSizeMake(12, 12));
    
    
    // title text
    
    CGPoint textPoint = CGPointMake(offsetLeft, posY);
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:ti_int(12)];
    NSString* text = _title;
    CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(titleWidth, ti_int(50)) lineBreakMode:UILineBreakModeWordWrap];
    [text drawInRect:CGRectMake(textPoint.x, textPoint.y, textSize.width, textSize.height) withFont:font lineBreakMode:UILineBreakModeWordWrap];
    
//    CGContextFillRect(context, CGRectMake(textPoint.x, textPoint.y, textSize.width, textSize.height));
    
    posY += ti_int(40);
    
    
    // percentages Gewusst
    
    text = @"Gewusst:";
    font = [UIFont fontWithName:@"Helvetica" size:ti_int(10)];
    textSize = [text sizeWithFont:font];
    textPoint = CGPointMake(offsetLeft3, posY);
    CGRect boxRect = CGRectMake(offsetLeft, posY, boxSize.width, boxSize.height);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextAddRect(context, boxRect);
    CGContextSetShadowWithColor(context, ti_size(CGSizeMake(1, 1)), ti_int(1), [UIColor blackColor].CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    CGContextAddRect(context, boxRect);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [text drawAtPoint:textPoint withFont:font];
    
    text = [NSString stringWithFormat:@"%0.1f%%", round((currentGreenDegrees / 360.0) * 1000) / 10];
    textPoint = CGPointMake(offsetLeft2, posY);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [text drawAtPoint:textPoint withFont:font];

    posY += ti_int(20);
    
    
    // percentages Neu
    
    text = @"Neu:";
    font = [UIFont fontWithName:@"Helvetica" size:ti_int(10)];
    textSize = [text sizeWithFont:font];
    textPoint = CGPointMake(offsetLeft3, posY);
    boxRect = CGRectMake(offsetLeft, posY, boxSize.width, boxSize.height);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddRect(context, boxRect);
    CGContextSetShadowWithColor(context, ti_size(CGSizeMake(1, 1)), ti_int(1), [UIColor blackColor].CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    CGContextAddRect(context, boxRect);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [text drawAtPoint:textPoint withFont:font];
    
    text = [NSString stringWithFormat:@"%0.1f%%", round((currentWhiteDegrees / 360.0) * 1000) / 10];
    textPoint = CGPointMake(offsetLeft2, posY);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [text drawAtPoint:textPoint withFont:font];
    
    posY += ti_int(20);
    
    
    // percentages Gewusst
    
    text = @"Wiederholen:";
    font = [UIFont fontWithName:@"Helvetica" size:ti_int(10)];
    textSize = [text sizeWithFont:font];
    textPoint = CGPointMake(offsetLeft3, posY);
    boxRect = CGRectMake(offsetLeft, posY, boxSize.width, boxSize.height);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextAddRect(context, boxRect);
    CGContextSetShadowWithColor(context, ti_size(CGSizeMake(1, 1)), ti_int(1), [UIColor blackColor].CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    CGContextAddRect(context, boxRect);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [text drawAtPoint:textPoint withFont:font];
    
    text = [NSString stringWithFormat:@"%0.1f%%", round((currentRedDegrees / 360.0) * 1000) / 10];
    textPoint = CGPointMake(offsetLeft2, posY);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [text drawAtPoint:textPoint withFont:font];

    
}


+ (UIImage*) createImageWithGreen:(float)green red:(float)red size:(CGSize)size {

    
    float greenDegrees = 360.0 * green;
    float redDegrees = 360.0 * red;
    float whiteDegrees = 360.0 * (1 - green - red);

    float radius = (size.width - 20)/2;
    float offsetDegrees = 0;
    float distanceFromCenter = 2.4;
    
    UIGraphicsBeginImageContextWithOptions(size, FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
//    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    


//    CGContextMoveToPoint(context, 0, size.height/2);
//    CGContextAddLineToPoint(context, size.width, size.height/2);
//    CGContextStrokePath(context);
//    
//    CGContextMoveToPoint(context, size.width/2, 0);
//    CGContextAddLineToPoint(context, size.width/2, size.height);
//    CGContextStrokePath(context);
    
    // green
    CGMutablePathRef greenPath = CGPathCreateMutable();
    float startAngle = CHART_STARING_ANGLE;
    float endAngle = CHART_STARING_ANGLE + greenDegrees;
    CGPoint point = offsetPoint(size.width/2, size.height/2, distanceFromCenter, radians((startAngle + endAngle) / 2));
    CGPathMoveToPoint(greenPath, NULL, point.x, point.y);
    CGPathAddArc(greenPath, NULL, point.x, point.y, radius, radians(startAngle), radians(endAngle), FALSE);
    CGPathCloseSubpath(greenPath);

    // white
    CGMutablePathRef whitePath = CGPathCreateMutable();
    startAngle = CHART_STARING_ANGLE + greenDegrees;
    endAngle = CHART_STARING_ANGLE + greenDegrees + whiteDegrees;
    point = offsetPoint(size.width/2, size.height/2, distanceFromCenter, radians((startAngle + endAngle) / 2));
    CGPathMoveToPoint(whitePath, NULL, point.x, point.y);
    CGPathAddArc(whitePath, NULL, point.x, point.y, radius, radians(startAngle), radians(endAngle), FALSE);
    CGPathCloseSubpath(whitePath);

    // red
    CGMutablePathRef redPath = CGPathCreateMutable();
    startAngle = CHART_STARING_ANGLE + greenDegrees + whiteDegrees;
    endAngle = CHART_STARING_ANGLE + greenDegrees + whiteDegrees + redDegrees;
    point = offsetPoint(size.width/2, size.height/2, distanceFromCenter, radians((startAngle + endAngle) / 2));
    CGPathMoveToPoint(redPath, NULL, point.x, point.y);
    CGPathAddArc(redPath, NULL, point.x, point.y, radius, radians(startAngle), radians(endAngle), FALSE);
    CGPathCloseSubpath(redPath);


    CGContextSaveGState(context);
    
    CGContextSetShadowWithColor(context, CGSizeMake(3, 3), 2, [UIColor blackColor].CGColor);
    
    // fill shadows
    CGContextSetRGBFillColor(context, 0, 1, 0, 1);
    CGContextAddPath(context, greenPath);
    CGContextAddPath(context, redPath);
    CGContextAddPath(context, whitePath);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);

    
    // fill paths
    CGContextSetRGBFillColor(context, 0, 1, 0, 1);
    CGContextAddPath(context, greenPath);
    CGContextFillPath(context);
    
    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    CGContextAddPath(context, redPath);
    CGContextFillPath(context);
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextAddPath(context, whitePath);
    CGContextFillPath(context);

    
    
    // stroke paths
    CGContextSetRGBStrokeColor(context, 0.3, 0.3, 0.3, 1);
    CGContextSetLineWidth(context, 0.5);
    
    CGContextAddPath(context, greenPath);
    CGContextStrokePath(context);
    CGContextAddPath(context, redPath);
    CGContextStrokePath(context);
    CGContextAddPath(context, whitePath);
    CGContextStrokePath(context);

    
    // release paths
    CGPathRelease(greenPath);
    CGPathRelease(redPath);
    CGPathRelease(whitePath);

    
    
    UIImage* image =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end




@implementation Ticker

@synthesize delegate;


- (id) initWithTicks:(uint)ticks intervalLength:(float)intervalLength {
    
    if (self = [super init]) {

        _numberOfTicks = ticks;
        _intervalLength = intervalLength;
        _tickNumber = 0;
    }
    
    return self;
}


- (void) start {
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_intervalLength target:self selector:@selector(tick) userInfo:nil repeats:TRUE];
    
    NSLog(@"started with timer: %@", _timer);
    
    timer_start(@"whole_animation");
}

- (void) tick {
    
//    NSLog(@"tick: %d", _tickNumber);
    
    [self.delegate tickerDidTickWithTickNumber:_tickNumber];
    ++_tickNumber;
    
    if (_tickNumber > _numberOfTicks) {
        [self stop];
    }
}

- (void) stop {
    
    NSLog(@"stop");
    
    [_timer invalidate];
    _timer = nil;
    
    counter_incF(@"whole_animation", timer_passed(@"whole_animation"));
    counter_printall;
    counter_removeAll;
}


@end


