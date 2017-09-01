//
//  CustomSegmentedControl.m
//  KlettAbiLernboxen
//
//  Created by Wang on 18.11.12.
//
//

#import "CustomSegmentedControl.h"
#import "ResourceManager.h"
#import <QuartzCore/QuartzCore.h>
#import "ModuleManager.h"
#import "PDFManager.h"
#import "UIImage+Extensions.h"
#import "UIColor+Extensions.h"


#define Left_Range      NSMakeRange(0, 108)
#define Middle_Range    NSMakeRange(108, 106)
#define Right_Range     NSMakeRange(214, 107)

#define Left_Range_2    NSMakeRange(0, 160)
#define Right_Range_2  NSMakeRange(160, 160)

#define Cap_Insets_Selected     UIEdgeInsetsMake(18,12,12,15)
#define Cap_Insets_Deselected   UIEdgeInsetsMake(0,4,4,4)
#define Font [UIFont fontWithName:@"Helvetica-Bold" size:12.0]
#define Text_Color [UIColor whiteColor]
#define Text_Shadow_Color [UIColor blackColor]
#define Text_Shadow_Offset CGSizeMake(0, -0.5)
#define Text_Shadow_Blur 0.75


@implementation CustomSegmentedControl

@synthesize selectedIndex;
@synthesize titles;


#pragma mark Initializer

- (id) initWithCoder:(NSCoder *)aDecoder {

    if (self = [super initWithCoder:aDecoder]) {
        
        selectedIndex = 0;
        
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:recognizer];
        
//        [[PropertyBoard instance] addChangeObserver:self];
        
        self.clipsToBounds = FALSE;
        
        
        UIImage* shadowPatternImage = [(UIImage*) resource(@"Images.DocumentView.SegmentedControl.ShadowPattern") resizableImageWithCapInsets:UIEdgeInsetsZero];
        
        UIImageView* shadowImageView = [[UIImageView alloc] initWithImage:shadowPatternImage];
        shadowImageView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 2);
        shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:shadowImageView];
    }
    
    return self;
}


#pragma mark View

//- (void) didMoveToSuperview {
//    
//    if (self.superview) {
//        
//        [self setNeedsDisplay];
//    }
//}


- (void) drawRect:(CGRect)rect {
    
    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"segmented saturation") * 0.01];
    
//    UIImage* buttonSelected = [[(UIImage*)resource(@"Images.DocumentView.SegmentedControl.ButtonSelected") imageWithAdjustmentColor:barColor] resizableImageWithCapInsets:Cap_Insets_Selected resizingMode:UIImageResizingModeStretch];
    UIImage* buttonSelected = [[(UIImage*)resource(@"Images.DocumentView.SegmentedControl.ButtonSelected") imageWithAdjustmentColor:barColor] resizableImageWithCapInsets:Cap_Insets_Selected];
    
