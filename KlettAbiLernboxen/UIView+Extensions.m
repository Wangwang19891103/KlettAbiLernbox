//
//  UIView+Extensions.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 15.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+Extensions.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIView (Frame_Setters)


#pragma mark Setters

- (void) setFrameX:(float)theX {
    
    CGRect newFrame = self.frame;
    newFrame.origin.x = theX;
    self.frame = newFrame;
}

- (void) setFrameY:(float)theY {
    
    CGRect newFrame = self.frame;
    newFrame.origin.y = theY;
    self.frame = newFrame;
}

- (void) setFrameWidth:(float)theWidth {
    
    CGRect newFrame = self.frame;
    newFrame.size.width = theWidth;
    self.frame = newFrame;
}

- (void) setFrameHeight:(float)theHeight {
    
    CGRect newFrame = self.frame;
    newFrame.size.height = theHeight;
    self.frame = newFrame;
}

- (void) setFrameSize:(CGSize)theSize {
    
    CGRect newFrame = self.frame;
    newFrame.size = theSize;
    self.frame = newFrame;
}

- (void) setFrameOrigin:(CGPoint)theOrigin {
    
    CGRect newFrame = self.frame;
    newFrame.origin = theOrigin;
    self.frame = newFrame;
}


#pragma mark Center Methods

- (void) centerXInSuperview {
    
    if (!self.superview) return;
    
    int superWidth = self.superview.frame.size.width;
    int selfWidth = self.frame.size.width;
    float posX = (superWidth - selfWidth) / 2;
    [self setFrameX:posX];
}

- (void) centerYInSuperview {

    if (!self.superview) return;
    
    int superHeight = self.superview.frame.size.height;
    int selfHeight = self.frame.size.height;
    float posY = (superHeight - selfHeight) / 2;
    [self setFrameY:posY];
}

- (void) centerOverPoint:(CGPoint)point {
    
    int posX = point.x - (self.frame.size.width / 2);
    int posY = point.y - (self.frame.size.height / 2);
    [self setFrameOrigin:CGPointMake(posX, posY)];
}


#pragma mark Scaling Methods

- (void) scaleToWidth:(int)theWidth withUpScale:(BOOL)upScale {
    
    CGRect newFrame = self.frame;
    float oldWidth = newFrame.size.width;
    float ratio = (theWidth > oldWidth && !upScale) ? 1 : theWidth / oldWidth;
    CGSize newSize = CGSizeMake(oldWidth * ratio, newFrame.size.height * ratio);
    newFrame.size = newSize;
    self.frame = newFrame;
}

- (void) scaleToHeight:(int)theHeight withUpScale:(BOOL)upScale {
    
    CGRect newFrame = self.frame;
    float oldHeight = newFrame.size.height;
    float ratio = (theHeight > oldHeight && !upScale) ? 1 : theHeight / oldHeight;
    CGSize newSize = CGSizeMake(newFrame.size.width * ratio, oldHeight * ratio);
    newFrame.size = newSize;
    self.frame = newFrame;
}

- (void) scaleToSize:(CGSize)theSize withUpScale:(BOOL)upScale {
    
    CGRect newFrame = self.frame;
    float oldWidth = newFrame.size.width;
    float oldHeight = newFrame.size.height;
    float ratioW = (theSize.width > oldWidth && !upScale) ? 1 : theSize.width / oldWidth;
    float ratioH = (theSize.height > oldHeight && !upScale) ? 1 : theSize.height / oldHeight;
    float ratio = (ratioW < ratioH) ? ratioW : ratioH;
    CGSize newSize = CGSizeMake(oldWidth * ratio, oldHeight * ratio);
    newFrame.size = newSize;    
    self.frame = newFrame;
}


#pragma mark Misc Methods

- (UIView*) parentViewOfClass:(Class)class {
    
    UIView* parent = self;
    
    while (parent != nil && ![parent isKindOfClass:class]) {
        parent = parent.superview;
    }
    
    return parent;
}

- (UIImage*) captureImage {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, FALSE, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


//+ (void) replaceView:(UIView **)oldView inSuperviewWithView:(UIView *)newView centering:(BOOL)centering withStrongReference:(BOOL)strong {
//    
//    if (![*oldView superview]) {
//        return;
//    }
//    
//    [[*oldView superview] addSubview:newView];
//    
//    if (centering) {
//        [newView centerOverPoint:[*oldView center]];
//    }
//    else {
//        newView.frame = [*oldView frame];
//    }
//    
//    if (strong) {
//        [*oldView autorelease];
//        [newView retain];
//    }
//    
//    [*oldView removeFromSuperview];
//    
//    *oldView = newView;
//}

@end