//    UIImage* buttonDeselected = [[(UIImage*)resource(@"Images.DocumentView.SegmentedControl.ButtonDeselected") imageWithAdjustmentColor:barColor] resizableImageWithCapInsets:Cap_Insets_Deselected resizingMode:UIImageResizingModeStretch];
    UIImage* buttonDeselected = [[(UIImage*)resource(@"Images.DocumentView.SegmentedControl.ButtonDeselected") imageWithAdjustmentColor:barColor] resizableImageWithCapInsets:Cap_Insets_Deselected];

    UIImage* backgroundImage = [[(UIImage*) resource(@"Images.DocumentView.SegmentedControl.BackgroundPattern") imageWithAdjustmentColor:barColor] resizableImageWithCapInsets:UIEdgeInsetsZero];
    
    
    float offsetX = (rect.size.width - 320) * 0.5;
    
    UIImage* currentImage = nil;
    CGRect currentRect;
    NSString* currentText;
    CGSize currentTextSize;
    CGRect currentTextRect;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, Text_Color.CGColor);
    
    /* background */
    if (offsetX > 0) {
        
        /* left side */
        currentRect = CGRectMake(0, 0, offsetX, rect.size.height);
        [backgroundImage drawInRect:currentRect];
        
        /* right side */
        currentRect = CGRectMake(rect.size.width - offsetX, 0, offsetX, rect.size.height);
        [backgroundImage drawInRect:currentRect];
    }
    
    
    if (self.titles.count == 3) {
        
        /* left button */
        currentImage = (selectedIndex == 0) ? buttonSelected : buttonDeselected;
        currentRect = CGRectMake(offsetX + Left_Range.location, 0, Left_Range.length, rect.size.height);
        [currentImage drawInRect:currentRect];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, Text_Shadow_Offset, Text_Shadow_Blur, Text_Shadow_Color.CGColor);
        currentText = [titles objectAtIndex:0];
        currentTextSize = [currentText sizeWithFont:Font];
        currentTextRect = CGSizeCenterInRect(currentTextSize, currentRect);
        [currentText drawInRect:currentTextRect withFont:Font];
        CGContextRestoreGState(context);
        
        /* middle button */
        currentImage = (selectedIndex == 1) ? buttonSelected : buttonDeselected;
        currentRect = CGRectMake(offsetX + Middle_Range.location, 0, Middle_Range.length, rect.size.height);
        [currentImage drawInRect:currentRect];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, Text_Shadow_Offset, Text_Shadow_Blur, Text_Shadow_Color.CGColor);
        currentText = [titles objectAtIndex:1];
        currentTextSize = [currentText sizeWithFont:Font];
        currentTextRect = CGSizeCenterInRect(currentTextSize, currentRect);
        [currentText drawInRect:currentTextRect withFont:Font];
        CGContextRestoreGState(context);
        
        /* right button */
        currentImage = (selectedIndex == 2) ? buttonSelected : buttonDeselected;
        currentRect = CGRectMake(offsetX + Right_Range.location, 0, Right_Range.length, rect.size.height);
        [currentImage drawInRect:currentRect];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, Text_Shadow_Offset, Text_Shadow_Blur, Text_Shadow_Color.CGColor);
        currentText = [titles objectAtIndex:2];
        currentTextSize = [currentText sizeWithFont:Font];
        currentTextRect = CGSizeCenterInRect(currentTextSize, currentRect);
        [currentText drawInRect:currentTextRect withFont:Font];
        CGContextRestoreGState(context);
    }
    else if (self.titles.count == 2) {
        
        /* left button */
        currentImage = (selectedIndex == 0) ? buttonSelected : buttonDeselected;
        currentRect = CGRectMake(offsetX + Left_Range_2.location, 0, Left_Range_2.length, rect.size.height);
        [currentImage drawInRect:currentRect];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, Text_Shadow_Offset, Text_Shadow_Blur, Text_Shadow_Color.CGColor);
        currentText = [titles objectAtIndex:0];
        currentTextSize = [currentText sizeWithFont:Font];
        currentTextRect = CGSizeCenterInRect(currentTextSize, currentRect);
        [currentText drawInRect:currentTextRect withFont:Font];
        CGContextRestoreGState(context);
        
        /* right button */
        currentImage = (selectedIndex == 1) ? buttonSelected : buttonDeselected;
        currentRect = CGRectMake(offsetX + Right_Range_2.location, 0, Right_Range_2.length, rect.size.height);
        [currentImage drawInRect:currentRect];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, Text_Shadow_Offset, Text_Shadow_Blur, Text_Shadow_Color.CGColor);
        currentText = [titles objectAtIndex:1];
        currentTextSize = [currentText sizeWithFont:Font];
        currentTextRect = CGSizeCenterInRect(currentTextSize, currentRect);
        [currentText drawInRect:currentTextRect withFont:Font];
        CGContextRestoreGState(context);
    }
}


- (void) variableValueChangedForName:(NSString *)name {
    
    [self setNeedsDisplay];
}


#pragma mark Events

- (void) handleTap:(UIGestureRecognizer *)recognizer {
    
    CGPoint position = [recognizer locationInView:self];
    
    NSLog(@"position: %@", NSStringFromCGPoint(position));
    
    uint index = [self indexForTouchPoint:position];

    if (index == selectedIndex)
        return;
    
    if (index != -1) {
        
        selectedIndex = index;
    }
    
    [self setNeedsDisplay];
    
    [_valueChangedTarget performSelector:_valueChangedSelector withObject:self];
}


- (uint) indexForTouchPoint:(CGPoint) point {
    
    float offsetX = (self.bounds.size.width - 320) * 0.5;
    
    
    if (self.titles.count == 3) {
    
        if (CGRectContainsPoint(CGRectMake(offsetX + Left_Range.location, 0, Left_Range.length, self.bounds.size.height), point)) {
            
            return 0;
        }
        else if (CGRectContainsPoint(CGRectMake(offsetX + Middle_Range.location, 0, Middle_Range.length, self.bounds.size.height), point)) {
            
            return 1;
        }
        else if (CGRectContainsPoint(CGRectMake(offsetX + Right_Range.location, 0, Right_Range.length, self.bounds.size.height), point)) {
            
            return 2;
        }
        else return -1;
    }
    else if (self.titles.count == 2) {
        
        if (CGRectContainsPoint(CGRectMake(offsetX + Left_Range_2.location, 0, Left_Range_2.length, self.bounds.size.height), point)) {
            
            return 0;
        }
        else if (CGRectContainsPoint(CGRectMake(offsetX + Right_Range_2.location, 0, Right_Range_2.length, self.bounds.size.height), point)) {
            
            return 1;
        }
        else return -1;
    }
    else return -1;
}



#pragma mark Public Methods

- (void) setValueChangedSelector:(SEL)selector onTarget:(id)target {
    
    _valueChangedTarget = target;
    _valueChangedSelector = selector;
}


@end
